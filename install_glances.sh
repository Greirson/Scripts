#!/bin/bash

# Get the current machine's IP address
machine_ip=$(hostname -I | awk '{print $1}')

# Update package list
wget -O- https://bit.ly/glances | /bin/bash

# Create a systemd service file for Glances
cat <<EOL | sudo tee /etc/systemd/system/glances.service > /dev/null
[Unit]
Description=Glances
After=network.target

[Service]
ExecStart=/usr/local/bin/glances -w
Restart=on-abort
RemainAfterExit=yes

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

# Find the port on which Glances is running (default is 61208)
glances_port=$(ps aux | grep '[g]lances -w' | awk '{print $NF}' | sed 's/.*://')

# Display the link to Glances web UI
echo "Glances Web UI: http://$machine_ip:$glances_port"
