# Shell script for backing up PostgreSQL databases

1. Clone to desired directory
2. Modify pg_backup.config to your needs
3. Add pg_backup.sh to crontab

  Execute `crontab -e`

  Append `@daily /path/to/pg_backup.sh > /dev/null`

## If you want something less heavy

* If you don't want to use AWS backups, try (this)[https://github.com/mlensment/backupper/tree/local-only]
* If you want to do just one backup, try (this)[https://github.com/mlensment/backupper/tree/simple]
