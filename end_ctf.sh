#!/bin/bash

# Exit immediately if any command fails
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    # Source the .env file to export variables
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

# Change to Terraform directory
cd "terraform"

# Get the public IP addresses of the VMs from Terraform output
CTFD_IP=$(terraform output -raw ctfd_instance_ip)
#CHALLENGES_IP=$(terraform output -raw challenges_instance_ip)

echo "CTFd Server IP: $CTFD_IP"
#echo "Challenges Server IP: $CHALLENGES_IP"

# Return to the original directory

# Gracefully shut down services
echo "Stopping CTFd services on $CTFD_IP..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "cd /opt/CTFd && sudo docker-compose down"

#if [ "$CHALLENGES_IP" != "Not found" ]; then
#    echo "Stopping all Kubernetes challenge containers on $CHALLENGES_IP..."
#    ssh user@$CHALLENGES_IP "kubectl delete all --all --namespace=default"
#fi

# Destroy Terraform-managed resources
echo "Destroying Terraform infrastructure..."
terraform destroy -var-file="variables.tfvars" -auto-approve

# Return to the original directory
cd ..

echo "CTF infrastructure has been successfully destroyed!"
