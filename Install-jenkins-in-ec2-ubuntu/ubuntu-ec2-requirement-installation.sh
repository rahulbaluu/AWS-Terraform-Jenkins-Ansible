#!/bin/bash

# Exit on error
set -e

# Function to display messages
info() {
  echo -e "\n\e[1;34m[INFO] $1\e[0m"
}

error() {
  echo -e "\n\e[1;31m[ERROR] $1\e[0m" >&2
}

# Update system packages
info "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Java 17 required for Jenkins
info "Installing Java 17..."
sudo apt install -y openjdk-17-jdk
java --version || { error "Java installation failed"; exit 1; }

# Jenkins key and repository setup
info "Setting up Jenkins repository..."
sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
info "Installing Jenkins..."
sudo apt install -y jenkins

# Terraform installation
info "Installing Terraform..."
sudo apt-get install -y gnupg software-properties-common
wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform
terraform --version || { error "Terraform installation failed"; exit 1; }

# Ansible installation
info "Installing Ansible..."
sudo apt install -y python3-pip
sudo pip3 install ansible
ansible --version || { error "Ansible installation failed"; exit 1; }

# Git installation
info "Installing Git..."
sudo apt install -y git

# Enable, start, and check Jenkins service
info "Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager || { error "Jenkins service failed to start"; exit 1; }

# Maven installation
info "Installing Maven..."
sudo apt install -y wget
wget -q https://downloads.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
sudo tar -xvzf apache-maven-3.9.9-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.9 /opt/maven
echo 'export PATH=$PATH:/opt/maven/bin' | sudo tee -a /etc/profile
source /etc/profile
mvn -version || { error "Maven installation failed"; exit 1; }

# Show initial Jenkins admin password for setup
info "Displaying initial Jenkins admin password..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

info "Setup completed successfully!"
