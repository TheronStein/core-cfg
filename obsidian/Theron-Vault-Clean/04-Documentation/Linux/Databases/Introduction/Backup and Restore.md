PostgreSQL allows you to back up and restore each database independently, or you can back up the entire cluster (which includes all databases).

Example of Backing Up a Single Database:
```bash
pg_dump -U rampdb -d rampage_db -f rampage_db_backup.sql
```

Example of Restoring a Database:
```bash
psql -U rampdb -d rampage_db -f rampage_db_backup.sql
```