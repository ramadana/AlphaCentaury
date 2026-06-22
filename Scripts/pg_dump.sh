# Configuration
BACKUP_DIR="/home/user/db_backups"
DB_NAME="your_db_name"
DB_USER="your_db_user"
CONTAINER_NAME="your_postgres_container_name"
S3_BUCKET="s3://your-bucket-name/database-backups/"

# Generate timestamp in yyyyMMddhhmm format (e.g., 202606220708)
TIMESTAMP=$(date +%Y%m%d%H%M)

# New filename format: <db_name>-<yyyyMMddhhmm>.sql
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}-${TIMESTAMP}.sql"

# 1. Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# 2. Run pg_dump using the new variables
docker exec -t "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"

# 3. Sync to S3
aws s3 sync "$BACKUP_DIR" "$S3_BUCKET" --delete

# 4. Cleanup old files
find "$BACKUP_DIR" -type f -name "${DB_NAME}-*.sql" -mtime +7 -delete