#!/bin/bash
echo "Stopping and removing all containers..."
docker-compose down -v

echo "Starting fresh setup..."
docker-compose up -d

echo "Waiting for containers to initialize..."
sleep 30

echo "Checking master database..."
docker exec mysql-master mysql -uroot -pmaster_root_password -e "SHOW DATABASES;"

echo "Testing replication..."
docker exec mysql-master mysql -uroot -pmaster_root_password -e "
CREATE DATABASE IF NOT EXISTS myntra_inventory_replenisher;
USE myntra_inventory_replenisher;
CREATE TABLE test_replication (id INT AUTO_INCREMENT PRIMARY KEY, data VARCHAR(100));
INSERT INTO test_replication (data) VALUES ('Replication test data');"

echo "Checking slave database..."
docker exec mysql-slave mysql -uroot -pslave_root_password -e "SHOW SLAVE STATUS\G"
docker exec mysql-slave mysql -uroot -pslave_root_password -e "
USE myntra_inventory_replenisher;
SELECT * FROM test_replication;"

echo "Setup complete! Master: localhost:3306, Slave: localhost:3307"