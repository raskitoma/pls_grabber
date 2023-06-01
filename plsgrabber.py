# the sole purpose of this script is to get data from multiple sites to store into a influxdb to be used by a panel

import time
import requests
import logging
import json
import os
import influxdb_client
from selenium import webdriver
from pyvirtualdisplay import Display
from influxdb_client.client.write_api import SYNCHRONOUS
from bs4 import BeautifulSoup

# program vars
everything_ok = True
env_vars = ['INFLUX_HOST_PORT', 'INFLUX_ORG', 'INFLUX_BUCKET', 'INFLUX_KEY', 'PLS_PRICE_URI', 'PLS_LAUNCH_URI']
page_obj = ['Total PLS staked', 'Total validators', 'Current APR']
not_set = []
my_envars = []
page_data = []
logging.getLogger().setLevel(logging.INFO)

# checking required env vars
for env_var in env_vars:
    if os.environ.get(env_var) is None:
        not_set.append(env_var)
        everything_ok = False
    else:
        my_envars.append(os.environ.get(env_var))
        
if not everything_ok:
    print(f"The following environment variables are missing: {', '.join(not_set)}. Please refer to documentation to fix this issue.")
else:
    # get PLS price
    try:
        response = requests.get(my_envars[4])
        data = json.loads(response.text)
        price_usd = float(data['pair']['priceUsd'])
    except Exception as e:
        logging.info('Error getting data from price page: ' + str(e))
        everything_ok = False
    
    # get PLS Total Staked, Validator count and APR
    # Setting virtual display, if needed
    try:
        display = Display(visible=0, size=(1920, 1080))
        display.start()
        logging.info('Virtual display initialized.')
    except Exception as e:
        logging.info('Virtual display not needed, using gecko.')

    try:
        # creating Selenium browser object
        browser = webdriver.Firefox()
        logging.info('Opening %s', my_envars[5])
        browser.get(my_envars[5])
        time.sleep(5)
        browser.implicitly_wait(10)
        html = browser.page_source
        browser.quit()
        soup = BeautifulSoup(html, 'html.parser')
        # checking data from staking page
        for my_obj in page_obj:
            h3 = soup.find('h3', text=my_obj)
            span1 = h3.find_next_sibling('span')
            span2 = span1.find('span')
            text = span2.text
            text = text.replace(',', '').replace(' ', '').replace('PLS', '').replace('%', '')
            text = float(text)
            page_data.append(text)
    except Exception as e:
        logging.info('Error getting data from launchpad page: ' + str(e))
        everything_ok = False
        
# writing data to influxdb
if everything_ok:
    try:
        client = influxdb_client.InfluxDBClient(
            url=f"{my_envars[0]}", 
            token=f"{my_envars[3]}", 
            org=f"{my_envars[1]}"
        )
        write_api = client.write_api(write_options=SYNCHRONOUS)
        p = influxdb_client.Point("pls_data").field("pls_price", price_usd).field("pls_staked", page_data[0]).field("pls_validators", page_data[1]).field("pls_apr", page_data[2])
        write_api.write(bucket=f"{my_envars[2]}", record=p)
        logging.info('Data written to influxdb.')
    except Exception as e:
        logging.info('Error writing data to influxdb: ' + str(e))
        everything_ok = False

if everything_ok:
    logging.info('Everything OK.')
else:
    logging.info('Something went wrong, please check logs for more info.')
