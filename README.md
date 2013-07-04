Shell script for backing up PostgreSQL databases

1. Clone to desired directory
2. Modify pg_backup.config to your needs
3. Add pg_backup.sh to crontab

  Execute `crontab -e`

  Append `@daily /path/to/pg_backup.sh > /dev/null`