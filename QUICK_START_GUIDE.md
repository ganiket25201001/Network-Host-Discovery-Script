# Network Scanner - Quick Start Guide

## 🚀 Quick Start (3 Steps)

### 1. Install Dependencies
```bash
sudo apt-get install -y nmap arp-scan ipcalc
```

### 2. Make Executable
```bash
chmod +x Network_Host_Discovery_Script.sh
```

### 3. Run Scan
```bash
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
```

## 📊 What You Get

### Console Output
- ✅ Color-coded status messages
- 📈 Real-time progress updates
- 📊 Network statistics
- 🎯 Summary report

### Files Generated
```
scan_results_YYYYMMDD_HHMMSS/
├── scan_summary.txt       ← Quick text summary
├── active_hosts.csv       ← Import into Excel/tools
├── inactive_ips.txt       ← Non-responding hosts
└── detailed_report.html   ← Open in browser!
```

## 💡 Common Use Cases

### Home Network Scan
```bash
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
```

### Office Network Scan
```bash
sudo ./Network_Host_Discovery_Script.sh 10.0.0.0/22
```

### Small Subnet Scan
```bash
sudo ./Network_Host_Discovery_Script.sh 172.16.10.0/28
```

## 🎨 Output Preview

### Terminal Output
```
╔════════════════════════════════════════════════════════════════╗
║        Network Host Discovery & Analysis Tool v2.0            ║
╚════════════════════════════════════════════════════════════════╝

[INFO] Checking dependencies...
[SUCCESS] All dependencies satisfied
[INFO] Starting network scan for: 192.168.1.0/24

Network Information:
  Network:   192.168.1.0/24
  Netmask:   255.255.255.0
  Host Range: 192.168.1.1 - 192.168.1.254

[SUCCESS] Discovered 12 active hosts
[SUCCESS] Identified 242 inactive hosts

╔════════════════════════════════════════════════════════════════╗
║              NETWORK SCAN SUMMARY REPORT                       ║
╚════════════════════════════════════════════════════════════════╝

Total IP Addresses:    254
Active Hosts:          12 (4.72%)
Inactive Hosts:        242
```

### CSV Output (active_hosts.csv)
```
IP Address,MAC Address,Vendor/Hostname
192.168.1.1,00:11:22:33:44:55,Cisco Systems
192.168.1.10,aa:bb:cc:dd:ee:ff,Dell Inc.
192.168.1.25,11:22:33:44:55:66,Apple Inc.
```

### HTML Report
- 📊 Beautiful dashboard with statistics
- 📈 Visual charts and graphs
- 🎨 Professional gradient design
- 📱 Mobile-responsive layout
- 🔍 Searchable tables

## ⚡ Pro Tips

### View HTML Report
```bash
# Open in default browser
xdg-open scan_results_*/detailed_report.html

# Or specify browser
firefox scan_results_*/detailed_report.html
google-chrome scan_results_*/detailed_report.html
```

### Import CSV to Excel
1. Open Excel
2. File → Import → CSV
3. Select `active_hosts.csv`
4. Analyze with pivot tables, charts, etc.

### Schedule Regular Scans
```bash
# Add to crontab for daily scans at 2 AM
sudo crontab -e

# Add this line:
0 2 * * * /path/to/Network_Host_Discovery_Script.sh 192.168.1.0/24
```

### Compare Scans Over Time
```bash
# Keep scan results organized
ls -lt scan_results_*/

# Compare active hosts between scans
diff scan_results_20251110_140000/active_hosts.csv \
     scan_results_20251111_140000/active_hosts.csv
```

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Must be run as root" | Add `sudo` before command |
| "Missing required tools" | Run: `sudo apt-get install nmap arp-scan ipcalc` |
| "Invalid CIDR notation" | Use format: `192.168.1.0/24` |
| No hosts found | Check network interface with `ip addr` |
| Permission denied | Run from home directory: `cd ~` |

## 📞 Need Help?

### Check Your Network
```bash
# Show your IP address
ip addr show

# Show network interfaces
ip link show

# Test ARP scan manually
sudo arp-scan --localnet
```

### Verify Installation
```bash
# Check if tools are installed
which nmap arp-scan ipcalc

# Test nmap
nmap --version

# Test arp-scan
sudo arp-scan --version
```

## 🎯 Next Steps

1. ✅ Run your first scan
2. 📊 Open the HTML report in browser
3. 📈 Analyze the results
4. 🔄 Schedule regular scans
5. 📚 Read full documentation in `NETWORK_SCANNER_README.md`

## ⚠️ Important Notes

- **Authorization Required**: Only scan networks you own or have permission to test
- **Root Access**: Script requires sudo for ARP scanning
- **Network Impact**: Minimal, but inform network admin for large scans
- **Data Security**: Results contain sensitive network information - store securely

## 🌟 Features at a Glance

| Feature | Description |
|---------|-------------|
| 🎨 Color Output | Easy-to-read terminal display |
| 📊 Multiple Formats | CSV, TXT, HTML reports |
| ✅ Error Handling | Robust validation and checks |
| 🔍 Vendor Lookup | Identify device manufacturers |
| 📈 Statistics | Active/inactive host percentages |
| 🕐 Timestamps | Organized results by date/time |
| 📱 Responsive | HTML works on all devices |
| 🚀 Fast | Efficient ARP-based scanning |

---

**Ready to scan? Run this now:**
```bash
sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
```

**Questions?** Check `NETWORK_SCANNER_README.md` for detailed documentation.
