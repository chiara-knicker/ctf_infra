#!/bin/bash

set -e

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

# Check if required environment variables are set
if [ -z "$SSH_USER" ]; then
    echo "Error: SSH_USER is not defined in .env"
    exit 1
fi

if [ -z "$SSH_PRIVATE_KEY" ]; then
    echo "Error: SSH_PRIVATE_KEY is not defined in .env"
    exit 1
fi

echo "Shutting down CTFd infrastructure..."

PROVIDER=$1

# Check if cloud provider is provided
if [ -z "$PROVIDER" ]; then
  echo "Using default provider: oracle."
  PROVIDER="oracle"
fi

cd "terraform/ctfd/$PROVIDER"

# Get the public IP address of the VM from Terraform output
CTFD_IP=$(terraform output -raw ctfd_instance_ip)
echo "CTFd Server IP: $CTFD_IP"

# Gracefully shut down services
#echo "Stopping CTFd services on $CTFD_IP..."
#ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "cd /opt/CTFd && sudo docker-compose down"

# Remove the IP from known_hosts
echo "Removing $CTFD_IP from known_hosts..."
ssh-keygen -R "$CTFD_IP"

# Destroy Terraform-managed resources
echo "Destroying Terraform infrastructure..."
terraform destroy -var-file="variables.tfvars" -auto-approve
rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl

echo "CTFd infrastructure has been successfully destroyed!"