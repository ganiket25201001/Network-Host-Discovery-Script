#!/bin/bash

################################################################################
# Network Host Discovery Script
# Description: Professional network scanning tool for host discovery and analysis
# Author: Network Security Team
# Version: 2.0
# Usage: sudo ./Network_Host_Discovery_Script.sh <network/CIDR>
# Example: sudo ./Network_Host_Discovery_Script.sh 192.168.1.0/24
################################################################################

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Output files
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly OUTPUT_DIR="scan_results_${TIMESTAMP}"
readonly ACTIVE_HOSTS_CSV="${OUTPUT_DIR}/active_hosts.csv"
readonly INACTIVE_IPS_TXT="${OUTPUT_DIR}/inactive_ips.txt"
readonly SCAN_SUMMARY="${OUTPUT_DIR}/scan_summary.txt"
readonly DETAILED_REPORT="${OUTPUT_DIR}/detailed_report.html"

################################################################################
# Function: print_banner
# Description: Display script banner
################################################################################
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║        Network Host Discovery & Analysis Tool v2.0            ║"
    echo "║              Professional Network Scanner                      ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

################################################################################
# Function: print_info
# Description: Print informational message
################################################################################
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

################################################################################
# Function: print_success
# Description: Print success message
################################################################################
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

################################################################################
# Function: print_warning
# Description: Print warning message
################################################################################
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

################################################################################
# Function: print_error
# Description: Print error message and exit
################################################################################
print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

################################################################################
# Function: check_root
# Description: Verify script is running with root privileges
################################################################################
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
    fi
}

################################################################################
# Function: check_dependencies
# Description: Verify required tools are installed
################################################################################
check_dependencies() {
    local missing_tools=()
    
    print_info "Checking dependencies..."
    
    for tool in nmap arp-scan ipcalc awk; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}\nInstall with: sudo apt-get install nmap arp-scan ipcalc"
    fi
    
    print_success "All dependencies satisfied"
}

