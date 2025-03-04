#!/bin/bash

set -e

# Check if .env file exists
if [ -e ".env" ]; then
    echo ".env exists."
else
    echo ".env does not exist."
    exit 1
fi

# Run Terraform output and store values
echo "Getting values from terraform output..."
cd terraform/ctfd/oracle
CTFD_IP=$(terraform output -raw ctfd_instance_ip)
cd ../../challenges
ACCESS_TOKEN=$(terraform output -raw k8s_deployer_access_token)
CLUSTER_IP=$(terraform output -raw ctf_cluster_endpoint)
CA_CERT=$(terraform output -raw cluster_ca_cert)
SA_K8_DEPLOYER_KEY=$(terraform output -raw k8s_deployer_key)

# Check if token is expired
echo "Checking if access token is expired..."
TOKEN_EXPIRY=$(curl -s https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$ACCESS_TOKEN | jq -r '.expires_in')

if [[ "$TOKEN_EXPIRY" == "null" || "$TOKEN_EXPIRY" -le 0 ]]; then
    echo "Access token is expired. Refreshing..."
    terraform apply -refresh-only -auto-approve > /dev/null
    ACCESS_TOKEN=$(terraform output -raw k8s_deployer_access_token)
else
    echo "Access token is still valid ($TOKEN_EXPIRY seconds remaining)."
fi

cd ../..

# Store the CA Certificate in a file
echo "Storing CA certificate..."
CA_CERT_PATH="auth/gke-ca.crt"
echo $CA_CERT | base64 --decode > $CA_CERT_PATH

# Store json key in a file
echo "Storing k8s_deployer json key..."
KEY_PATH="auth/sa_k8s_deployer_key.json"
echo $SA_K8_DEPLOYER_KEY | base64 --decode > $KEY_PATH

# Function to update or add a key-value pair in .env
update_env() {
    local key=$1
    local value=$2
    if grep -q "^$key=" ".env"; then
        sed -i "s|^$key=.*|$key=$value|" ".env"
    else
        echo "$key=$value" >> ".env"
    fi
}

# Update required values
echo "Updating .env file..."
update_env "CTFD_IP" "$CTFD_IP"
update_env "ACCESS_TOKEN" "$ACCESS_TOKEN"
update_env "CLUSTER_IP" "$CLUSTER_IP"

echo "Updated .env file successfully!"