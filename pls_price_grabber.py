# the sole purpose of this script is to get data from multiple sites to store into a influxdb to be used by a panel

import time
import requests
import logging
import json
import os
import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS

# program vars
everything_ok = True
env_vars = ['INFLUX_HOST_PORT', 'INFLUX_ORG', 'INFLUX_BUCKET', 'INFLUX_KEY', 'PLS_PRICE_URI', 'PLS_PRICE_API_KEY']
not_set = []
my_envars = []
page_data = []
logging.getLogger().setLevel(logging.INFO)

def get_time():
    return time.strftime("%d/%m/%Y %H:%M:%S")

# checking required env vars
for env_var in env_vars:
    if os.environ.get(env_var) is None:
        not_set.append(env_var)
        everything_ok = False
    else:
        my_envars.append(os.environ.get(env_var))
        
if not everything_ok:
    print(f"{get_time()} | The following environment variables are missing: {', '.join(not_set)}. Please refer to documentation to fix this issue.")
else:
    # get PLS price
    try:
        headers = {'X-CMC_PRO_API_KEY': my_envars[5]}
        response = requests.get(my_envars[4], headers=headers)
        data = json.loads(response.text)
        price_usd = float(data['data']['11145']['quote']['USD']['price'])
    except Exception as e:
        logging.info(f"{get_time()} | Error getting data from price API: {str(e)}")
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
        p = influxdb_client.Point("pls_data").field("pls_price", price_usd)
        write_api.write(bucket=f"{my_envars[2]}", record=p)
        logging.info(f"{get_time()} | Data written to influxdb.")
    except Exception as e:
        logging.info(f"{get_time()} | Error writing data to influxdb: {str(e)}")
        everything_ok = False

if everything_ok:
    logging.info(f"{get_time()} | Everything OK! Done!")
else:
    logging.info(f"{get_time()} | Something went wrong, please check logs for more info.")
