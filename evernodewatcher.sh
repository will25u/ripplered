#!/bin/bash

# Directory to store files
INSTALL_DIR="/opt/ripplered"

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

echo "Notification URL set up successfully."
