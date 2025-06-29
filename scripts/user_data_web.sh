#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

NAME="m1-projet-automatisation"
REGION="eu-west-3"
CW_AGENT_URL="https://amazoncloudwatch-agent-${REGION}.s3.${REGION}.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"
SSM_CLOUDWATCH_CONFIG="AmazonCloudWatch-agent-configuration"
SSM_PREFIX="/rds/backup"
SCRIPT_BUCKET="m1-projet-annuel-scripts-bucket"
OBJECT_PATH="simple-guestbook"
DEST_DIR="/var/www/html"

# Install required packages
apt update -y
apt install -y unzip curl apache2 php php-mysql

# Install AWS CLI
apt remove -y awscli
apt update -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install

# Install CloudWatch Agent
curl -o amazon-cloudwatch-agent.deb "$CW_AGENT_URL"
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Fetch config from SSM and start the agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c ssm:${SSM_CLOUDWATCH_CONFIG} \
  -s

# Install Application
cd /tmp
rm -rf ${DEST_DIR}/*
aws s3 sync s3://${SCRIPT_BUCKET}/${OBJECT_PATH}/ ${DEST_DIR}/

# Get RDS Endpoint 
echo "[INFO] Waiting for RDS endpoint in SSM..."

for i in {1..15}; do
  DB_HOST=$(aws ssm get-parameter --name "${SSM_PREFIX}/endpoint" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
  if [[ -n "$DB_HOST" && "$DB_HOST" != "None" ]]; then
    echo "[INFO] Found DB endpoint: $DB_HOST"
    break
  fi
  echo "[WARN] Attempt $i/15: RDS endpoint not found. Retrying in 10s..."
  sleep 10
done

if [[ -z "$DB_HOST" || "$DB_HOST" == "None" ]]; then
  echo "[ERROR] Could not retrieve RDS endpoint from SSM. Exiting."
  exit 1
fi

sed -i "s|\(\$hostname *= *\).*;|\1'${DB_HOST}';|" ${DEST_DIR}/config.php
chown -R www-data:www-data ${DEST_DIR}
chmod -R 755 ${DEST_DIR}
systemctl restart apache2



