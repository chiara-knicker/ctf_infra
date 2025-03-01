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

PROVIDER=$2

# Check if theme provider name is provided
if [ -z "$PROVIDER" ]; then
  echo "Using default provider: oracle."
  PROVIDER="oracle"
fi

theme=$1

# Check if theme name is provided
if [ -z "$theme" ]; then
  echo "Please provide the theme name."
  exit 1
fi

# Check if the theme directory exists
if [ -d "ctfd_theme/$theme" ]; then
  echo "Directory '$theme' exists inside 'ctfd_theme'."
else
  echo "Directory '$theme' does not exist inside 'ctfd_theme'."
  exit 1
fi

echo "Updating CTFd theme $theme ..."

# copy the theme folder to the VM
echo "copying files"
#scp -i "$SSH_PRIVATE_KEY" -r ctfd_theme/$theme $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/
# Only modified files are replaced
RSYNC_OUTPUT=$(rsync -az --delete --itemize-changes -e "ssh -i $SSH_PRIVATE_KEY" ctfd_theme/$theme/ $SSH_USER@$CTFD_IP:/opt/CTFd/CTFd/themes/$theme/)

# If rsync reports no changes (no output) and exit code is 0, exit the script
if [ -z "$RSYNC_OUTPUT" ]; then
  echo "No changes detected. Exiting script."
  exit 0
fi

# If there were changes, print them and restart CTFd
echo "Changes detected: "
echo "$RSYNC_OUTPUT"

# Restart CTFd services to apply the new theme
echo "restart docker"
ssh -i "$SSH_PRIVATE_KEY" $SSH_USER@$CTFD_IP "cd /opt/CTFd && sudo docker-compose restart"

echo "CTFd theme updated and service restarted successfully!"
