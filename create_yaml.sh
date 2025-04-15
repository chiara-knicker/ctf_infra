#!/bin/bash

set -e

# Check if challenge name is provided
if [ -z "$1" ]; then
  echo "Usage: create_yaml [challenge-name]"
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
if [ ! -d $CHALLENGES_DIR ]; then
    echo "Error: Challenge directory $CHALLENGES_DIR does not exist!"
    exit 1
fi

CHALLENGE_NAME=$1
CHALLENGE_DIR=$(find "$CHALLENGES_DIR" -type d -name "$CHALLENGE_NAME" -print -quit)

# Check if the challenge directory was found
if [ -n $CHALLENGE_DIR ]; then
  echo "Directory '$CHALLENGE_NAME' found: $CHALLENGE_DIR"
else
  echo "Directory '$CHALLENGE_NAME' not found inside '$CHALLENGES_DIR'."
  exit 1
fi

# Check if meta.yaml exists
META_FILE="$CHALLENGE_DIR/meta.yaml"
if [ ! -e $META_FILE ]; then
    echo "Error: Challenge directory does not have a meta.yaml file!"
    exit 1
fi

# Check if challenge.yaml exists already
YAML_FILE="$CHALLENGE_DIR/challenge.yaml"
if [ -e $YAML_FILE ]; then
    echo "Error: challenge.yaml already exists!"
    exit 1
fi

# Extract values from meta.yaml
echo "Getting values from meta.yaml..."
CATEGORY=$(grep "category:" "$META_FILE" | awk '{print $2}')
REPLICAS=$(grep "replicas:" "$META_FILE" | awk '{print $2}')
CONTAINER_PORT=$(grep "containerPort:" "$META_FILE" | awk '{print $2}')
NODE_PORT=$(grep "nodePort:" "$META_FILE" | awk '{print $2}')

REGISTRY_URL="$REGION-docker.pkg.dev/$PROJECT_ID/ctf-docker-registry"

# Check if values were found
if [ -z "$CATEGORY" ] || [ -z "$CONTAINER_PORT" ] || [ -z "$NODE_PORT" ] || [ -z "$REPLICAS" ]; then
    echo "Error: One or more required values (category, containerPort, nodePort, replicas) are missing from meta.yaml"
    exit 1
fi

touch $YAML_FILE

# Fill YAML_FILE with template challenge.yaml where placeholders are replaced with values
echo "Creating challenge.yaml..."
YAML_TEMPLATE="challenges/challenge.yaml.template"
sed -e "s|CHALLENGE_NAME|$CHALLENGE_NAME|g" \
    -e "s|CATEGORY|$CATEGORY|g" \
    -e "s|REPLICAS|$REPLICAS|g" \
    -e "s|CONTAINER_PORT|$CONTAINER_PORT|g" \
    -e "s|NODE_PORT|$NODE_PORT|g" \
    -e "s|REGISTRY_URL|$REGISTRY_URL|g" \
    "$YAML_TEMPLATE" > "$YAML_FILE"

echo "challenge.yaml file created successfully."