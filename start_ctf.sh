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

# Set CTF Year
CHALLENGE_DIR="challenges/$CTF_YEAR"

# Check if the year directory exists
if [ ! -d "$CHALLENGE_DIR" ]; then
    echo "Error: Challenge directory $CHALLENGE_DIR does not exist!"
    exit 1
fi

echo "Starting CTF setup for year: ${CTF_YEAR}"

# Change to Terraform directory
cd "terraform"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply Terraform configuration (ensuring secrets are provided)
echo "Applying Terraform..."
terraform apply -var-file="variables.tfvars" -auto-approve

# Get the public IP addresses of the VMs from Terraform output
CTFD_IP=$(terraform output -raw ctfd_instance_ip)
#CHALLENGES_IP=$(terraform output -raw challenges_instance_ip)

echo "CTFd Server IP: $CTFD_IP"
#echo "Challenges Server IP: $CHALLENGES_IP"

# Return to the original directory
cd ..

# Add CTFd Theme
echo "Adding CTFd theme..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sudo chown -R $SSH_USER:$SSH_USER /opt/CTFd/CTFd/themes/" # Give ubuntu user permissions to write to themes directory
scp -i "$SSH_PRIVATE_KEY" -r ctfd_theme/uclcybersoc $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/

# SSH into the VM and deploy CTFd using Docker Compose
echo "Deploying CTFd with Docker Compose..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
    cd /opt/CTFd

    # Start CTFd in detached mode
    sudo docker-compose up -d
EOF

# Deploy hosted challenges using Kubernetes
# TODO

echo "CTF setup complete for year ${CTF_YEAR}!"
