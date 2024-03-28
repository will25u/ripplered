 script
#!/bin/bash

# JustMe ROMs script to monitor a service and notify a remote server if it's running.

# Customize these variables as needed:
SERVICE_NAME="sashimono-agent.service"
NOTIFICATION_URL="http://192.168.86.25:3001/api/push/Q0ge6kVb61?status=up&msg=OK&ping="
LOG_FILE="/var/log/check_service.log" # Ensure this directory exists and is writable.

# Create and schedule the monitoring script with a single command block.
cat << EOF | tee check_service.sh | crontab -
#!/bin/bash

# This script monitors a specified service and notifies a given URL.
# Usage: $0 <service_name> <notification_url> [<log_file>]

# Validate input parameters.
if [ "\$#" -lt 2 ]; then
    echo "Usage: \$0 <service_name> <notification_url> [<log_file>]"
    exit 1
fi

# Assign parameters to variables.
SERVICE_NAME="\$1"
NOTIFICATION_URL="\$2"
LOG_FILE="\${3:-/var/log/check_service.log}" # Default log file if not specified.

# Function to log messages with a timestamp.
log_message() {
    echo "\$(date '+%Y-%m-%d %H:%M:%S'): \$1" | tee -a "\$LOG_FILE"
}

# Check the service status and notify.
if systemctl is-active --quiet \$SERVICE_NAME; then
    log_message "\$SERVICE_NAME is running."
    if ! curl -s "\$NOTIFICATION_URL" >/dev/null; then
        log_message "Failed to call URL: \$NOTIFICATION_URL"
    else
        log_message "URL called successfully."
    fi
else
    log_message "\$SERVICE_NAME is not running."
fi

EOF

# Make the generated script executable.
chmod +x check_service.sh

# Schedule the script to run every minute via crontab.
(crontab -l 2>/dev/null; echo "* * * * * $(pwd)/check_service.sh $SERVICE_NAME $NOTIFICATION_URL $LOG_FILE") | crontab -

echo "scheduled to run every minute."
