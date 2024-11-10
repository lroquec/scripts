#!/bin/bash

# Check for updates https://github.com/aquasecurity/trivy

# Get the package
wget https://github.com/aquasecurity/trivy/releases/download/v0.57.0/trivy_0.57.0_Linux-64bit.deb

# Install the package
sudo dpkg -i trivy_0.57.0_Linux-64bit.deb

# Scan the image
trivy image --severity CRITICAL --exit-code 0 --format sarif --output trivy-report.sarif lroquec/$app_name:latest