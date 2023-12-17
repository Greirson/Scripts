#!/bin/bash

# Get the current machine's IP address
machine_ip=$(hostname -I | awk '{print $1}')

# Confirm the detected IP address
read -p "Detected IP address: $machine_ip. Is this correct? (y/n): " confirm_ip

if [ "$confirm_ip" != "y" ]; then
    # If incorrect, prompt for the correct IP address
    read -p "Enter the correct IP address of this machine: " machine_ip
fi

# Update package list
sudo apt update

# Install dependencies
sudo apt install -y python3-dev python3-pip gcc libatlas-base-dev

# Install Glances
sudo pip3 install glances

# Create a systemd service file for Glances
cat <<EOL | sudo tee /etc/systemd/system/glances.service > /dev/null
[Unit]
Description=Glances System Monitor

[Service]
ExecStart=/usr/local/bin/glances -w -t 1 --disable-webui
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

# Create /etc/glances if it doesn't exist
sudo mkdir -p /etc/glances

# Create /etc/glances/homeassistant.yaml if it doesn't exist
sudo touch /etc/glances/homeassistant.yaml

# Write code block to homeassistant.yaml file
echo -e "Add the following lines to your Home Assistant configuration.yaml file under 'sensors':\n" | sudo tee /etc/glances/homeassistant.yaml > /dev/null
echo -e "```yaml" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "  - platform: rest" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    name: Glances CPU Load" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    resource: http://$machine_ip:61208/api/2/cpu" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    value_template: '{{ value_json.load }}'" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    scan_interval: 10" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    unit_of_measurement: '%'" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "  - platform: rest" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    name: Glances Memory Usage" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    resource: http://$machine_ip:61208/api/2/mem" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    value_template: '{{ value_json.percent }}'" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    scan_interval: 10" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    unit_of_measurement: '%'" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "  - platform: rest" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    name: Glances Disk Free" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    resource: http://$machine_ip:61208/api/2/fs" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    value_template: '{{ value_json[\"/\"].free }}'" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    scan_interval: 10" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "    unit_of_measurement: 'GB'" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
echo -e "```" | sudo tee -a /etc/glances/homeassistant.yaml > /dev/null
