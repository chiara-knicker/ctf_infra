#!/bin/bash

#export $(cat .env | xargs)

# Update and install dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git docker.io docker-compose python3-pip nginx certbot python3-certbot-nginx

# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Enable Nginx and start it
sudo systemctl enable nginx
sudo systemctl start nginx

# Clone CTFd repository
cd /opt
sudo git clone https://github.com/CTFd/CTFd.git