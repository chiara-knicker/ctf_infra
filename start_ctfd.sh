#!/bin/bash

set -e

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

PROVIDER=$1

# Check if theme provider name is provided
if [ -z "$PROVIDER" ]; then
  echo "Using default provider: oracle."
  PROVIDER="oracle"
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

cd "terraform/ctfd/$PROVIDER"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply Terraform configuration
echo "Applying Terraform..."
terraform apply -var-file="variables.tfvars" -auto-approve

# Get the public IP address of the VM from Terraform output
CTFD_IP=$(terraform output -raw ctfd_instance_ip)

cd ../../..

# Update .env file
if grep -q "^CTFD_IP=" ".env"; then
    sed -i "s|^CTFD_IP=.*|CTFD_IP=$CTFD_IP|" ".env"
else
    echo "CTFD_IP=$CTFD_IP" >> ".env"
fi
echo "Updated .env file successfully!"

# Try to SSH once VM is ready
max_retries=5
wait_time=10 #seconds

set +e
for ((retry_count=1; retry_count<=max_retries; retry_count++)); do
    echo -ne "Attempting to SSH... ($retry_count/$max_retries)                  \r"

    # Attempt SSH
    ssh -i "$SSH_PRIVATE_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 $SSH_USER@$CTFD_IP exit 2>/dev/null

    # Check if SSH connection is successful
    if [ $? -eq 0 ]; then
        echo -e "\nSSH access established!"
        break
    fi

    # If it's not the last attempt, wait and retry
    if [ $retry_count -lt $max_retries ]; then
        echo -ne "SSH is not available yet. Retrying in $wait_time seconds...\r"
        sleep $wait_time
    else
        echo -e "\nError: Unable to SSH into the VM after $max_retries retries."
        exit 1
    fi
done
set -e

# Wait for cloud-init to finish
echo -e "\nWaiting for cloud-init to complete..."
ssh -T -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
    TOTAL_LINES=1615 

    while ! grep -q 'Cloud-init.*finished' /var/log/cloud-init-output.log; do
        CURRENT_LINES=\$(wc -l < /var/log/cloud-init-output.log)
        PERCENTAGE=\$((CURRENT_LINES * 100 / TOTAL_LINES))
        echo -ne "Cloud-init progress: \$PERCENTAGE% (\$CURRENT_LINES / \$TOTAL_LINES) complete...\r"
        sleep 5
    done

    tail -n 1 /var/log/cloud-init-output.log
EOF
echo -e "\nCloud-init finished!"

# Add CTFd Theme
echo "Adding CTFd themes..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sudo chown -R $SSH_USER:$SSH_USER /opt/CTFd/CTFd/themes/" # Give ubuntu user permissions to write to themes directory
#scp -i "$SSH_PRIVATE_KEY" -r ctfd_theme/uclcybersoc $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/
#scp -i "$SSH_PRIVATE_KEY" -r ctfd_theme/ucl-core $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/
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

echo "CTF setup complete for year ${CTF_YEAR}!"