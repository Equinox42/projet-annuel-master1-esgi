#!/bin/bash

SSM_PREFIX="/rds/backup"
DB_NAME="guestbook"
DATE=$(date +%Y-%m-%d-%H-%M)
DUMP_FILE="/tmp/${DB_NAME}_${DATE}.sql"
S3_BUCKET="m1-projet-annuel-backup-bucket"
S3_KEY="${DB_NAME}_${DATE}.sql.gz"

# --- Récupération des infos depuis SSM ---
DB_HOST=$(aws ssm get-parameter --name "/rds/backup/endpoint" --with-decryption --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "${SSM_PREFIX}/username" --with-decryption --query "Parameter.Value" --output text)
DB_PASS=$(aws ssm get-parameter --name "${SSM_PREFIX}/password" --with-decryption --query "Parameter.Value" --output text)

# --- Log ---
echo "[INFO] Dumping MySQL database ${DB_NAME} from ${DB_HOST}..."

# --- Dump ---
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" --single-transaction "$DB_NAME" > "$DUMP_FILE"

# --- Compression ---
gzip "$DUMP_FILE"

# --- Upload sur S3 ---
aws s3 cp "${DUMP_FILE}.gz" "s3://${S3_BUCKET}/${S3_KEY}"

# --- Résultat ---
if [[ $? -eq 0 ]]; then
    echo "[✅] Dump envoyé vers s3://${S3_BUCKET}/${S3_KEY}"
else
    echo "[❌] Erreur lors de l’upload"
    exit 1
fi
