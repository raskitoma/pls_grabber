#!/bin/sh
echo "==================== Starting PLS Data Grabber..."
echo "Current config variables (some of them hidden for security purposes):"
env | grep INFLUX_HOST_PORT
env | grep INFLUX_BUCKET
env | grep PLS_
env | grep CRON_
env | grep PATH

echo "==================== Setting up cron task for pls data bunch and price grab..."
# Set up the cron job
printf "%s env PATH=$PATH:/usr/bin:/opt env INFLUX_HOST_PORT=$INFLUX_HOST_PORT INFLUX_ORG=$INFLUX_ORG INFLUX_BUCKET=$INFLUX_BUCKET INFLUX_KEY=$INFLUX_KEY PLS_PRICE_URI=$PLS_PRICE_URI PLS_PRICE_API_KEY=$PLS_PRICE_API_KEY PLS_LAUNCH_URI=$PLS_LAUNCH_URI /usr/local/bin/python /app/plsgrabber.py > /proc/1/fd/1 2>&1\n%s env PATH=$PATH:/usr/bin:/opt env INFLUX_HOST_PORT=$INFLUX_HOST_PORT INFLUX_ORG=$INFLUX_ORG INFLUX_BUCKET=$INFLUX_BUCKET INFLUX_KEY=$INFLUX_KEY PLS_PRICE_URI=$PLS_PRICE_URI PLS_PRICE_API_KEY=$PLS_PRICE_API_KEY PLS_LAUNCH_URI=$PLS_LAUNCH_URI /usr/local/bin/python /app/pls_price_grabber.py > /proc/1/fd/1 2>&1" "$CRON_SCHEDULE" "$CRON_PRICE" | crontab -

echo "==================== Tasks created..."
crontab -l

echo "==================== First run..."
/usr/local/bin/python /app/plsgrabber.py
/usr/local/bin/python /app/pls_price_grabber.py

echo "==================== Starting cron..."
# Start cron in the foreground
exec cron -f