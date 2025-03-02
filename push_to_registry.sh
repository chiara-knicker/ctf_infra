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

# Check if required environment variables are set
if [ -z "$CTF_YEAR" ]; then
    echo "Error: CTF_YEAR is not defined in .env"
    exit 1
fi

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

# Docker registry and GCP project info
DOCKER_REGISTRY_URL="$REGION-docker.pkg.dev/$PROJECT_ID/ctf-docker-registry"
DOCKER_IMAGE="$DOCKER_REGISTRY_URL/$CHALLENGE_NAME:latest"

# Build Docker image for the challenge
echo "Building Docker image for challenge '$CHALLENGE_NAME'..."
docker build -t $DOCKER_IMAGE $CHALLENGE_DIR

# Authenticate with Google Artifact Registry
echo "Authenticating Docker with Google Artifact Registry..."
#gcloud auth configure-docker $DOCKER_REGISTRY_URL
cat $SA_TERRAFORM_KEY | docker login -u _json_key --password-stdin https://$(echo $DOCKER_REGISTRY_URL | cut -d'/' -f1)

# Push the Docker image to Google Artifact Registry
echo "Pushing Docker image to Google Artifact Registry..."
docker push $DOCKER_IMAGE

echo "Docker image pushed to registry successfully."