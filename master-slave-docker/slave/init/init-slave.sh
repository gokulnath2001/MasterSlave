#!/bin/bash
set -e

# Configuration script for MySQL slave

# Wait for MySQL master to be ready
echo "Waiting for MySQL master to be ready..."
until mysql -h mysql-master -u root -pmaster_root_password -e "SELECT 1"; do
  sleep 5
done

# Get master log file and position
echo "Getting master log file and position..."
MASTER_STATUS=$(mysql -h mysql-master -u root -pmaster_root_password -e "SHOW MASTER STATUS\G")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

echo "Master log file: $MASTER_LOG_FILE"
echo "Master log position: $MASTER_LOG_POS"

# Configure slave replication
mysql -u root -p$MYSQL_ROOT_PASSWORD <<-EOSQL
  CHANGE MASTER TO
    MASTER_HOST='mysql-master',
    MASTER_USER='repl_user',
    MASTER_PASSWORD='repl_password',
    MASTER_LOG_FILE='$MASTER_LOG_FILE',
    MASTER_LOG_POS=$MASTER_LOG_POS;
  START SLAVE;
EOSQL

# Check slave status
echo "MySQL Slave setup complete. Slave status:"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW SLAVE STATUS\G"