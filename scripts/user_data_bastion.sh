#!/bin/bash

apt remove -y awscli
apt update -y
apt install -y unzip curl mysql-client

# Installer AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install

SSM_PREFIX="/rds/backup"
SCRIPT_BUCKET="m1-projet-annuel-scripts-bucket"
OBJECT_PATH="config-database/init_database.sql"
DEST_DIR="/tmp"

# Récupération des paramètres SSM
DB_HOST=$(aws ssm get-parameter --name "${SSM_PREFIX}/endpoint" --with-decryption --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "${SSM_PREFIX}/username" --with-decryption --query "Parameter.Value" --output text)
DB_PASS=$(aws ssm get-parameter --name "${SSM_PREFIX}/password" --with-decryption --query "Parameter.Value" --output text)

# Copie du fichier d'init depuis s3
aws s3 cp s3://${SCRIPT_BUCKET}/${OBJECT_PATH} ${DEST_DIR}/init_database.sql

# Injection du script SQL dans le RDS
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" < ${DEST_DIR}/init_database.sql
