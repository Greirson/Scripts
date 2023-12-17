#!/bin/bash

# Run this as root on any debian babsed server to install glances
# bash -c "$(wget -qO- https://raw.githubusercontent.com/Greirson/Scripts/main/install_glances.sh)"

# Update package list
sudo apt update

# Install dependencies
sudo apt install -y python3-dev python3-pip gcc libatlas-base-dev

# Install Glances
pip3 install --user glances

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
mkdir -p ~/.config/glances

# Create Glances configuration file with provided credentials
echo "username=$glances_username" > ~/.config/glances/glances.conf
echo "password=$(echo -n $glances_password | sha256sum | awk '{print $1}')" >> ~/.config/glances/glances.conf

# Set proper permissions for the configuration file
chmod 600 ~/.config/glances/glances.conf

# Create a systemd service file for Glances
cat <<EOL > ~/.config/systemd/user/glances.service
[Unit]
Description=Glances System Monitor

[Service]
ExecStart=$HOME/.local/bin/glances -w --config $HOME/.config/glances/glances.conf
Restart=always

[Install]
WantedBy=default.target
EOL

# Reload user systemd configuration
systemctl --user daemon-reload

# Enable and start Glances service
systemctl --user enable glances.service
systemctl --user start glances.service

# Display password in yellow text
echo -e "\e[1;33mYour Glances web interface password: $glances_password\e[0m"
