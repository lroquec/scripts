#!/bin/bash

# Actualiza los paquetes del sistema
sudo yum update -y

# Instala las dependencias necesarias
sudo yum install -y yum-utils

# Agrega el repositorio oficial de HashiCorp
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Instala Vault
sudo yum install -y vault

# Verifica la instalación
vault --version

# Crea un usuario para ejecutar Vault
sudo useradd --system --home /etc/vault.d --shell /bin/false vault

# Configura permisos en el directorio de configuración
sudo mkdir -p /etc/vault.d
sudo chown -R vault:vault /etc/vault.d
sudo chmod 750 /etc/vault.d

# Configuración del almacenamiento local (puedes adaptarlo según tu entorno)
sudo tee /etc/vault.d/vault.hcl > /dev/null <<EOF
storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

ui = true
EOF

# Crea el directorio para el almacenamiento
sudo mkdir -p /opt/vault/data
sudo chown -R vault:vault /opt/vault/data
sudo chmod 750 /opt/vault/data

# Crea un archivo de configuración para systemd
sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description=HashiCorp Vault - A tool for managing secrets
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Recarga systemd para que reconozca el nuevo servicio
sudo systemctl daemon-reload

# Inicia el servicio Vault
sudo systemctl start vault

# Habilita el servicio para que se inicie en el arranque
sudo systemctl enable vault

# Verifica que el servicio está corriendo
sudo systemctl status vault

### Aditional steps ###
# echo "export VAULT_ADDR='http://127.0.0.1:8200'" >> ~/.bashrc
# source ~/.bashrc
# vault operator init
# vault operator unseal