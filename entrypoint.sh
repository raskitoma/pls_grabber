#!/bin/sh
echo "==================== Starting PLS Data Grabber..."
echo "Current config variables (some of them hidden for security purposes):"
env | grep INFLUX_HOST_PORT
env | grep INFLUX_BUCKET
env | grep PLS_
env | grep CRON_

echo "==================== Setting up cron task..."
# Set up the cron job
echo "$CRON_SCHEDULE /usr/local/bin/python /app/plsgrabber.py > /proc/1/fd/1 2>&1" | crontab -

echo "==================== Task created..."
crontab -l

echo "==================== First run..."
/usr/local/bin/python /app/plsgrabber.py

echo "==================== Starting cron..."
# Start cron in the foreground
exec cron -f