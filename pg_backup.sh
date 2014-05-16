#!/bin/bash

if [ $# = 0 ]; then
  SCRIPTPATH=$(cd ${0%/*} && pwd -P)
  source $SCRIPTPATH/pg_backup.config
fi;

if ! touch $SCRIPTPATH/pg_backup.log; then
  log "[!!ERROR!!] Cannot update backupper log file. Exiting."
  exit 1;
fi;

log() {
  echo -e $1
  echo -e $1 >> $SCRIPTPATH/pg_backup.log
}

log_from_tmp() {
  cat tmp.txt >> $SCRIPTPATH/pg_backup.log
}


backup_to_local() {
  log "Backupping to local"

  pg_dump -Fp -h "$HOSTNAME" -U "$USERNAME" -n "$SCHEMA" "$DATABASE" 2> tmp.txt | gzip > "$FINAL_BACKUP_FILE".sql.gz.in_progress

  if [ ${PIPESTATUS[0]} -ne "0" ]; then
    log_from_tmp
    log "\n[!!ERROR!!] Failed to backup database $DATABASE. Exiting."
    rm  "$FINAL_BACKUP_FILE".sql.gz.in_progress
    exit 1;
  fi

  mv "$FINAL_BACKUP_FILE".sql.gz.in_progress "$FINAL_BACKUP_FILE".sql.gz
  log "Backupped to local $FINAL_BACKUP_FILE.sql.gz"
}

delete_local_backups() {
  # Delete old backups
  log "Deleting local backups older than $DAYS_TO_KEEP days"
  for f in $(find $BACKUP_DIR/* -mtime +$DAYS_TO_KEEP)
  do
    log "Deleting file $f from local"
    rm $f
  done
}

delete_backups() {
  delete_local_backups
}

TIME=`date +\%Y-\%m-\%d_\%H-\%M`

log "Backupper initalized on $TIME"
log "Selected database: $DATABASE"
log "Selected schema: $SCHEMA"

export PGPASSWORD="$PGPASSWORD"

# Make sure we're running as the required backup user
if [ "$BACKUP_USER" != "" -a "$(id -un)" != "$BACKUP_USER" ]; then
  log "[!!ERROR!!] This script must be run as $BACKUP_USER. Exiting."
  exit 1;
fi;

# Create output directory
if ! mkdir -p $BACKUP_DIR; then
  log "[!!ERROR!!] Cannot create backup directory $BACKUP_DIR. Exiting."
  exit 1;
fi;

# Set defaults
if [ ! $HOSTNAME ]; then
  HOSTNAME="localhost"
fi;

if [ ! $USERNAME ]; then
  USERNAME="postgres"
fi;

FINAL_BACKUP_FILE="$BACKUP_DIR"/"$TIME"

# Perform backup
backup_to_local
delete_backups

rm tmp.txt

log "Backup complete\n"
