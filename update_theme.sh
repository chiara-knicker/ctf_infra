#!/bin/bash

# Exit immediately if any command fails
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

# Check if required environment variables are set
if [ -z "$CTF_YEAR" ]; then
    echo "Error: CTF_YEAR is not defined in .env"
    exit 1
fi

if [ -z "$SSH_USER" ]; then
    echo "Error: SSH_USER is not defined in .env"
    exit 1
fi

if [ -z "$SSH_PRIVATE_KEY" ]; then
    echo "Error: SSH_PRIVATE_KEY is not defined in .env"
    exit 1
fi

# Get the public IP addresses of the VMs from Terraform output
cd terraform
CTFD_IP=$(terraform output -raw ctfd_instance_ip)
cd ..

echo "Updating CTFd theme..."

# SCP the theme folder to the VM
echo "copy files"
scp -i "$SSH_PRIVATE_KEY" -r ctfd_theme/uclcybersoc $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/

# Restart CTFd services to apply the new theme
echo "restart docker"
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "cd /opt/CTFd && sudo docker-compose restart"

echo "CTFd theme updated and service restarted successfully!"
