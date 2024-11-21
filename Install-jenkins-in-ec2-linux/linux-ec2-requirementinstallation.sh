#!/bin/bash
# Update the system
sudo yum update -y

# Jenkins repository setup
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y

# Java installation
sudo yum install java-17-amazon-corretto-headless -y

# Git installation
sudo yum install git -y

# Terraform installation
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
sudo terraform -version

# Ansible installation
sudo yum update -y
sudo amazon-linux-extras install ansible2 -y

# Maven installation
sudo yum install -y wget
wget https://downloads.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
sudo tar -xvzf apache-maven-3.9.9-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.9 /opt/maven
echo 'export PATH=$PATH:/opt/maven/bin' | sudo tee -a /etc/profile
source /etc/profile

# Verify Maven installation
mvn -version

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

# Jenkins installation
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Output Jenkins initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword