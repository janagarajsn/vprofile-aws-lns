#!/bin/bash
# Install memcached
sudo apt-get update
sudo apt-get install memcached -y

# Start memcached
sudo systemctl start memcached

# Enable memcached to start on boot
sudo systemctl enable memcached

# Check memcached status
sudo systemctl status memcached

# Modify the memcached configuration to listen on all interfaces
sudo sed -i 's/-l 127.0.0.1/-l 0.0.0.0/g' /etc/memcached.conf

# Restart memcached to apply changes
sudo systemctl restart memcached

# Install firewalld
sudo apt-get install firewalld -y

# Start firewalld
sudo systemctl start firewalld

# Enable firewalld to start on boot
sudo systemctl enable firewalld

# Open port 11211 for TCP
sudo firewall-cmd --add-port=11211/tcp --permanent

# Open port 11111 for UDP
sudo firewall-cmd --add-port=11111/udp --permanent

# Reload firewalld to apply changes
sudo firewall-cmd --reload

# Start memcached with specific ports and user
sudo memcached -p 11211 -U 11111 -u memcached -d
