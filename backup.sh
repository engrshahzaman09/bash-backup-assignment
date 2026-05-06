#!/bin/bash

# Errors par script ko rokne ke liye
set -e

# Variables
LOG_FILE="/var/log/backup.log"
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Function: Log messages
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 1. Check if argument (source folder) is provided
if [ -z "$1" ]; then
    echo "Error: Please provide source folder path."
    echo "Usage: ./backup.sh /path/to/folder"
    exit 1
fi

SOURCE=$1

# 2. Check if source folder exists
if [ ! -d "$SOURCE" ]; then
    log_msg "ERROR: Source $SOURCE not found!"
    exit 1
fi

# 3. Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log_msg "ERROR: Backup directory $BACKUP_DIR missing!"
    exit 1
fi

# 4. Create Backup
BACKUP_NAME="backup_$(basename "$SOURCE")_$TIMESTAMP.tar.gz"

if tar -czf "$BACKUP_DIR/$BACKUP_NAME" "$SOURCE" > /dev/null 2>&1; then
    log_msg "SUCCESS: Backup saved as $BACKUP_NAME"
    echo "Done! Backup created successfully."
else
    log_msg "FAILURE: Could not create backup."
    exit 1
fi

# 5. Bonus: Delete backups older than 7 days
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;
log_msg "INFO: Old backups cleaned up."
