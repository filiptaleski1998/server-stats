#!/bin/bash

# server-stats.sh - Server Performance Statistics Script
# This script analyzes and displays key server performance metrics

# ANSI color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to print subsection headers
print_subheader() {
    echo -e "\n${CYAN}--- $1 ---${NC}"
}

# Check if we have root privileges (needed for some advanced stats)
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Note: Some metrics may require root privileges for complete information${NC}"
    fi
}

# Basic system information
system_info() {
    print_header "SYSTEM INFORMATION"
    
    echo -e "${PURPLE}Hostname:${NC} $(hostname)"
    echo -e "${PURPLE}OS:${NC} $(grep -E "^(NAME|VERSION)=" /etc/os-release | cut -d= -f2 | tr -d '"' | tr '\n' ' ')"
    echo -e "${PURPLE}Kernel:${NC} $(uname -r)"
    echo -e "${PURPLE}Uptime:${NC} $(uptime -p)"
    echo -e "${PURPLE}Last Boot:${NC} $(who -b | awk '{print $3 " " $4}')"
    echo -e "${PURPLE}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
}

# CPU information and usage
cpu_info() {
    print_header "CPU INFORMATION"
    
    # CPU model and cores
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')
    cpu_cores=$(grep -c "processor" /proc/cpuinfo)
    echo -e "${PURPLE}CPU Model:${NC} $cpu_model"
    echo -e "${PURPLE}CPU Cores:${NC} $cpu_cores"
    
    # CPU usage
    print_subheader "CPU Usage"
    echo -e "${PURPLE}Total CPU Usage:${NC}"
    top -bn1 | grep "Cpu(s)" | awk '{print "User: " $2 "%, System: " $4 "%, Idle: " $8 "%"}'
    
    cpu_user=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)
    cpu_system=$(top -bn1 | grep "Cpu(s)" | awk '{print $4}' | cut -d% -f1)
    cpu_total=$(echo "$cpu_user + $cpu_system" | bc)
    
    echo -e "${PURPLE}Total CPU Usage:${NC} ${cpu_total}%"
}

# Memory information and usage
memory_info() {
    print_header "MEMORY INFORMATION"
    
    # Get memory info from free command
    total_mem=$(free -m | awk '/Mem:/ {print $2}')
    used_mem=$(free -m | awk '/Mem:/ {print $3}')
    free_mem=$(free -m | awk '/Mem:/ {print $4}')
    buff_cache=$(free -m | awk '/Mem:/ {print $6}')
    available_mem=$(free -m | awk '/Mem:/ {print $7}')
    
    # Calculate percentages
    used_percent=$(echo "scale=2; ($used_mem / $total_mem) * 100" | bc)
    free_percent=$(echo "scale=2; ($free_mem / $total_mem) * 100" | bc)
    buff_cache_percent=$(echo "scale=2; ($buff_cache / $total_mem) * 100" | bc)
    available_percent=$(echo "scale=2; ($available_mem / $total_mem) * 100" | bc)
    
    # Display memory usage
    echo -e "${PURPLE}Total Memory:${NC} $total_mem MB"
    echo -e "${PURPLE}Used Memory:${NC} $used_mem MB (${used_percent}%)"
    echo -e "${PURPLE}Free Memory:${NC} $free_mem MB (${free_percent}%)"
    echo -e "${PURPLE}Buffer/Cache:${NC} $buff_cache MB (${buff_cache_percent}%)"
    echo -e "${PURPLE}Available Memory:${NC} $available_mem MB (${available_percent}%)"
    
    # Get swap info
    print_subheader "Swap Usage"
    total_swap=$(free -m | awk '/Swap:/ {print $2}')
    used_swap=$(free -m | awk '/Swap:/ {print $3}')
    free_swap=$(free -m | awk '/Swap:/ {print $4}')
    
    # Calculate swap percentages if swap exists
    if [ "$total_swap" -ne 0 ]; then
        used_swap_percent=$(echo "scale=2; ($used_swap / $total_swap) * 100" | bc)
        free_swap_percent=$(echo "scale=2; ($free_swap / $total_swap) * 100" | bc)
        echo -e "${PURPLE}Total Swap:${NC} $total_swap MB"
        echo -e "${PURPLE}Used Swap:${NC} $used_swap MB (${used_swap_percent}%)"
        echo -e "${PURPLE}Free Swap:${NC} $free_swap MB (${free_swap_percent}%)"
    else
        echo -e "${PURPLE}Swap:${NC} Not configured"
    fi
}

