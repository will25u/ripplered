#!/bin/bash

# Static service name
SERVICE_NAME="sashimono-agent.service"
NOTIFICATION_FILE="/opt/ripplered/notification_url.txt"
LOG_FILE="/opt/ripplered/evernodewatcher.log"
LOGROTATE_CONFIG="/etc/logrotate.d/evernodewatcher"

# Function to create logrotate configuration file
create_logrotate_config() {
    if [ ! -f "$LOGROTATE_CONFIG" ]; then
        sudo tee "$LOGROTATE_CONFIG" > /dev/null << EOF
$LOG_FILE {
    size 5k
    rotate 1
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF
    fi
}

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

# Prompt the user for the notification URL if not provided as an argument
if [ "$#" -lt 1 ]; then
    read -p "Enter the notification URL (current URL: $(<"$NOTIFICATION_FILE")): " NEW_NOTIFICATION_URL
    if [ -z "$NEW_NOTIFICATION_URL" ]; then
        echo "Error: You must provide a notification URL."
        exit 1
    fi
else
    NEW_NOTIFICATION_URL="$1"
fi

# Save the new notification URL
save_notification_url "$NEW_NOTIFICATION_URL"

# Check the service status and notify.
if systemctl is-active --quiet "$SERVICE_NAME"; then
    # If service is running, call the notification URL
    curl -s "$NEW_NOTIFICATION_URL" >/dev/null
fi

# Create logrotate configuration
create_logrotate_config

# Make the script executable
chmod +x "$0"

# Add cron job to call the script every minute
{ crontab -l 2>/dev/null; echo "* * * * * /bin/bash $(realpath "$0")"; } | crontab -
