#!/bin/bash
# This script installs Jenkins on an Ubuntu server

# Update package lists
sudo apt-get update

# Install Java 11
sudo apt-get install -y openjdk-11-jdk

# Download Jenkins key and add it to system
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins to system package source list
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null'

# Update package lists again to include Jenkins and install it
sudo apt-get update
sudo apt-get install -y jenkins

# Verify Jenkins is installed and working
sudo systemctl status jenkins