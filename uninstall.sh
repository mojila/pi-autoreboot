#!/bin/bash

# Pi Auto-Reboot Uninstallation Script
# This script removes the pi-autoreboot service from Linux systems

set -e

echo "Pi Auto-Reboot Uninstallation Script"
echo "====================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Stop and disable the service
echo "Stopping and disabling pi-autoreboot service..."
sudo systemctl stop pi-autoreboot 2>/dev/null || echo "Service was not running"
sudo systemctl disable pi-autoreboot 2>/dev/null || echo "Service was not enabled"

# Remove systemd service file
echo "Removing systemd service file..."
sudo rm -f /etc/systemd/system/pi-autoreboot.service

# Remove binary
echo "Removing binary..."
sudo rm -f /usr/local/bin/pi-autoreboot

# Reload systemd
echo "Reloading systemd..."
sudo systemctl daemon-reload

echo ""
echo "Uninstallation completed successfully!"
echo "The pi-autoreboot service has been completely removed from your system."
echo ""