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
- Automatically install dependencies on the VM 
- Deploy CTFd with Docker Compose
- Link CTFd to a domain and set up HTTPS
- Manage challenges in a structured directory format
- Store Docker images for challenges in a registry
- Deploy challenges to a Kubernetes cluster

# File Structure

```
ctf-infra/ 
│── challenges/                   
│   ├── 2025/                     
│   │   ├── category/             
│   │   │   ├── challenge-name/   
│   │   │   |    ├── meta.yaml      # Challenge metadata
│   │   │   |    ├── challenge.yaml # Kubernetes deployment file
│   │   │   |    ├── ...            # Challenge files
├── CTFd/
│   ├── pages/                    # HTML for custom pages for CTFd
│   ├── server_config/            # Files for CTFd network configs
│   │   ├── docker-compose.yml
│   │   ├── http.conf
│   ├── themes/                   # Custom CTFd themes
├── secrets/
│   ├── ...                       # Files with sensitive data used for authentication
│── terraform/                  
│   ├── ctfd/                     # Terraform setup for CTFd
│   │   ├── provider/                
│   │   │   ├── scripts/
│   │   │   |   ├── ctfd-init.sh # Initialization script for VM
│   │   │   ├── dns.tf            # DNS configuration
│   │   │   ├── main.tf           # Main Terraform configuration
│   │   │   ├── output.tf         # Terraform outputs
│   │   │   ├── provider.tf       # Provider configuration
│   │   │   ├── variables.tf      # Declaration of configurable variables
│   │   │   ├── variables.tfvars  # Values for variables
│   ├── challenges/               # Terraform setup for Kubernetes cluster  
│   │   │   ├── cluster.tf        # Cluster configuration
│   │   │   ├── output.tf    
│   │   │   ├── provider.tf       
│   │   │   ├── registry.tf       # Docker registry configuration
│   │   │   ├── variables.tf      
│   │   │   ├── variables.tfvars  
│── .env        
│── README.md           
├── start_ctfd.sh                 # Deploys CTFd VM and setup
├── end_ctfd.sh                   # Destroys CTFd infrastructure
├── create_yaml.sh                # Generates challenge deployment files
├── update_theme.sh               # Updates CTFd theme
├── update_env.sh                 # Updates `.env` with Terraform outputs
├── push_to_registry.sh           # Creates Docker image and pushes it to registry
├── deploy_challenge.sh           # Deploys challenge to Kubernetes cluster

```

# Prerequisites

- Terraform
- Docker
- SSH key pair for VM access

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

Create a Cloudflare account and add your domain. For your domain, take a note of your zone ID and create an API token with the 'Zone.DNS' permission. If you don't have an SSL certificate yet, store this token in ```secrets/cloudflare.ini``` like this:

```
dns_cloudflare_api_token = your_token
```

## Configure Variables

You will need to set the following in the variables.tfvars files and .env:

- GCP project ID
- project region (default is europe-west2)
- name of service account used for terraform (the one created earlier)
- path to terraform service account key
- path to the public and private key used for SSH access
- ssh user name (depends on VM image, default is ubuntu)
- domain to use for CTFd
- subdomain to use for CTFd
- cloudflare API token
- cloudflare zone ID

Some terraform variables have default values that can be adjusted if needed. You can find them in the ```variables.tf``` file. Some variables in .env are updated using the ```update_env.sh``` script after running terraform.

## HTTPS

If you already have an SSL certificate, add ```fullchain.pem``` and ```privkey.pem``` to ```secrets/```.

## Start CTFd

To start CTFd, run the ```start_ctfd.sh``` script (make sure to uncomment the SSL certificate creation part if you do not have a certificate already).

**Note: This script may take a few minutes.**

If any changes are made to the theme, you can run the ```update_theme.sh``` script to update it.

To destroy the infrastructure, run the ```end_ctfd.sh``` script.

## Create Kubernetes Cluster

Navigate to the ```terraform/challenges/``` directory and run

```
terraform init
terraform apply -var-file="variables.tfvars"
```

**Note: This may take a while!**

Once the cluster is created, run the ```update_env.sh``` script.

You can get the node details with this command:

```
kubectl # TODO
```

TODO: example output, show which IPs are the external ones to connect to

## Deploying Challenges

Each challenge needs to be deployed individually. 

If the challenge does not have a ```challenge.yaml``` file yet, run the ```create_yaml.sh``` script. Make sure that the ```meta.yaml``` file contains all the required data.

Next, run the ```push_to_registry.sh``` script.

Finally, run the ```deploy_challenge.sh``` script.

**Note: The access token used when setting kubectl credentials is only valid for 1h. Once it expires, rerun terraform (this will not recreate any other resources) and rerun the ```update_env.sh``` script.**

You can check deployment with these commands:

```
kubectl # TODO
```

TODO: example output

# Terraform

CTFd and the Kubernetes cluster for challenge deployment are provisioned separately.

## CTFd

TODO: VM

## Challenges

TODO: Kubernetes cluster, Docker registry

# CTFd

## Theme

The theme files are based on the default core theme.

