#!/bin/sh

echo "==================== Starting PLS Data Grabber..."
echo "==================== Setting up cron..."

# Set up the cron job
echo "*/$CRON_SCHEDULE /usr/local/bin/python /app/plsgrabber.py > /proc/1/fd/1 2>&1" | crontab -
crontab -l

echo "==================== Starting cron..."

# Start cron in the foreground
exec cron -f