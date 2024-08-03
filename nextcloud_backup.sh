#!/bin/bash

# Remote server details
REMOTE_USER="root"
REMOTE_HOST="139.162.10.231"
REMOTE_NEXTCLOUD_DIR="/DATA/AppData/nextcloud/var/www/html/"
REMOTE_DB_CONTAINER="mariadb"
REMOTE_DB_USER="root"
REMOTE_DB_PASS="casaos"
REMOTE_DB_NAME="casaos"
LOCAL_BACKUP_DIR="./nextcloudbck"

# Create local backup directories if they don't exist
mkdir -p "$LOCAL_BACKUP_DIR/files"
mkdir -p "$LOCAL_BACKUP_DIR/db"

# Stop Nextcloud container on remote server
ssh $REMOTE_USER@$REMOTE_HOST "docker stop nextcloud"

# Rsync the Nextcloud data directory to local machine
rsync -avz --delete $REMOTE_USER@$REMOTE_HOST:"$REMOTE_NEXTCLOUD_DIR" "$LOCAL_BACKUP_DIR/files/"

# Dump the MariaDB database from within the container and transfer it to local machine
ssh $REMOTE_USER@$REMOTE_HOST "docker exec -i $REMOTE_DB_CONTAINER mysqldump -u$REMOTE_DB_USER -p$REMOTE_DB_PASS $REMOTE_DB_NAME" > "$LOCAL_BACKUP_DIR/db/nextcloud_db_$(date +%F).sql"

# Start Nextcloud container on remote server
ssh $REMOTE_USER@$REMOTE_HOST "docker start nextcloud"

# Optional: Remove old local backups older than 7 days
find "$LOCAL_BACKUP_DIR/files/" -type f -mtime +7 -exec rm {} \;
find "$LOCAL_BACKUP_DIR/db/" -type f -mtime +7 -exec rm {} \;

