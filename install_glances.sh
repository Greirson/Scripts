#!/bin/bash

# Get the current machine's IP address
machine_ip=$(hostname -I | awk '{print $1}')

# Update package list
sudo apt update -y || { echo "Package update failed"; exit 1; }

# Install dependencies
sudo apt install -y python3-dev python3-pip gcc libatlas-base-dev || { echo "Dependency installation failed"; exit 1; }

# Install Glances
sudo pip3 install glances || { echo "Glances installation failed"; exit 1; }

# Create a systemd service file for Glances
cat <<EOL | sudo tee /etc/systemd/system/glances.service > /dev/null
[Unit]
Description=Glances System Monitor

[Service]
ExecStart=/usr/local/bin/glances -w
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

# Display machine's IP address
echo "Machine IP Address: $machine_ip"
