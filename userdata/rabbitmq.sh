#!/bin/bash
## Install dependencies
sudo apt-get update -y
sudo apt-get install curl gnupg apt-transport-https -y

## Import the RabbitMQ signing keys
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo apt-key add -
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | sudo apt-key add -

## Add the RabbitMQ and Erlang repositories
sudo sh -c 'echo "deb https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/rabbitmq.list'
sudo sh -c 'echo "deb https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/deb/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/rabbitmq.list'

## Update the package list
sudo apt-get update -y

## Install dependencies
sudo apt-get install socat logrotate -y

## Install Erlang and RabbitMQ server
sudo apt-get install erlang rabbitmq-server -y

## Enable RabbitMQ service to start on boot
sudo systemctl enable rabbitmq-server

## Start RabbitMQ service
sudo systemctl start rabbitmq-server

## Configure RabbitMQ to allow remote access by removing loopback restrictions
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

## Add a new user to RabbitMQ
sudo rabbitmqctl add_user test test

## Grant administrator privileges to the new user
sudo rabbitmqctl set_user_tags test administrator

## Restart RabbitMQ service to apply changes
sudo systemctl restart rabbitmq-server
