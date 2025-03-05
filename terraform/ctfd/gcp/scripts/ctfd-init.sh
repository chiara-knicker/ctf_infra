#!/bin/bash

# Update and install dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git docker.io docker-compose python3-pip rsync python3-certbot-dns-cloudflare

# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Clone CTFd repository
cd /opt
sudo git clone https://github.com/CTFd/CTFd.git