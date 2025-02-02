#!/bin/bash

export $(cat .env | xargs)

# Update system
apt update && apt upgrade -y

# Install Docker, nginx and Kubernetes components
apt install -y docker.io nginx kubeadm kubectl kubelet

# Enable Docker and Kubernetes to start on boot
systemctl enable --now docker
systemctl enable --now kubelet

# Allow Kubernetes to use system ports
ufw allow 6443/tcp  # Kubernetes API port
ufw allow 10250/tcp # Kubelet port
ufw allow 2379/tcp  # etcd port

# Initialize Kubernetes (adjust for your specific cluster setup)
kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup kubeconfig for kubectl access
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config