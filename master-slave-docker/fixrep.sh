# Stop the slave
docker exec mysql-slave mysql -uroot -pslave_root_password -e "STOP SLAVE;"

# Create the database manually on both master and slave
docker exec mysql-master mysql -uroot -pmaster_root_password -e "CREATE DATABASE IF NOT EXISTS myntra_inventory_replenisher;"
docker exec mysql-slave mysql -uroot -pslave_root_password -e "CREATE DATABASE IF NOT EXISTS myntra_inventory_replenisher;"

# Get current master position
MASTER_STATUS=$(docker exec mysql-master mysql -uroot -pmaster_root_password -e "SHOW MASTER STATUS\G")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

echo "Master log file: $MASTER_LOG_FILE"
echo "Master log position: $MASTER_LOG_POS"

# Reset slave and reconfigure replication with current position
docker exec mysql-slave mysql -uroot -pslave_root_password -e "
STOP SLAVE;
RESET SLAVE;
CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_USER='repl_user',
  MASTER_PASSWORD='repl_password',
  MASTER_LOG_FILE='$MASTER_LOG_FILE',
  MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
"

# Check slave status again
docker exec mysql-slave mysql -uroot -pslave_root_password -e "SHOW SLAVE STATUS\G"