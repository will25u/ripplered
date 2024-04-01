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

# Set up cron job
CRON_JOB="* * * * * $INSTALL_DIR/evernodewatcher.sh >> $LOG_FILE 2>&1"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Logging and cron job set up successfully."
