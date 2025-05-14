#!/bin/bash
# Create directory structure
mkdir -p master/conf.d master/init slave/conf.d slave/init

# Make sure the init scripts are executable
chmod +x master/init/init-master.sh
chmod +x slave/init/init-slave.sh

# Start the MySQL master-slave setup
docker-compose up -d

# Wait for containers to be healthy
echo "Waiting for containers to be healthy..."
sleep 30

# Check replication status
echo "Checking replication status..."
docker exec mysql-slave mysql -uroot -pslave_root_password -e "SHOW SLAVE STATUS\G"

echo "MySQL master-slave setup complete!"
echo "Master available at localhost:3306/myntra_inventory_replenisher"
echo "Slave available at localhost:3307/myntra_inventory_replenisher"