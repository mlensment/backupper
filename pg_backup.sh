#!/bin/bash


######################
## BACKUPPER CONFIG ##
######################

# Optional username to connect to database as.  Will default to "postgres" if none specified.
HOSTNAME=localhost

USERNAME=blog_v4

#Password
PGPASSWORD=blog_v4_pwd

# Schema
SCHEMA=public

# Database
DATABASE=blog_v4_development

### SCRIPT ###

log() {
  echo -e $1
}

backup_to_local() {
  log "Backupping to local"

  pg_dump -Fp -h "$HOSTNAME" -U "$USERNAME" -n "$SCHEMA" "$DATABASE" 2> log.txt | gzip > "$FINAL_BACKUP_FILE".sql.gz.in_progress

  if [ ${PIPESTATUS[0]} -ne "0" ]; then
    log "\n[!!ERROR!!] Failed to backup database $DATABASE. Exiting."
    rm  "$FINAL_BACKUP_FILE".sql.gz.in_progress
    exit 1;
  fi

  mv "$FINAL_BACKUP_FILE".sql.gz.in_progress "$FINAL_BACKUP_FILE".sql.gz
  log "Backupped to local $FINAL_BACKUP_FILE.sql.gz"
}

TIME=`date +\%Y-\%m-\%d_\%H-\%M`

log "Backupper initalized on $TIME"
log "Selected database: $DATABASE"
log "Selected schema: $SCHEMA"

export PGPASSWORD="$PGPASSWORD"

# Set defaults
if [ ! $HOSTNAME ]; then
  HOSTNAME="localhost"
fi;

if [ ! $USERNAME ]; then
  USERNAME="postgres"
fi;

FINAL_BACKUP_FILE="./"$TIME""

# Perform backup
backup_to_local

rm log.txt
log "Backup complete\n"
