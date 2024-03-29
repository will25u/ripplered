#!/bin/bash

# Static service name
SERVICE_NAME="sashimono-agent.service"
NOTIFICATION_FILE="/opt/ripplered/notification_url.txt"

# Function to read notification URL from file
read_notification_url() {
    if [ -f "$NOTIFICATION_FILE" ]; then
        NOTIFICATION_URL=$(<"$NOTIFICATION_FILE")
    else
        NOTIFICATION_URL=""
    fi
}

# Function to save notification URL to file
save_notification_url() {
    echo "$1" > "$NOTIFICATION_FILE"
}

# Check if notification URL is provided
if [ "$#" -lt 1 ]; then
    read_notification_url
    if [ -z "$NOTIFICATION_URL" ]; then
        echo "Error: You must provide UpTime Kuma PUSH URL."
        exit 1
    fi
else
    # Save the new notification URL
    NOTIFICATION_URL="$1"
    save_notification_url "$NOTIFICATION_URL"
fi

# Check the service status and notify.
if systemctl is-active --quiet "$SERVICE_NAME"; then
    # If service is running, call the notification URL
    curl -s "$NOTIFICATION_URL" >/dev/null
fi

# Make the script executable
chmod +x "$0"

# Add cron job to call the script every minute
{ crontab -l 2>/dev/null; echo "* * * * * /bin/bash $(realpath "$0")"; } | crontab -
