# Configuration
BACKUP_DIR="/root/systems/_data/thera/postgres/backups"
DB_NAME="skies_db"
DB_USER="syahbandar"
CONTAINER_NAME="thr-postgres"
S3_BUCKET="s3://skies-backups/postgres/"

# Generate timestamp in yyyyMMddhhmm format (e.g., 202606220708)
TIMESTAMP=$(date +%Y%m%d%H%M)

# New filename format: <db_name>-<yyyyMMddhhmm>.sql
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}-${TIMESTAMP}.sql"

# 1. Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# 2. Run pg_dump using the new variables
/usr/bin/docker exec -t "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"

# 3. Sync to S3
/usr/bin/aws --endpoint-url https://sgp1.vultrobjects.com s3 sync "$BACKUP_DIR" "$S3_BUCKET" --delete

# 4. Cleanup old files
find "$BACKUP_DIR" -type f -name "${DB_NAME}-*.sql" -mtime +7 -delete