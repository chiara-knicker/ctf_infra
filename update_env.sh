#!/bin/bash

# Exit on any error
set -e

# Run Terraform output and store values
cd terraform/ctfd/oracle
CTFD_IP=$(terraform output -raw ctfd_instance_ip)

cd ../../challenges
ACCESS_TOKEN=$(terraform output -raw access_token)
CLUSTER_IP=$(terraform output -raw challenges_cluster_endpoint)
CA_CERT=$(terraform output -raw cluster_ca_cert)

cd ../..

# Store the CA Certificate in a file
CA_CERT_PATH="auth/gke-ca.crt"
echo $CA_CERT | base64 --decode > $CA_CERT_PATH

# Update .env file
ENV_FILE=".env"

# Ensure .env file exists
touch $ENV_FILE

# Function to update or add a key-value pair in .env
update_env() {
    local key=$1
    local value=$2
    if grep -q "^$key=" "$ENV_FILE"; then
        sed -i "s|^$key=.*|$key=$value|" "$ENV_FILE"
    else
        echo "$key=$value" >> "$ENV_FILE"
    fi
}

# Update required values
update_env "CTFD_IP" "$CTFD_IP"
update_env "ACCESS_TOKEN" "$ACCESS_TOKEN"
update_env "CLUSTER_IP" "$CLUSTER_IP"

echo "Updated .env file successfully!"
