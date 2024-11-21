#!/bin/bash
# Update the system
sudo yum update -y

# Java installation
sudo yum install java-17-amazon-corretto-headless -y

# Git installation
sudo yum install git -y

# Install required packages for SonarQube
sudo yum install -y wget unzip

# Create a user for SonarQube (if it doesn't exist)
if ! id "sonar" &>/dev/null; then
    sudo useradd sonar
fi

# Download and install SonarQube
SONARQUBE_VERSION="9.9.0.65466"
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
sudo unzip sonarqube-${SONARQUBE_VERSION}.zip -d /opt
sudo mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube

# Set proper permissions for SonarQube directory
sudo chown -R sonar:sonar /opt/sonarqube

# Switch to the sonar user and start SonarQube
sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh start"

# Output SonarQube status (as sonar user)
sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh status"

# Clean up downloaded files
rm -f sonarqube-${SONARQUBE_VERSION}.zip

# Output SonarQube initial status
echo "SonarQube is now running."