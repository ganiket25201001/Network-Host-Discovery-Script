# Network Host Discovery Script - Professional Edition

## 🎯 Overview

A professional-grade network scanning tool designed for network administrators and security professionals. This script performs comprehensive host discovery using ARP scanning and generates detailed reports in multiple formats.

## ✨ Features

### Core Functionality
- **ARP-based Host Discovery**: Fast and reliable layer-2 host detection
- **Network Analysis**: Complete network information including netmask, broadcast, and host ranges
- **Active/Inactive Host Tracking**: Identifies both responding and non-responding hosts
- **Vendor Identification**: MAC address vendor lookup for device identification

### Professional Output
- **Color-coded Console Output**: Easy-to-read terminal display with status indicators
- **CSV Export**: Machine-readable format for active hosts
- **Text Reports**: Detailed inactive host listings
- **HTML Dashboard**: Beautiful, interactive web-based report with statistics
- **Summary Report**: Quick overview of scan results

### Quality Features
- **Error Handling**: Robust error checking and validation
- **Dependency Verification**: Automatic check for required tools
- **Root Privilege Check**: Ensures proper permissions
- **Input Validation**: CIDR notation verification
- **Timestamped Results**: Organized output with timestamps

## 📋 Prerequisites

### Required Tools
```bash
# Debian/Ubuntu/Kali Linux
sudo apt-get update
sudo apt-get install -y nmap arp-scan ipcalc gawk

# Red Hat/CentOS/Fedora
sudo dnf install -y nmap arp-scan ipcalc gawk

# Arch Linux
sudo pacman -S nmap arp-scan ipcalc gawk
```

### System Requirements
- Linux operating system
- Root/sudo privileges
- Network interface with connectivity to target network
- Bash 4.0 or higher

## 🚀 Installation

1. **Download the script:**
```bash
wget https://your-repo/Network_Host_Discovery_Script.sh
# or
curl -O https://your-repo/Network_Host_Discovery_Script.sh
```

2. **Make it executable:**
```bash
chmod +x Network_Host_Discovery_Script.sh
```

3. **Verify dependencies:**
```bash
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
# The script will check dependencies automatically
```

## 📖 Usage

### Basic Syntax
```bash
sudo ./Network_Host_Discovery_Script.sh <network/CIDR>
```

### Examples

#### Scan a Class C Network
```bash
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
```

#### Scan a Smaller Subnet
```bash
sudo ./Network_Host_Discovery_Script.sh 10.0.0.0/28
```

#### Scan a Large Network
```bash
sudo ./Network_Host_Discovery_Script.sh 172.16.0.0/16
```

## 📊 Output Format

### Directory Structure
```
scan_results_YYYYMMDD_HHMMSS/
├── scan_summary.txt          # Quick overview of results
├── active_hosts.csv          # CSV format: IP, MAC, Vendor
├── inactive_ips.txt          # List of non-responding IPs
└── detailed_report.html      # Interactive HTML dashboard
```

### Console Output Example
```
╔════════════════════════════════════════════════════════════════╗
║        Network Host Discovery & Analysis Tool v2.0            ║
║              Professional Network Scanner                      ║
╚════════════════════════════════════════════════════════════════╝

[INFO] Checking dependencies...
[SUCCESS] All dependencies satisfied
[SUCCESS] Created output directory: scan_results_20251110_143022
[INFO] Starting network scan for: 192.168.1.0/24

Network Information:
  Network:   192.168.1.0/24
  Netmask:   255.255.255.0
  Broadcast: 192.168.1.255
  Host Range: 192.168.1.1 - 192.168.1.254

[INFO] Enumerating IP addresses in range...
[SUCCESS] Found 254 possible hosts in range

[INFO] Performing ARP scan (this may take a moment)...
[SUCCESS] Discovered 12 active hosts

[INFO] Generating active hosts report...
[INFO] Identifying inactive hosts...
[SUCCESS] Identified 242 inactive hosts

╔════════════════════════════════════════════════════════════════╗
║              NETWORK SCAN SUMMARY REPORT                       ║
╚════════════════════════════════════════════════════════════════╝

Scan Date/Time: 2025-11-10 14:30:45
Target Network: 192.168.1.0/24
Netmask:        255.255.255.0

────────────────────────────────────────────────────────────────
STATISTICS
────────────────────────────────────────────────────────────────
Total IP Addresses:    254
Active Hosts:          12 (4.72%)
Inactive Hosts:        242
```

### CSV Output Format (active_hosts.csv)
```csv
IP Address,MAC Address,Vendor/Hostname
192.168.1.1,00:11:22:33:44:55,Cisco Systems Inc
192.168.1.10,aa:bb:cc:dd:ee:ff,Dell Inc.
192.168.1.25,11:22:33:44:55:66,Apple Inc.
```