################################################################################
# Function: validate_network
# Description: Validate network CIDR notation
################################################################################
validate_network() {
    local network="$1"
    
    if [[ ! "$network" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        print_error "Invalid CIDR notation: $network\nExample: 192.168.1.0/24"
    fi
}

################################################################################
# Function: create_output_directory
# Description: Create directory for scan results
################################################################################
create_output_directory() {
    if [[ -d "$OUTPUT_DIR" ]]; then
        print_warning "Output directory already exists: $OUTPUT_DIR"
    else
        mkdir -p "$OUTPUT_DIR"
        print_success "Created output directory: $OUTPUT_DIR"
    fi
}

################################################################################
# Function: scan_network
# Description: Perform network scanning and host discovery
################################################################################
scan_network() {
    local network="$1"
    
    print_info "Starting network scan for: ${BOLD}$network${NC}"
    echo ""
    
    # Get network information
    local netmask=$(ipcalc -n "$network" | awk -F= '/Netmask/ {print $2}')
    local network_addr=$(ipcalc -n "$network" | awk -F= '/Network/ {print $2}')
    local broadcast=$(ipcalc -n "$network" | awk -F= '/Broadcast/ {print $2}')
    local hostmin=$(ipcalc -n "$network" | awk -F= '/HostMin/ {print $2}')
    local hostmax=$(ipcalc -n "$network" | awk -F= '/HostMax/ {print $2}')
    
    echo -e "${CYAN}Network Information:${NC}"
    echo "  Network:   $network_addr"
    echo "  Netmask:   $netmask"
    echo "  Broadcast: $broadcast"
    echo "  Host Range: $hostmin - $hostmax"
    echo ""
    
    # List all possible IPs in range
    print_info "Enumerating IP addresses in range..."
    local all_ips=$(nmap -sL -n "$network" | awk '/Nmap scan report/{print $NF}')
    local total_ips=$(echo "$all_ips" | wc -l)
    print_success "Found $total_ips possible hosts in range"
    echo ""
    
    # Perform ARP scan
    print_info "Performing ARP scan (this may take a moment)..."
    local arp_output=$(arp-scan --interface=eth0 --retry=3 --timeout=500 "$network" 2>/dev/null || arp-scan "$network" 2>/dev/null)
    
    # Parse active hosts
    local active_data=$(echo "$arp_output" | awk '/^[0-9]/{print $1","$2","$3" "$4" "$5" "$6" "$7" "$8" "$9}')
    local active_ips=$(echo "$active_data" | cut -d',' -f1)
    local active_count=$(echo "$active_ips" | grep -c '^' || echo 0)
    
    print_success "Discovered $active_count active hosts"
    echo ""
    
    # Save active hosts to CSV
    print_info "Generating active hosts report..."
    {
        echo "IP Address,MAC Address,Vendor/Hostname"
        echo "$active_data"
    } > "$ACTIVE_HOSTS_CSV"
    
    # Calculate inactive IPs
    print_info "Identifying inactive hosts..."
    local inactive=$(comm -23 <(printf "%s\n" $all_ips | sort) <(printf "%s\n" $active_ips | sort))
    local inactive_count=$(echo "$inactive" | grep -c '^' || echo 0)
    
    {
        echo "# Inactive IP Addresses"
        echo "# Scan Date: $(date)"
        echo "# Network: $network"
        echo "# Total Inactive: $inactive_count"
        echo ""
        echo "$inactive"
    } > "$INACTIVE_IPS_TXT"
    
    print_success "Identified $inactive_count inactive hosts"
    echo ""
    
    # Generate summary
    generate_summary "$network" "$total_ips" "$active_count" "$inactive_count" "$netmask"
    
    # Generate HTML report
    generate_html_report "$network" "$active_data" "$inactive" "$total_ips" "$active_count" "$inactive_count"
}

################################################################################
# Function: generate_summary
# Description: Create text summary of scan results
################################################################################
generate_summary() {
    local network="$1"
    local total="$2"
    local active="$3"
    local inactive="$4"
    local netmask="$5"
    
    local active_percent=$(awk "BEGIN {printf \"%.2f\", ($active/$total)*100}")
    
    {
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              NETWORK SCAN SUMMARY REPORT                       ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Scan Date/Time: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Target Network: $network"
        echo "Netmask:        $netmask"
        echo ""
        echo "────────────────────────────────────────────────────────────────"
        echo "STATISTICS"
        echo "────────────────────────────────────────────────────────────────"
        echo "Total IP Addresses:    $total"
        echo "Active Hosts:          $active ($active_percent%)"
        echo "Inactive Hosts:        $inactive"
        echo ""
        echo "────────────────────────────────────────────────────────────────"
        echo "OUTPUT FILES"
        echo "────────────────────────────────────────────────────────────────"
        echo "Active Hosts (CSV):    $ACTIVE_HOSTS_CSV"
        echo "Inactive IPs (TXT):    $INACTIVE_IPS_TXT"
        echo "Detailed Report (HTML): $DETAILED_REPORT"
        echo ""
        echo "════════════════════════════════════════════════════════════════"
    } > "$SCAN_SUMMARY"
    
    # Display summary to console
    echo -e "${GREEN}${BOLD}"
    cat "$SCAN_SUMMARY"
    echo -e "${NC}"
}

################################################################################
# Function: generate_html_report
# Description: Create detailed HTML report
################################################################################
generate_html_report() {
    local network="$1"
    local active_data="$2"
    local inactive_data="$3"
    local total="$4"
    local active_count="$5"
    local inactive_count="$6"
    
    cat > "$DETAILED_REPORT" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Network Scan Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { font-size: 1.1em; opacity: 0.9; }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        .stat-card h3 { color: #667eea; font-size: 2em; margin-bottom: 5px; }
        .stat-card p { color: #666; font-size: 0.9em; text-transform: uppercase; }
        .content { padding: 30px; }
        .section { margin-bottom: 40px; }
        .section h2 {
            color: #667eea;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        th, td {
            padding: 15px;
            text-align: left;
        }
        tbody tr:nth-child(even) { background: #f8f9fa; }
        tbody tr:hover { background: #e9ecef; }
        .status-active { color: #28a745; font-weight: bold; }
        .status-inactive { color: #dc3545; font-weight: bold; }
        .info-box {
            background: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .info-box strong { color: #2196F3; }
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
        .inactive-list {
            max-height: 400px;
            overflow-y: auto;
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        .inactive-list div { padding: 5px; }
        .inactive-list div:hover { background: #e9ecef; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔍 Network Scan Report</h1>
            <p>Professional Host Discovery & Analysis</p>
        </div>
        
        <div class="stats">
            <div class="stat-card">
                <h3>SCAN_TOTAL</h3>
                <p>Total IPs</p>
            </div>
            <div class="stat-card">
                <h3 class="status-active">SCAN_ACTIVE</h3>
                <p>Active Hosts</p>
            </div>
            <div class="stat-card">
                <h3 class="status-inactive">SCAN_INACTIVE</h3>
                <p>Inactive Hosts</p>
            </div>
            <div class="stat-card">
                <h3>SCAN_PERCENT%</h3>
                <p>Active Rate</p>
            </div>
        </div>
        
        <div class="content">
            <div class="info-box">
                <strong>Scan Information:</strong><br>
                Network: <strong>SCAN_NETWORK</strong><br>
                Date/Time: <strong>SCAN_DATETIME</strong><br>
                Scanner: Network Host Discovery Tool v2.0
            </div>
            
            <div class="section">
                <h2>✅ Active Hosts</h2>
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>IP Address</th>
                            <th>MAC Address</th>
                            <th>Vendor/Hostname</th>
                        </tr>
                    </thead>
                    <tbody>
                        ACTIVE_HOSTS_ROWS
                    </tbody>
                </table>
            </div>
            
            <div class="section">
                <h2>❌ Inactive Hosts</h2>
                <p style="margin-bottom: 15px;">The following IP addresses did not respond to ARP requests:</p>
                <div class="inactive-list">
                    INACTIVE_HOSTS_ROWS
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>Generated by Network Host Discovery Script | © 2025 Network Security Team</p>
        </div>
    </div>
</body>
</html>
EOF

    # Replace placeholders
    local active_percent=$(awk "BEGIN {printf \"%.1f\", ($active_count/$total)*100}")
    local scan_datetime=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Generate active hosts table rows
    local active_rows=""
    local counter=1
    while IFS=',' read -r ip mac vendor; do
        if [[ -n "$ip" && "$ip" != "IP Address" ]]; then
            active_rows+="<tr><td>$counter</td><td><strong>$ip</strong></td><td>$mac</td><td>$vendor</td></tr>"
            ((counter++))
        fi
    done <<< "$active_data"
    
    # Generate inactive hosts list
    local inactive_rows=""
    while read -r ip; do
        if [[ -n "$ip" ]]; then
            inactive_rows+="<div>$ip</div>"
        fi
    done <<< "$inactive_data"
    
    # Replace all placeholders
    sed -i "s|SCAN_NETWORK|$network|g" "$DETAILED_REPORT"
    sed -i "s|SCAN_DATETIME|$scan_datetime|g" "$DETAILED_REPORT"
    sed -i "s|SCAN_TOTAL|$total|g" "$DETAILED_REPORT"
    sed -i "s|SCAN_ACTIVE|$active_count|g" "$DETAILED_REPORT"
    sed -i "s|SCAN_INACTIVE|$inactive_count|g" "$DETAILED_REPORT"
    sed -i "s|SCAN_PERCENT|$active_percent|g" "$DETAILED_REPORT"
    sed -i "s|ACTIVE_HOSTS_ROWS|$active_rows|g" "$DETAILED_REPORT"
    sed -i "s|INACTIVE_HOSTS_ROWS|$inactive_rows|g" "$DETAILED_REPORT"
    
    print_success "HTML report generated: $DETAILED_REPORT"
}

################################################################################
# Function: display_results
# Description: Show final results and file locations
################################################################################
display_results() {
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}                    SCAN COMPLETED SUCCESSFULLY${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}📁 Results saved to: ${YELLOW}$OUTPUT_DIR${NC}"
    echo ""
    echo -e "  📄 ${BOLD}Summary:${NC}        $SCAN_SUMMARY"
    echo -e "  📊 ${BOLD}Active Hosts:${NC}   $ACTIVE_HOSTS_CSV"
    echo -e "  📋 ${BOLD}Inactive IPs:${NC}   $INACTIVE_IPS_TXT"
    echo -e "  🌐 ${BOLD}HTML Report:${NC}    $DETAILED_REPORT"
    echo ""
    echo -e "${CYAN}Tip: Open the HTML report in your browser for a detailed view${NC}"
    echo ""
}

################################################################################
# MAIN EXECUTION
################################################################################
main() {
    print_banner
    
    # Check for root privileges
    check_root
    
    # Validate arguments
    if [[ $# -ne 1 ]]; then
        print_error "Usage: $0 <network/CIDR>\nExample: $0 192.168.1.0/24"
    fi
    
    local network="$1"
    
    # Validate network format
    validate_network "$network"
    
    # Check dependencies
    check_dependencies
    
    # Create output directory
    create_output_directory
    
    # Perform network scan
    scan_network "$network"
    
    # Display results
    display_results
}

# Execute main function
main "$@"
