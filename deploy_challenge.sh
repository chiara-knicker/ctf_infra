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

# Set CTF Year
CHALLENGE_DIR="challenges/$CTF_YEAR"

# Check if the year directory exists
if [ ! -d "$CHALLENGE_DIR" ]; then
    echo "Error: Challenge directory $CHALLENGE_DIR does not exist!"
    exit 1
fi

challenge=$1

# Check if challenge name is provided
if [ -z "$challenge" ]; then
  echo "Please provide a challenge name."
  exit 1
fi

# Search for the directory inside the base directory recursively
found_dir=$(find "$CHALLENGE_DIR" -type d -name "$challenge" -print -quit)

# Check if the directory was found
if [ -n "$found_dir" ]; then
  echo "Directory '$challenge' found: $found_dir"
else
  echo "Directory '$challenge' not found inside '$CHALLENGE_DIR'."
  exit 1
fi

# TODO