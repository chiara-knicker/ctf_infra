#!/bin/bash

#export $(cat .env | xargs)

# Update and install dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git docker.io docker-compose python3-pip nginx certbot python3-certbot-nginx ufw rsync

# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Allow ssh, HTTP, and HTTPS through the firewall
sudo ufw allow 'Nginx Full'
sudo ufw allow 'OpenSSH'

# Enable the firewall
sudo ufw enable

# For setting up HTTPS
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Clone CTFd repository
cd /opt
sudo git clone https://github.com/CTFd/CTFd.git