#!/bin/bash

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Java 17 required for Jenkins
sudo apt install openjdk-17-jdk -y
sudo java --version

# Jenkins key and repository setup
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

# Upgrade system packages
sudo apt upgrade -y

# Terraform installation
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install terraform -y
sudo terraform --version

# Ansible installation
sudo apt install -y python3-pip
sudo pip3 install ansible
sudo ansible --version

# Git installation
sudo apt install git -y

# Enable, start and status Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Maven installation
sudo yum install -y wget
wget https://downloads.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
sudo tar -xvzf apache-maven-3.9.9-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.9 /opt/maven
echo 'export PATH=$PATH:/opt/maven/bin' | sudo tee -a /etc/profile
source /etc/profile

# Verify Maven installation
mvn -version

# Show initial Jenkins admin password for setup
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

#sudo systemctl status jenkins  /The code can't stop execution once exececuted 
