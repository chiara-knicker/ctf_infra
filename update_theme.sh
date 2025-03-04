#!/bin/bash

set -e

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
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

THEME=$1

# Check if theme name is provided
if [ -z "$THEME" ]; then
  echo "Usage: update_theme [theme-name] [provider]"
  exit 1
fi

PROVIDER=$2

# Check if cloud provider is provided
if [ -z "$PROVIDER" ]; then
  echo "Using default provider: oracle."
  PROVIDER="oracle"
fi

# Check if the theme directory exists
if [ -d "CTFd/themes/$THEME" ]; then
  echo "Directory '$THEME' exists inside 'CTFd/themes'."
else
  echo "Directory '$THEME' does not exist inside 'CTFd/themes'."
  exit 1
fi

echo "Updating CTFd theme $THEME..."

# Copy the theme folder to the VM
echo "Copying files..."
#scp -i "$SSH_PRIVATE_KEY" -r CTFd/themes/$theme $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/
# Only modified files are replaced
RSYNC_OUTPUT=$(rsync -az --delete --itemize-changes -e "ssh -i $SSH_PRIVATE_KEY" CTFd/themes/$THEME/ $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/$THEME/)

# If rsync reports no changes (no output) and exit code is 0, exit the script
if [ -z "$RSYNC_OUTPUT" ]; then
  echo "No changes detected. Exiting script."
  exit 0
fi

# If there were changes, print them and restart CTFd
echo "Changes detected: "
echo "$RSYNC_OUTPUT"

# Restart CTFd services to apply the new theme
echo "Restarting docker..."
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "cd /opt/CTFd && sudo docker-compose restart"

echo "CTFd theme updated and service restarted successfully!"
