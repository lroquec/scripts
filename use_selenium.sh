#!/bin/bash

# Verificar si el contenedor 'selenium' está corriendo y eliminarlo si es necesario
docker ps -a -q --filter "name=selenium" | grep -q . && docker stop selenium && docker rm selenium || true

# Correr el contenedor de Selenium
docker run --rm -d --name selenium --network test-network -p 4444:4444 selenium/standalone-chrome:latest