### HTML Report Features
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Statistics Dashboard**: Visual cards showing key metrics
- **Interactive Tables**: Sortable and searchable host information
- **Color-coded Status**: Green for active, red for inactive
- **Professional Styling**: Modern gradient design with shadows

## 🔧 Advanced Configuration

### Customize Network Interface
If you have multiple network interfaces, modify line 147:
```bash
local arp_output=$(arp-scan --interface=eth0 --retry=3 --timeout=500 "$network" 2>/dev/null || arp-scan "$network" 2>/dev/null)
```
Change `eth0` to your interface (e.g., `wlan0`, `ens33`)

### Adjust ARP Scan Parameters
- `--retry=3`: Number of ARP request retries (increase for unreliable networks)
- `--timeout=500`: Timeout in milliseconds (increase for slow networks)

### Modify Output Directory
Change line 18 to customize the output directory name:
```bash
readonly OUTPUT_DIR="scan_results_${TIMESTAMP}"
# Change to:
readonly OUTPUT_DIR="/path/to/custom/directory_${TIMESTAMP}"
```

## 🛡️ Security Considerations

### Permissions
- **Root Required**: ARP scanning requires raw socket access
- **Network Access**: Ensure you have authorization to scan the target network
- **Firewall Rules**: May need to allow ARP traffic

### Legal Notice
⚠️ **WARNING**: Only scan networks you own or have explicit permission to test. Unauthorized network scanning may be illegal in your jurisdiction.

### Best Practices
1. Always obtain written authorization before scanning
2. Scan during maintenance windows to minimize disruption
3. Document all scanning activities
4. Store results securely (contains network topology information)
5. Use VPN or secure connection when scanning remote networks

## 🐛 Troubleshooting

### Common Issues

#### "This script must be run as root"
**Solution**: Use sudo
```bash
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
```

#### "Missing required tools"
**Solution**: Install dependencies
```bash
sudo apt-get install nmap arp-scan ipcalc
```

#### "Invalid CIDR notation"
**Solution**: Use proper format
```bash
# Correct
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24

# Incorrect
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0
```

#### No hosts discovered
**Possible causes**:
1. Wrong network interface (specify with `--interface`)
2. Network isolation/VLAN separation
3. Firewall blocking ARP requests
4. Incorrect network range

**Debug steps**:
```bash
# Check your IP and network
ip addr show

# List available interfaces
ip link show

# Test ARP manually
sudo arp-scan --interface=eth0 --localnet
```

#### Permission denied on output directory
**Solution**: Check write permissions
```bash
# Run from a directory where you have write access
cd ~/Desktop
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
```

## 📈 Performance Tips

### Large Networks
For networks larger than /16:
1. Break into smaller subnets
2. Run parallel scans on different subnets
3. Increase timeout values
4. Use dedicated scanning machine

### Faster Scanning
```bash
# Reduce retries for fast networks
arp-scan --retry=1 --timeout=200 192.168.1.0/24

# Use specific interface
arp-scan --interface=eth0 192.168.1.0/24
```

## 🔄 Integration Examples

### Cron Job for Regular Scanning
```bash
# Edit crontab
sudo crontab -e

# Add daily scan at 2 AM
0 2 * * * /path/to/Network_Host_Discovery_Script.sh 192.168.1.0/24 >> /var/log/network_scan.log 2>&1
```

### Email Results
```bash
# Add to end of script
echo "Network scan completed" | mail -s "Scan Results" -A "$DETAILED_REPORT" admin@example.com
```

### Integration with Monitoring Systems
```bash
# Parse CSV for monitoring
while IFS=',' read -r ip mac vendor; do
    # Send to monitoring system
    curl -X POST http://monitoring-system/api/hosts \
         -d "ip=$ip&mac=$mac&vendor=$vendor"
done < active_hosts.csv
```

## 📝 Changelog

### Version 2.0 (Current)
- ✅ Complete rewrite with professional features
- ✅ Color-coded console output
- ✅ HTML report generation
- ✅ Comprehensive error handling
- ✅ Dependency checking
- ✅ Input validation
- ✅ Timestamped output directories
- ✅ Detailed documentation

### Version 1.0 (Original)
- Basic ARP scanning
- Simple CSV output
- Minimal error handling

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request

## 📄 License

This script is provided "as-is" for educational and professional use. Modify and distribute freely with attribution.

## 👥 Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Contact: network-security-team@example.com
- Documentation: https://your-docs-site.com

## 🙏 Acknowledgments

- **nmap**: Network exploration tool
- **arp-scan**: ARP scanning utility
- **ipcalc**: IP network calculator
- Community contributors and testers

---

**Made with ❤️ by Network Security Professionals**
