# PLS DATA GRABBER

This is an script that runs periodically to multiple data from PLS and stores it into an Influx Database


## Installation

1. Assuming you have a properly running InfluxDB instance, create a bucket and a token with write access.

2. git clone this repo.

3. create a `docker-compose.yml` based on the `docker-compose.sample.yml`. Customize it changing the following variables:

> - `INFLUX_HOST_PORT` - The host where your InfluxDB is running
> - `INFLUX_ORG` - The organization where you created the bucket and token
> - `INFLUX_BUCKET` - The bucket where you want to store the data
> - `INFLUX_KEY` - The token with write access to the bucket
> - `PLS_PRICE_URI` - URL to get price data, Default is Dexscreener API.
> - `PLS_LAUNCH_URI` - URL where PLS staking, validator and APR resides. Default is PLS launchpad site.
> - `CRON_SCHEDULE` - Cron configuration, uses std cron format. Default is every hour. (Please don't abuse the API and sites)

4. Run with `docker-compose.yml build && docker-compose.yml up -d`. Please be patient, it takes a while, because it has to install some packages and, since it depends on Selenium, it has to download the browser and the driver.

5. You can see the logs with `docker-compose.yml logs -f`

## Updates

You can do it manually (taking container down, pull and rebuild), but, for your convenience, there is a script that does it for you. Just run `./restart_plsgrabber.sh` and it will do it for you. Just remember to give it execution permissions with `chmod +x restart_plsgrabber.sh`.


## Usage

It's mostly self explanatory. The idea is this container will run every hour, grab the data from the API and the website and store it into InfluxDB. Then you can use Grafana to visualize it.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.