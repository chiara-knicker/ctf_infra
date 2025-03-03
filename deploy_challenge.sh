#!/bin/bash

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

CHALLENGES_DIR="challenges"

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

echo "Access token info:"
curl -s https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$ACCESS_TOKEN | jq

kubectl config set-credentials k8s_deployer \
  --token=$ACCESS_TOKEN

kubectl config set-context $cluster_name \
  --cluster=$cluster_name \
  --user=k8s_deployer

kubectl config use-context $cluster_name

echo "Cluster nodes:"
kubectl get nodes -o wide

# Check if secret for authenticating with registry already exists
secret_name="artifact-registry-secret"
set +e
kubectl get secret $secret_name 
if [ $? -eq 0 ]; then
  echo "Secret '$secret_name' already exists. Skipping creation."
else
  # Secret does not exist, so create it
  echo "Secret '$secret_name' does not exist. Creating it now..."
  kubectl create secret docker-registry $secret_name \
    --docker-server=$REGION-docker.pkg.dev \
    --docker-username=_json_key \
    --docker-password="$(cat $SA_K8S_DEPLOYER_KEY)" 
fi
set -e

# Deploy to Kubernetes
echo "Deploying challenge '$CHALLENGE_NAME' to Kubernetes..."
kubectl apply -f "$CHALLENGE_DIR/challenge.yaml"
#kubectl delete -f "$CHALLENGE_DIR/challenge.yaml"

echo "Challenge '$CHALLENGE_NAME' deployed successfully!"