The main files to edit for style changes are ```assets/css/challenge-board.scss``` and ```assets/css/main.scss```. General style settings are in main and challenge board specific ones in challenge-board. These need to be compiled, which can be done with sass using docker:

```
docker run --rm -v $(pwd):/mnt -w /mnt node:18 bash -c "npm install -g sass && sass --style=compressed CTFd/themes/porticoHack/assets/css/main.scss CTFd/themes/porticoHack/static/css/main.min.css"
```
```
docker run --rm -v $(pwd):/mnt -w /mnt node:18 bash -c "npm install -g sass && sass --style=compressed CTFd/themes/porticoHack/assets/css/challenge-board.scss CTFd/themes/porticoHack/static/css/challenge-board.min.css"
```

This will create compiled files and store them in the correct directory.

Images are stored in ```static/img```. These can be used in the HTML source of CTFd pages.

## Pages

Pages can be added on the CTFd website. This directory contains the HTML source for the index and rules pages.

## Server configuration

To set up HTTPS, the CTFd default ```docker-compose.yml``` and ```http.conf``` files need to be changed.

```docker-compose.yml```: nginx block is changed to specify the paths to the SSL certificates and the ports to use

```http.conf```: changed to redirect HTTP traffic to HTTPS.

The ```start_ctfd.sh``` script automatically replaces the default files on the VM with the modified ones.

# Challenges

Every challenge has its own directory. The name of this directory is the challenge name and can only contain lowercase alphanumerical characters and '-' and '.' because it will be used to name the docker image.

Every challenge should include these files:
- ```meta.yaml```: useful metadata, both for documentation and for adding the challenge ot CTFd
- ```README.md```: challenge writeup
- challenge files, organised in directories

Additionally, these files are needed for hosted challenges:
- ```challenge.yaml```: Kubernetes deployment file (this file can be created automatically using the ```create_yaml.sh``` script)
- ```Dockerfile```: to create the Docker image

```meta.yaml``` has to include extra data for hosted challenges:
- 'replicas': number of instances of the challenge
- 'containerPort': port exposed by Docker container as specified in Dockerfile
- 'nodePort': port to expose on each node on the cluster (make sure it is within a valid range and the firewall allows traffic through it)

# Scripts

- ```start_ctfd.sh```: Sets up the entire CTFd infrastructure. After it runs, CTFd will be available at the specified domain.
- ```end_ctfd.sh```: Destroys the entire CTFd infrastructure.
- ```update_theme.sh```: Updates the CTFd theme.
- ```update_env.sh```: Updates the .env file and secrets with cluster data needed for challenge deployment.
- ```push_to_registry.sh```: Builds Docker image for a challenge and pushes it to the registry.
- ```create_yaml.sh```: Creates the Kubernetes deployment file for a challenge.
- ```deploy_challenge.sh```: Deploys a challenge to the Kubernetes cluster.

# Resources

General: <br>
- https://ctf101.org/intro/how-to-run-a-ctf/
- https://github.com/pwning/docs/blob/master/suggestions-for-running-a-ctf.markdown

CTFd: <br>
- https://docs.ctfd.io/
- https://github.com/CTFd/themes

HTTPS for CTFd: <br>
- [https://dev.to/roeeyn/how-to-setup-your-ctfd-platform-with-https-and-ssl-3fda](https://dev.to/roeeyn/how-to-setup-your-ctfd-platform-with-https-and-ssl-3fda)
- tried, but didnt work: https://medium.com/csictf/self-hosting-a-ctf-platform-ctfd-90f3f1611587

Terraform: <br>
- https://medium.com/bluetuple-ai/terraform-remote-state-on-gcp-d50e2f69b967
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
- https://howtodevez.medium.com/using-terraform-to-deploy-a-docker-image-on-google-kubernetes-engine-fe1ccf5e3671

Kubernetes: <br>
- https://medium.com/csictf/using-kubernetes-haproxy-to-host-scalable-ctf-challenges-a4720b6a9bbc
- https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
- https://registry.terraform.io/providers/hashicorp/google-beta/6.29.0/docs/guides/using_gke_with_terraform

Inspiration from other CTFs: <br>
- https://medium.com/csictf/structuring-your-repository-for-ctf-challenges-9351fd47b09a
- https://github.com/csivitu/ctf-challenges/tree/master
- https://medium.com/csictf/ctfup-66867f38b8a3
- https://github.com/hur/ctfd-gcp/tree/master
- https://github.com/DownUnderCTF/ctfd-kubectf-plugin/tree/develop
- https://github.com/DownUnderCTF/kube-ctf/tree/develop
- https://github.com/DownUnderCTF/ctfd-appengine

Challenge deployment: <br>
- https://github.com/Eadom/ctf_xinetd/tree/master
- https://github.com/redpwn/jail/tree/main
- https://medium.com/csictf/automate-deployment-using-ci-cd-eeadd3d47ca7
- https://google.github.io/kctf/

# Notes

- the number of nodes will be 3 * node_count because there are 3 zones, so it's node_count per zone
- might have to request quota increase for GCP project to use more CPUs (determine number of nodes and machine type, then check how many CPUs are needed, remember to include CPUs used by CTFd VM)
