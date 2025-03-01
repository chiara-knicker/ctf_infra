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

echo "Shutting down CTF infrastructure"

provider=$1

# Check if theme provider name is provided
if [ -z "$provider" ]; then
  echo "Using default provider: oracle."
  provider="oracle"
fi

# Change to Terraform directory
cd "terraform/ctfd/$provider"

# Get the public IP addresses of the VMs from Terraform output
CTFD_IP=$(terraform output -raw ctfd_instance_ip)

echo "CTFd Server IP: $CTFD_IP"

# Gracefully shut down services
echo "Stopping CTFd services on $CTFD_IP..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "cd /opt/CTFd && sudo docker-compose down"

# Destroy Terraform-managed resources
echo "Destroying Terraform infrastructure..."
terraform destroy -var-file="variables.tfvars" -auto-approve
rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl

# Return to the original directory
cd ../../..

echo "CTF infrastructure has been successfully destroyed!"
