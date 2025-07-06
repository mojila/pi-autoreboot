#!/bin/bash

# Pi Auto-Reboot Installation Script
# This script installs the pi-autoreboot service on Linux systems

set -e

echo "Pi Auto-Reboot Installation Script"
echo "===================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    echo "Error: Rust/Cargo is not installed. Please install Rust first:"
    echo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# Build the project
echo "Building pi-autoreboot..."
cargo build --release

if [ $? -ne 0 ]; then
    echo "Error: Failed to build the project"
    exit 1
fi

# Install the binary
echo "Installing binary to /usr/local/bin/..."
sudo cp target/release/pi-autoreboot /usr/local/bin/
sudo chmod +x /usr/local/bin/pi-autoreboot

# Install systemd service
echo "Installing systemd service..."
sudo cp pi-autoreboot.service /etc/systemd/system/

# Reload systemd and enable service
echo "Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable pi-autoreboot

echo ""
echo "Installation completed successfully!"
echo ""
echo "To start the service now:"
echo "  sudo systemctl start pi-autoreboot"
echo ""
echo "To check service status:"
echo "  sudo systemctl status pi-autoreboot"
echo ""
echo "To view logs:"
echo "  sudo journalctl -u pi-autoreboot -f"
echo ""
echo "To stop the service:"
echo "  sudo systemctl stop pi-autoreboot"
echo ""
echo "To disable the service:"
echo "  sudo systemctl disable pi-autoreboot"
echo ""