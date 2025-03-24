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
  echo "Usage: ./start_ctfd.sh <provider>"
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

echo "Starting CTFd setup..."

# Initialize Terraform
echo "Initializing Terraform..."
cd "terraform/ctfd/$PROVIDER"
terraform init

# Apply Terraform configuration
echo "Applying Terraform..."
terraform apply -var-file="variables.tfvars" -auto-approve

# Get the public IP address of the VM from Terraform output
CTFD_IP=$(terraform output -raw ctfd_instance_ip)

cd ../../..

# Update .env file
echo "Adding VM IP to .env..."
if grep -q "^CTFD_IP=" ".env"; then
    sed -i "s|^CTFD_IP=.*|CTFD_IP=$CTFD_IP|" ".env"
else
    echo "CTFD_IP=$CTFD_IP" >> ".env"
fi
echo "Updated .env file successfully!"

# Try to SSH once VM is ready
max_retries=10
wait_time=15 #seconds
set +e
for ((retry_count=1; retry_count<=max_retries; retry_count++)); do
    echo -ne "Attempting to SSH... ($retry_count/$max_retries)                           \r"
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

# Wait for cloud-init to finish (TODO replace with checking for /opt/CTFd dir)
echo -e "\nWaiting for cloud-init to complete..."
ssh -T -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
    TOTAL_LINES=1678

    while ! grep -q 'Cloud-init.*finished' /var/log/cloud-init-output.log; do
        CURRENT_LINES=\$(wc -l < /var/log/cloud-init-output.log)
        PERCENTAGE=\$((CURRENT_LINES * 100 / TOTAL_LINES))
        echo -ne "Cloud-init progress: \$PERCENTAGE% (\$CURRENT_LINES / \$TOTAL_LINES) complete...\r"
        sleep 5
    done

    tail -n 1 /var/log/cloud-init-output.log
EOF
echo -e "\nCloud-init finished!"

# Wait until /opt/CTFd directory is available
# TODO

# Add CTFd Theme
echo "Adding CTFd theme..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sudo chown -R $SSH_USER:$SSH_USER /opt/CTFd/CTFd/themes/" # Give ubuntu user permissions to write to themes directory
#scp -i "$SSH_PRIVATE_KEY" -r CTFd/themes/uclcybersoc $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/
#scp -i "$SSH_PRIVATE_KEY" -r CTFd/themes/ucl-core $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/
scp -i "$SSH_PRIVATE_KEY" -r CTFd/themes/porticoHack $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/

# TODO make this an if statement checking if files already exist so it doesnt have to be commented manually
# Generate SSL certificate
#echo "Generating SSL certificate..."
#ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sudo chown -R $SSH_USER:$SSH_USER /etc/letsencrypt/"
#scp -i "$SSH_PRIVATE_KEY" secrets/cloudflare.ini $SSH_USER@$CTFD_IP:/etc/letsencrypt/cloudflare.ini
#ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
#    sudo mkdir -p /etc/letsencrypt
#    sudo mkdir -p /var/lib/letsencrypt

#    sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini -d $CTFD_SUBDOMAIN.$DOMAIN --email $EMAIL --agree-tos

#    sudo cp /etc/letsencrypt/live/$CTFD_SUBDOMAIN.$DOMAIN/fullchain.pem /opt/CTFd/conf/nginx/fullchain.pem
#    sudo cp /etc/letsencrypt/live/$CTFD_SUBDOMAIN.$DOMAIN/privkey.pem /opt/CTFd/conf/nginx/privkey.pem

    # Change permission to copy over to local machine
#    sudo chown -R $SSH_USER:$SSH_USER /opt/CTFd/conf/nginx/
#EOF
#scp -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP:/opt/CTFd/conf/nginx/privkey.pem secrets/privkey.pem
#scp -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP:/opt/CTFd/conf/nginx/fullchain.pem secrets/fullchain.pem

# Move SSL certificate to VM
echo "Copying certificate to VM..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sudo chown -R $SSH_USER:$SSH_USER /opt/CTFd/conf/nginx/"
scp -i "$SSH_PRIVATE_KEY" secrets/privkey.pem $SSH_USER@$CTFD_IP:/opt/CTFd/conf/nginx/privkey.pem 
scp -i "$SSH_PRIVATE_KEY" secrets/fullchain.pem $SSH_USER@$CTFD_IP:/opt/CTFd/conf/nginx/fullchain.pem

# Update http.conf
echo "Updating http.conf file..."
scp -i "$SSH_PRIVATE_KEY" CTFd/server_config/http.conf $SSH_USER@$CTFD_IP:/opt/CTFd/conf/nginx/http.conf

# Update docker-compose.yml
echo "Updating docker-compose.yml file..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "sudo chown -R $SSH_USER:$SSH_USER /opt/CTFd/"
scp -i "$SSH_PRIVATE_KEY" CTFd/server_config/docker-compose.yml $SSH_USER@$CTFD_IP:/opt/CTFd/docker-compose.yml

# SSH into the VM and deploy CTFd using Docker Compose
echo "Deploying CTFd with docker compose..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP <<EOF
    cd /opt/CTFd

    # generate secret key
    sudo sh -c "head -c 64 /dev/urandom > .ctfd_secret_key"

    # Start CTFd in detached mode
    sudo docker-compose up -d
EOF

echo "CTFd setup complete!"