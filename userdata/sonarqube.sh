#!/bin/bash

# Update packages in Amazon linux
sudo yum update -y

# Install wget unzip and firewall
sudo yum install wget unzip firewalld -y

# Install Java 17
sudo yum install java-17-amazon-corretto -y

# Install PostgreSQL
sudo dnf install postgresql15.x86_64 postgresql15-server

# Initialize the database
sudo postgresql-setup --initdb

# Start and enable the PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create a PostgreSQL user and database for SonarQube
sudo -u postgres psql -c "CREATE USER sonar WITH PASSWORD 'admin123';"
sudo -u postgres psql -c "CREATE DATABASE sonar;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonar TO sonar;"

# Download and install SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.6.0.92116.zip
sudo unzip sonarqube-10.6.0.92116.zip
sudo rm -rf sonarqube-10.6.0.92116.zip
sudo mv sonarqube-10.6.0.92116 sonarqube

# Configure SonarQube
sudo sed -i 's/#sonar.jdbc.url=/sonar.jdbc.url=jdbc:postgresql:\/\/localhost\/sonarqube/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=admin123/g' /opt/sonarqube/conf/sonar.properties

# Create a Systemd Service for SonarQube
sudo cat <<EOT >> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonarqube
Group=sonarqube
LimitNOFILE=65536
LimitNPROC=4096
TimeoutStartSec=5
Restart=always
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target

EOT

# Create sonarqube user
sudo groupadd sonarqube
sudo useradd --system --gid sonarqube --no-create-home sonarqube

# Set Directory Ownership
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Start and enable the SonarQube service
sudo systemctl daemon-reload
sudo systemctl start sonarqube
sudo systemctl enable sonarqube

# Open port 9000 for SonarQube
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=9000/tcp
sudo firewall-cmd --reload
