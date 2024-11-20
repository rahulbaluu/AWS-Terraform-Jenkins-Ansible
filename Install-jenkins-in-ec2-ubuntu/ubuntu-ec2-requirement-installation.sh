#!/bin/bash

# Exit on error
set -e

# Variables
MAVEN_VERSION="3.9.9"
SONARQUBE_VERSION="9.9.1.69595"

# Functions for messages
info() { echo -e "\n\e[1;34m[INFO] $1\e[0m"; }
error() { echo -e "\n\e[1;31m[ERROR] $1\e[0m" >&2; }

# Log output
exec > >(tee -i setup.log) 2>&1

# Update system packages
info "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Java 17 (required for SonarQube and Jenkins)
info "Installing Java 17..."
sudo apt install -y openjdk-17-jdk
java --version || { error "Java installation failed"; exit 1; }

# Install Jenkins
info "Setting up Jenkins repository..."
sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
info "Installing Jenkins..."
sudo apt install -y jenkins

# Install Terraform
info "Installing Terraform..."
sudo apt-get install -y gnupg software-properties-common
wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform
terraform --version || { error "Terraform installation failed"; exit 1; }

# Install Ansible
info "Installing Ansible..."
sudo apt install -y python3-pip
sudo pip3 install ansible
ansible --version || { error "Ansible installation failed"; exit 1; }

# Install Git
info "Installing Git..."
sudo apt install -y git

# Enable, start, and verify Jenkins
info "Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager || { error "Jenkins service failed to start"; exit 1; }

# Install Maven
info "Installing Maven version $MAVEN_VERSION..."
sudo apt install -y wget
wget -q https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo tar -xvzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven
echo 'export PATH=$PATH:/opt/maven/bin' | sudo tee -a /etc/profile
source /etc/profile
rm apache-maven-${MAVEN_VERSION}-bin.tar.gz
mvn -version || { error "Maven installation failed"; exit 1; }

# Install SonarQube
info "Installing SonarQube version $SONARQUBE_VERSION..."
sudo apt install -y unzip
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
sudo unzip sonarqube-${SONARQUBE_VERSION}.zip -d /opt
sudo mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube
sudo adduser --system --group --no-create-home sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube
sudo chmod -R 755 /opt/sonarqube

# Configure SonarQube as a service
info "Configuring SonarQube as a service..."
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOL
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=simple
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL

# Start and enable SonarQube
info "Enabling and starting SonarQube service..."
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube
sudo systemctl status sonarqube --no-pager || { error "SonarQube service failed to start"; exit 1; }

# Show Jenkins initial password
info "Displaying initial Jenkins admin password..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

info "Setup completed successfully!"
