# Pi Auto-Reboot

A Rust-based monitoring service for Single Board Computers (SBC) like Raspberry Pi, Orange Pi, and Radxa that automatically reboots the system when internet connectivity is lost.

## Features

- **Internet Connectivity Monitoring**: Pings Google.com every minute to check internet connectivity
- **Automatic Reboot**: Reboots the system after 3 consecutive ping failures
- **Logging**: Comprehensive logging with different log levels (info, warn, error)
- **Lightweight**: Written in Rust for minimal resource usage
- **SBC Optimized**: Designed specifically for homelab SBC devices

## How It Works

1. The service pings `google.com` every 60 seconds
2. If a ping fails, it increments a failure counter
3. If the ping succeeds, the failure counter resets to 0
4. After 3 consecutive failures, the system automatically reboots
5. All activities are logged for monitoring and debugging

## Requirements

- Rust 1.70+ (for compilation)
- Linux-based operating system
- `sudo` privileges for system reboot
- Network interface (for ping functionality)

## Installation

### Option 1: Build from Source

1. Clone the repository:
```bash
git clone <repository-url>
cd pi-autoreboot
```

2. Build the project:
```bash
cargo build --release
```

3. The binary will be available at `target/release/pi-autoreboot`

### Option 2: Install via Cargo

```bash
cargo install --path .
```

## Usage

### Manual Execution

Run the service manually:
```bash
# With default logging
./target/release/pi-autoreboot

# With debug logging
RUST_LOG=debug ./target/release/pi-autoreboot

# With info logging (recommended)
RUST_LOG=info ./target/release/pi-autoreboot
```

### Running as a System Service

For production use, it's recommended to run this as a systemd service:

1. Copy the binary to a system location:
```bash
sudo cp target/release/pi-autoreboot /usr/local/bin/
sudo chmod +x /usr/local/bin/pi-autoreboot
```

2. Create a systemd service file:
```bash
sudo nano /etc/systemd/system/pi-autoreboot.service
```

3. Add the following content:
```ini
[Unit]
Description=Pi Auto-Reboot Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/pi-autoreboot
Restart=always
RestartSec=10
Environment=RUST_LOG=info

[Install]
WantedBy=multi-user.target
```

4. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable pi-autoreboot
sudo systemctl start pi-autoreboot
```

5. Check service status:
```bash
sudo systemctl status pi-autoreboot
```

6. View logs:
```bash
sudo journalctl -u pi-autoreboot -f
```

## Configuration

The service uses the following default settings:
- **Ping Interval**: 60 seconds
- **Failure Threshold**: 3 consecutive failures
- **Ping Timeout**: 5 seconds
- **Target Host**: google.com

To modify these settings, edit the constants in `src/main.rs` and rebuild:

```rust
const MAX_FAILURES: u32 = 3;  // Change failure threshold
const PING_INTERVAL: Duration = Duration::from_secs(60);  // Change interval
```

## Logging

The service provides detailed logging:

- **INFO**: Normal operations, successful pings, connection restoration
- **WARN**: Ping failures with failure count
- **ERROR**: Critical issues, reboot initiation

Log levels can be controlled via the `RUST_LOG` environment variable:
```bash
RUST_LOG=debug  # Most verbose
RUST_LOG=info   # Recommended for production
RUST_LOG=warn   # Only warnings and errors
RUST_LOG=error  # Only errors
```

## Supported Platforms

Tested and verified on:
- Raspberry Pi (all models)
- Orange Pi
- Radxa Rock series
- Other ARM-based Linux SBCs

## Security Considerations

- The service requires `sudo` privileges to execute system reboot
- Run as a dedicated user with minimal privileges when possible
- Monitor logs regularly for any suspicious activity
- Consider firewall rules if running in sensitive environments

## Troubleshooting

### Service Won't Start
- Check if the binary has execute permissions
- Verify the binary path in the systemd service file
- Check system logs: `sudo journalctl -u pi-autoreboot`

### Ping Failures
- Verify network connectivity manually: `ping -c 1 google.com`
- Check DNS resolution: `nslookup google.com`
- Ensure firewall allows outbound ICMP packets

### Reboot Not Working
- Verify sudo privileges: `sudo reboot` (test manually)
- Check if the user has passwordless sudo for reboot command
- Review system logs for reboot-related errors

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

### v0.1.0
- Initial release
- Basic ping monitoring functionality
- Automatic reboot on connection failure
- Systemd service support
- Comprehensive logging

## Support

For issues, questions, or contributions, please open an issue on the project repository.