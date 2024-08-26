#!/bin/bash
DATABASE_PASS='admin123'

# Install Memcached
sudo apt-get update -y
sudo apt-get install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
sudo memcached -p 11211 -U 11111 -u memcached -d

# Install RabbitMQ dependencies
sudo apt-get install socat -y
sudo apt-get install erlang -y
sudo apt-get install wget -y

# Download and install RabbitMQ
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server_3.6.10-1_all.deb
sudo apt-get install -y ./rabbitmq-server_3.6.10-1_all.deb

# Import the RabbitMQ signing key
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -

# Update package list and install RabbitMQ server
sudo apt-get update
sudo dpkg -i rabbitmq-server_3.6.10-1_all.deb

# Start and enable RabbitMQ server
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server

# Configure RabbitMQ to allow remote access
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

# Add a RabbitMQ user and set administrator privileges
sudo rabbitmqctl add_user rabbit bunny
sudo rabbitmqctl set_user_tags rabbit administrator

# Restart RabbitMQ server to apply changes
sudo systemctl restart rabbitmq-server

# Install MariaDB server
sudo apt-get install mariadb-server -y

# Allow remote access to MariaDB
sudo sed -i 's/^bind-address\s*=.*$/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Start and enable MariaDB server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation and restore the database
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET authentication_string=PASSWORD('$DATABASE_PASS') WHERE User='root'"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'app01' IDENTIFIED BY 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < /vagrant/vprofile-repo/src/main/resources/db_backup.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart MariaDB server to apply changes
sudo systemctl restart mariadb
