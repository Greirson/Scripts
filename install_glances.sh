#!/bin/bash

# Update package list
sudo apt update

# Install dependencies
sudo apt install -y python3-dev python3-pip gcc libatlas-base-dev

# Install Glances
sudo pip3 install glances

# Set default username
default_username="homeassistant"

# Prompt user for Glances web interface username
read -p "Do you want to use the default username '$default_username'? (y/n): " use_default_username

if [ "$use_default_username" = "y" ]; then
    glances_username=$default_username
else
    read -p "Enter a username for Glances: " glances_username
fi

# Prompt user for Glances web interface password
read -s -p "Enter a password for Glances: " glances_password
echo

# Create Glances configuration directory
sudo mkdir -p /etc/glances

# Create Glances configuration file with provided credentials
echo "username=$glances_username" | sudo tee /etc/glances/glances.conf > /dev/null
echo "password=$(echo -n $glances_password | sha256sum | awk '{print $1}')" | sudo tee -a /etc/glances/glances.conf > /dev/null

# Set proper permissions for the configuration file
sudo chmod 600 /etc/glances/glances.conf

# Create a systemd service file for Glances
cat <<EOL | sudo tee /etc/systemd/system/glances.service > /dev/null
[Unit]
Description=Glances System Monitor

[Service]
ExecStart=/usr/local/bin/glances -w --config /etc/glances/glances.conf
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd configuration
sudo systemctl daemon-reload

# Enable and start Glances service
sudo systemctl enable glances.service
sudo systemctl start glances.service

# Display password in yellow text
echo -e "\e[1;33mYour Glances web interface password: $glances_password\e[0m"
