#!/bin/bash

# Update and install open jdk 11 in ubuntu
sudo apt update
sudo apt install openjdk-11-jdk -y

# Create a new user nexus 
sudo useradd -m -U -d /opt/nexus -s /bin/bash nexus

# Download and install nexus
cd /opt
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
sudo tar -xvf latest-unix.tar.gz
sudo mv nexus-3* /opt/nexus
sudo chown -R nexus:nexus /opt/nexus

# Create nexus service
sudo cat <<EOT >> /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Service
After=network.target

[Service]
Type=forking
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

EOT

# Update the JVM memory settings to 512m in nexus config
sudo sed -i 's/^-Xms.*/-Xms512m/' /opt/nexus/bin/nexus.vmoptions
sudo sed -i 's/-Xmx.*/-Xmx512m/g' /opt/nexus/bin/nexus.vmoptions

# Reload daemon and start nexus
sudo systemctl daemon-reload
sudo systemctl start nexus
sudo systemctl enable nexus


