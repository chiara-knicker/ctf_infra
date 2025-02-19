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
scp -i "$SSH_PRIVATE_KEY" -r ctfd_theme/ucl-core $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/
scp -i "$SSH_PRIVATE_KEY" -r ctfd_theme/porticoHack $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/

# SSH into the VM and deploy CTFd using Docker Compose
echo "Deploying CTFd with Docker Compose..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
    cd /opt/CTFd

    # generate secret key
    sudo sh -c "head -c 64 /dev/urandom > .ctfd_secret_key"

    # Start CTFd in detached mode
    sudo docker-compose up -d
EOF

# get SSL certificate
#echo "Getting SSL certificate..."
#ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
#    sudo certbot --nginx -d $CTFD_DOMAIN
#EOF

# nginx configuration
#echo "Configuring nginx..."
#ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sudo chown -R $SSH_USER:$SSH_USER /etc/nginx/sites-available/" # Give ubuntu user permissions to write to themes directory
#scp -i "$SSH_PRIVATE_KEY" config/nginx.conf $SSH_USER@$CTFD_IP:/etc/nginx/sites-available/ctfd
#ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sed -i 's/your-domain/$CTFD_DOMAIN/g' /etc/nginx/sites-available/ctfd" # Update Nginx config file with actual IP before copying
#ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
#    sudo ln -sf /etc/nginx/sites-available/ctfd /etc/nginx/sites-enabled/
#    sudo nginx -t  # Test for syntax errors
#    sudo systemctl restart nginx
#EOF

# Deploy hosted challenges using Kubernetes
# TODO

echo "CTF setup complete for year ${CTF_YEAR}!"