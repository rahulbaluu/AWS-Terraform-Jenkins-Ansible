#!/bin/bash

# Exit on error
set -e

# Functions for messages
info() { echo -e "\n\e[1;34m[INFO] $1\e[0m"; }
error() { echo -e "\n\e[1;31m[ERROR] $1\e[0m" >&2; }


# Update system packages
info "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Java 17 (required for SonarQube and Jenkins)
info "Installing Java 17..."
sudo apt install -y openjdk-17-jdk
java -version || { error "Java installation failed"; exit 1; }

# Install Jenkins
info "Setting up Jenkins repository..."
sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
info "Installing Jenkins..."
sudo apt install -y jenkins

# Enable, start, and verify Jenkins
info "Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins || {
  error "Jenkins service failed to start. Check system logs with 'sudo journalctl -xe'."
  exit 1
}
sudo systemctl status jenkins --no-pager

# Install Terraform
info "Installing Terraform..."
sudo apt install -y gnupg software-properties-common
wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
terraform --version || { error "Terraform installation failed"; exit 1; }

# Install Git
info "Installing Git..."
sudo apt install -y git

#Install AWS CLI v2 on Ubuntu/Debian-based EC2 Instances
sudo apt update
sudo apt install unzip curl -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Kubectl installation
info "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/v1.27.4/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify kubectl installation
kubectl version --client || { error "kubectl installation failed"; exit 1; }

# Show Jenkins initial password
info "Displaying initial Jenkins admin password..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword