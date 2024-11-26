## Still testing on AlmaLinux 9.5
#!/bin/bash

# Define the Wazuh version
WAZUH_VERSION="4.9"

# Define the Wazuh repository URL
WAZUH_REPO_URL="https://packages.wazuh.com/${WAZUH_VERSION}/yum/"

# Define the GPG key URL
GPG_KEY_URL="https://packages.wazuh.com/key/GPG-KEY-WAZUH"

# Install the Wazuh repository
echo -e "[wazuh]\ngpgcheck=1\ngpgkey=${GPG_KEY_URL}\nenabled=1\nname=EL-\$releasever - Wazuh\nbaseurl=${WAZUH_REPO_URL}\nprotect=1" | tee /etc/yum.repos.d/wazuh.repo

# Install the Wazuh server
yum install -y wazuh-manager wazuh-api

# Install the Wazuh indexer
yum install -y wazuh-indexer

# Install the Wazuh dashboard
yum install -y wazuh-dashboard

# Configure the Wazuh server
sed -i 's/# <wazuh_config>/&\nwazuh_config name="wazuh" node_name="wazuh-node" node_type="master" key="c98b62a9b6169ac5f67dae55ae4a9088" port="1516" bind_addr="0.0.0.0" nodes="127.0.0.1" hidden="no" disabled="no"/g' /var/ossec/etc/ossec.conf

# Configure the Wazuh indexer
sed -i 's/# <wazuh_config>/&\nwazuh_config name="wazuh" node_name="wazuh-node" node_type="master" key="c98b62a9b6169ac5f67dae55ae4a9088" port="1516" bind_addr="0.0.0.0" nodes="127.0.0.1" hidden="no" disabled="no"/g' /etc/wazuh-indexer/indexer.yml

# Start the Wazuh services
systemctl start wazuh-manager
systemctl start wazuh-api
systemctl start wazuh-indexer
systemctl start wazuh-dashboard

# Enable the Wazuh services to start at boot
systemctl enable wazuh-manager
systemctl enable wazuh-api
systemctl enable wazuh-indexer
systemctl enable wazuh-dashboard