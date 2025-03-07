# CTF Infrastructure

This repository contains a Capture The Flag (CTF) infrastructure that automates the setup, deployment, and management of CTF challenges using Terraform, Docker and Kubernetes.

# Table of Contents

- Overview
- File Structure
- Prerequisites
- Setup Instructions
- Terraform
- CTFd
- Challenges
- Scripts

# Overview

This CTF infrastructure allows users to:
- Provision cloud infrastructure on Google Cloud using Terraform
- Automatically install dependencies on the VM via Cloud-Init
- Deploy CTFd with Docker Compose
- Link CTFd to a domain and set up HTTPS
- Manage challenges in a structured directory format
- Store Docker images for challenges in a registry
- Deploy challenges to a Kubernetes cluster

# File Structure

```
ctf-infra/
│── terraform/                    # Infrastructure as Code (Terraform)
│   ├── ctfd/                     # Terraform setup for CTFd
│   │   ├── oracle/               # Oracle-specific Terraform configs
│   │   │   ├── main.tf           # Main Terraform configuration
│   │   │   ├── variables.tfvars  # User-configurable variables
│   │   │   ├── outputs.tf        # Terraform outputs
│   │   │   ├── cloud-init.yaml   # Initialization script for VM
│── challenges/                   # Directory for challenges
│   ├── 2025/                     # Challenges for CTF 2025
│   │   ├── example-challenge/    # Example challenge directory
│   │   │   ├── meta.yaml         # Challenge metadata
│   │   │   ├── challenge.yaml    # Kubernetes deployment file
│── scripts/                      # Management scripts
│   ├── start_ctfd.sh             # Deploys CTFd VM and setup
│   ├── end_ctfd.sh               # Destroys CTF infrastructure
│   ├── create_yaml.sh            # Generates challenge deployment files
│   ├── update_env.sh             # Updates `.env` with Terraform outputs
│── ctfd_theme/                   # Custom CTFd themes
│── .env                          # Configuration file
│── README.md                     # This documentation

```

# Prerequisites

- Terraform
- Docker
- SSH key pair for VM access
- Project on GCP
- Service account for running terraform and corresponding API key

# Setup

## Clone the Repository

```
git clone https://github.com/[TODO]
cd ctf-infra
```

## Set Up Project on GCP

Create a new GCP project and create a service account that will be used to run terraform. This service account should have the following permissions:

- Artifact Registry Administrator
- Compute Admin
- Kubernetes Engine Admin
- Project IAM Admin
- Service Account Admin
- Service Account Key Admin
- Service Account Token Creator
- Service Account User
- Storage Admin

Create a service account key and store it in ```secrets/your_key_name.json```.

## Set Up Cloudflare

Create a Cloudflare account and add your domain. For your domain, take a note of your zone ID and create an API token with the 'Zone.DNS' permission. Store this token in ```secrets/cloudflare.ini``` like this:

```
dns_cloudflare_api_token = your_token
```

## Configure Terraform Variables

You will need to set the following:

- GCP project ID
- path to your service account key
- path to the public key of the key pair you are using for SSH access
- cloudflare API token
- cloudflare zone ID

The other variables have default values that can be adjusted if needed. You can find them in the ```variables.tf``` file.

## Configure Environment Variables

You will need to set some environment variables yourself and others can be updated using the ```update_env.sh``` script after running terraform. The variables you have to set yourself are:

- SSH_USER: ssh user depends on VM image
- SSH_PRIVATE_KEY: path to ssh private key used to ssh into VM
- PROJECT_ID: GCP project name
- REGION: GCP region
- SA_TERRAFORM: name of service account used for terraform
- SA_TERRAFORM_KEY: path to key of terraform service account
- DOMAIN: domain to use for CTFd
- CTFD_SUBDOMAIN: subdomain to use for CTFd

## HTTPS

If you already have an SSL certificate, add ```fullchain.pem``` and ```privkey.pem``` to ```secrets/```.

# Terraform

CTFd and the Kubernetes cluster for challenge deployment are created separately.

## CTFd

### VM Information
- some info about VM used for CTFd
- specs, terraform variables

monitor cloud-init: 
```
ssh -i ~/.ssh/oracle_key ubuntu@[ip]
sudo tail -f /var/log/cloud-init-output.log

```

TODO

## Challenges

TODO

Kubernetes, Docker registry

# CTFd

## Theme
- explain compiling scss (and js?)
```
docker run --rm -v $(pwd):/mnt -w /mnt node:18 bash -c "npm install -g sass && sass --style=compressed CTFd/themes/porticoHack/assets/css/main.scss CTFd/themes/porticoHack/static/css/main.min.css"
```
```
docker run --rm -v $(pwd):/mnt -w /mnt node:18 bash -c "npm install -g sass && sass --style=compressed CTFd/themes/porticoHack/assets/css/challenge-board.scss CTFd/themes/porticoHack/static/css/challenge-board.min.css"
```
- explain update script

## Pages
- explain pages

## Server configuration

TODO

# Challenges

## Challenge Directory Structure
- explain how files are organized
- explain required files
- explain what each file is for
- explain how configuration works

# Scripts

## start_ctfd

## end_ctfd

## update_env

## push_to_registry

## create_yaml

## deploy_challenge

## update_theme

# Resources

