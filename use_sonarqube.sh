#!/bin/bash

#Check for updates https://hub.docker.com/_/sonarqube/tags

# Best use docker 
docker run -dit --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube:10.6-community