#!/bin/bash

# Exit immediately if any command fails
set -e

# Check if challenge name is provided
if [ -z "$1" ]; then
  echo "Usage: deploy_challenge [challenge-name]"
  exit 1
fi

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

# Set CTF Year
CHALLENGES_DIR="challenges/$CTF_YEAR"

# Check if the challenges directory exists
if [ ! -d "$CHALLENGES_DIR" ]; then
    echo "Error: Challenge directory $CHALLENGES_DIR does not exist!"
    exit 1
fi

CHALLENGE_NAME=$1
CHALLENGE_DIR=$(find "$CHALLENGES_DIR" -type d -name "$CHALLENGE_NAME" -print -quit)

# Check if the challenge directory was found
if [ -n "$CHALLENGE_DIR" ]; then
  echo "Directory '$CHALLENGE_NAME' found: $CHALLENGE_DIR"
else
  echo "Directory '$CHALLENGE_NAME' not found inside '$CHALLENGES_DIR'."
  exit 1
fi

# Authenticate with Google Kubernetes Engine
echo "Authenticating with GKE..."

# gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION --project=$PROJECT_ID

cluster_name=ctf-challenges-cluster
kubectl config set-cluster $cluster_name \
  --server=https://$CLUSTER_IP \
  --certificate-authority=$CLUSTER_CA_CERT 

curl -s https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$ACCESS_TOKEN | jq

#test="ya29.a0AeXRPp78rB6JNN_62V4MlHQo3usi8GeLojnO2iSJuIlxPPRzcp3Qr418yOJifLTWNnuzMSVjVTO0MYDB-kEp3BMZ6aKzbKrUYljBwGVL0B1sfdGbqElR0SDBhJpjwACu09gLbkL1zrjPHZx-zuORsQwuMHf9R1aa0bN0DeHM5HeKshvi-uz24pNoSW7EKToPgbF8A8ezTaCP-J4h7dBnYMSu4jkFLtct3C2GM-9XDXr-1FUDLXT5BKXI_Wy5WmnPva0gQ09MFXwiwW3S3QvMmd3vCLWC_sgF8ga0BcKyY1a_kP3h2CuORkxor3wwJ4DmbglgFzQI6dGRl0SKukdMsoycIJKLjl7K_h1lS4HAen2weaPD2x7LXk87UnksnBy6Jw5S8-Bgo8HJtNF9OKpqK5aPV36G_QKeElfgaCgYKAYUSARISFQHGX2MiPCCJA5xasg7smQS9hbww3w0427"
#curl -s https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$test | jq

kubectl config set-credentials $SA_TERRAFORM \
  --token=$ACCESS_TOKEN

kubectl config set-context $cluster_name \
  --cluster=$cluster_name \
  --user=$SA_TERRAFORM

kubectl config use-context $cluster_name
kubectl get nodes -o wide

# Deploy to Kubernetes
echo "Deploying challenge '$CHALLENGE_NAME' to Kubernetes..."

# Check if the secret already exists
secret_name="artifact-registry-secret"
kubectl get secret $secret_name &>/dev/null

if [ $? -eq 0 ]; then
  echo "Secret '$secret_name' already exists. Skipping creation."
else
  # Secret does not exist, so create it
  echo "Secret '$secret_name' does not exist. Creating it now..."
  kubectl create secret docker-registry $secret_name \
    --docker-server=$REGION-docker.pkg.dev \
    --docker-username=_json_key \
    --docker-password="$(cat $SA_TERRAFORM_KEY)" 
fi

kubectl apply -f "$CHALLENGE_DIR/challenge.yaml"
#kubectl delete -f "$CHALLENGE_DIR/challenge.yaml"

echo "Challenge '$CHALLENGE_NAME' deployed successfully!"