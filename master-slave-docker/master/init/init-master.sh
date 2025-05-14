#!/bin/bash
set -e

# Configuration script for MySQL master

# Create replication user for slave
mysql -u root -p$MYSQL_ROOT_PASSWORD <<-EOSQL
  CREATE USER 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'repl_password';
  GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
  FLUSH PRIVILEGES;
EOSQL

# Print master status for reference
echo "MySQL Master setup complete. Master status:"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW MASTER STATUS\G"