# Disk usage information
disk_info() {
    print_header "DISK USAGE"
    
    # Get filesystem info
    echo -e "${YELLOW}Filesystem      Size  Used  Avail  Use%  Mounted on${NC}"
    df -h | grep -v "tmpfs\|devtmpfs\|loop" | tail -n +2 | while read -r line; do
        fs=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        used=$(echo "$line" | awk '{print $3}')
        avail=$(echo "$line" | awk '{print $4}')
        use_percent=$(echo "$line" | awk '{print $5}')
        mounted=$(echo "$line" | awk '{print $6}')
        
        # Color code based on usage
        if [[ $(echo "$use_percent" | tr -d '%') -ge 90 ]]; then
            echo -e "${RED}$fs  $size  $used  $avail  $use_percent  $mounted${NC}"
        elif [[ $(echo "$use_percent" | tr -d '%') -ge 70 ]]; then
            echo -e "${YELLOW}$fs  $size  $used  $avail  $use_percent  $mounted${NC}"
        else
            echo -e "$fs  $size  $used  $avail  $use_percent  $mounted"
        fi
    done
}

# Top processes by CPU and memory usage
top_processes() {
    print_header "TOP PROCESSES"
    
    print_subheader "Top 5 Processes by CPU Usage"
    echo -e "${YELLOW}PID   %CPU  %MEM  USER     COMMAND${NC}"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-6s %-5s %-5s %-8s %s\n", $2, $3, $4, $1, $11}'
    
    print_subheader "Top 5 Processes by Memory Usage"
    echo -e "${YELLOW}PID   %CPU  %MEM  USER     COMMAND${NC}"
    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-6s %-5s %-5s %-8s %s\n", $2, $3, $4, $1, $11}'
}

# Network information and statistics
network_info() {
    print_header "NETWORK INFORMATION"
    
    # Show IP addresses for each interface
    print_subheader "Network Interfaces"
    ip -4 addr | grep inet | awk '{print $NF, $2}' | column -t
    
    # Network statistics
    print_subheader "Network Statistics"
    echo -e "${YELLOW}Interface  RX packets  RX bytes  TX packets  TX bytes${NC}"
    
    # Get network interfaces excluding loopback
    interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
    
    for interface in $interfaces; do
        rx_packets=$(cat /proc/net/dev | grep "$interface:" | awk '{print $2}')
        rx_bytes=$(cat /proc/net/dev | grep "$interface:" | awk '{print $3}')
        tx_packets=$(cat /proc/net/dev | grep "$interface:" | awk '{print $10}')
        tx_bytes=$(cat /proc/net/dev | grep "$interface:" | awk '{print $11}')
        
        # Convert bytes to more readable format
        rx_bytes_readable=$(echo "$rx_bytes" | awk '{ split( "B KB MB GB TB PB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print int($1) v[s] }')
        tx_bytes_readable=$(echo "$tx_bytes" | awk '{ split( "B KB MB GB TB PB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print int($1) v[s] }')
        
        echo -e "$interface  $rx_packets  $rx_bytes_readable  $tx_packets  $tx_bytes_readable"
    done
}

# User information and login failures
user_info() {
    print_header "USER INFORMATION"
    
    # Currently logged in users
    print_subheader "Logged In Users"
    who
    
    # User login history
    print_subheader "Last Logins"
    last | head -5
    
    # Failed login attempts
    if [ -f /var/log/auth.log ]; then
        print_subheader "Failed Login Attempts"
        grep "Failed password" /var/log/auth.log | tail -5
    elif [ -f /var/log/secure ]; then
        print_subheader "Failed Login Attempts"
        grep "Failed password" /var/log/secure | tail -5
    else
        echo -e "${YELLOW}Cannot access auth logs. Root privileges may be required.${NC}"
    fi
}

# Main function
main() {
    clear
    echo -e "${GREEN}===================================================${NC}"
    echo -e "${GREEN}        SERVER PERFORMANCE STATISTICS REPORT        ${NC}"
    echo -e "${GREEN}===================================================${NC}"
    echo -e "${YELLOW}Report generated on:${NC} $(date)"
    echo -e "${YELLOW}Script executed by:${NC} $(whoami)"
    
    check_root
    system_info
    cpu_info
    memory_info
    disk_info
    top_processes
    network_info
    user_info
    
    echo -e "\n${GREEN}===================================================${NC}"
    echo -e "${GREEN}                REPORT COMPLETED                   ${NC}"
    echo -e "${GREEN}===================================================${NC}"
}

# Execute main function
main
