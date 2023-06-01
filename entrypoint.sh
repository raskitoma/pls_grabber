#!/bin/sh

echo "==================== Starting PLS Data Grabber..."
echo "==================== Setting up cron task..."

# Set up the cron job
echo "$CRON_SCHEDULE /usr/local/bin/python /app/plsgrabber.py > /proc/1/fd/1 2>&1" | crontab -
crontab -l

echo "==================== Task created..."

# Start cron in the foreground
exec cron -f