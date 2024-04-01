#!/bin/bash

# Directory to store files
INSTALL_DIR="/opt/ripplered"

# Set up log file
LOG_FILE="$INSTALL_DIR/evernodewatcher.log"
touch "$LOG_FILE" || { echo "Failed to create log file $LOG_FILE"; exit 1; }
chmod 644 "$LOG_FILE" || { echo "Failed to set permissions for log file $LOG_FILE"; exit 1; }

# Set up log rotation
LOGROTATE_CONFIG="/etc/logrotate.d/evernodewatcher"
cat << EOF | sudo tee "$LOGROTATE_CONFIG" > /dev/null || { echo "Failed to write logrotate config"; exit 1; }
$LOG_FILE {
    size 5k
    rotate 1
    notifempty
    compress
}
EOF

# Notification URL file
NOTIFICATION_URL_FILE="$INSTALL_DIR/notification_url.txt"

# Check if URL file exists
if [ -f "$NOTIFICATION_URL_FILE" ]; then
    # Read the notification URL from the file
    NOTIFICATION_URL=$(cat "$NOTIFICATION_URL_FILE")
else
    # Prompt the user for a new URL
    read -p "Enter the notification URL: " NOTIFICATION_URL

    # Save the URL to the file
    echo "$NOTIFICATION_URL" > "$NOTIFICATION_URL_FILE" || { echo "Failed to write notification URL to file"; exit 1; }
fi

# Check if URL is empty
if [ -z "$NOTIFICATION_URL" ]; then
    echo "Error: Notification URL is not provided." >&2
    exit 1
fi

# Push URL
if ! curl -s "$NOTIFICATION_URL" >/dev/null; then
    echo "Failed to push URL: $NOTIFICATION_URL" >&2
    exit 1
fi

# Make the script executable
chmod +x "$INSTALL_DIR/evernodewatcher.sh"

# Set up cron job
CRON_JOB="* * * * * $INSTALL_DIR/evernodewatcher.sh >> $LOG_FILE 2>&1"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Setup completed successfully."
