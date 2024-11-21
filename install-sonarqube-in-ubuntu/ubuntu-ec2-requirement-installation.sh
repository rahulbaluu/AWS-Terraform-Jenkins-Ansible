#!/bin/bash
# Update the system
sudo apt update -y && sudo apt upgrade -y

# Java installation
wget -O- https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto.gpg
echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list
sudo apt update
sudo apt install -y java-17-amazon-corretto-jdk

# Git installation
sudo apt install -y git

# Install required packages for SonarQube
sudo apt install -y wget unzip

# Create a user for SonarQube (if it doesn't exist)
if ! id "sonar" &>/dev/null; then
    sudo useradd -m -d /opt/sonarqube sonar
fi

# Download and install SonarQube
SONARQUBE_VERSION="9.9.0.65466"
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
sudo unzip sonarqube-${SONARQUBE_VERSION}.zip -d /opt

# Remove any existing SonarQube directory and move the extracted directory
sudo mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube

# Set proper permissions for SonarQube directory
sudo chown -R sonar:sonar /opt/sonarqube

sudo apt install -y openjdk-17-jdk-headless

# Switch to the sonar user and start SonarQube
sudo su - sonar -c "/opt/sonarqube/sonarqube-${SONARQUBE_VERSION}/bin/linux-x86-64/sonar.sh start"

# Output SonarQube status (as sonar user)
sudo su - sonar -c "/opt/sonarqube/sonarqube-${SONARQUBE_VERSION}/bin/linux-x86-64/sonar.sh status"

# Clean up downloaded files
rm -f sonarqube-${SONARQUBE_VERSION}.zip


# Output SonarQube status
echo "SonarQube is now running."
