#!/bin/bash

# server-stats.sh - A script to analyze basic server performance statistics

# Function to display section headers
section_header() {
    echo "----------------------------------------"
    echo "$1"
    echo "----------------------------------------"
}

# Clear screen
clear

# Display current date and time
echo "Server Performance Statistics - $(date)"
echo ""

# 1. System Information (stretch goal)
section_header "System Information"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(cat /proc/loadavg | awk '{print $1", "$2", "$3}')"
echo "Logged in Users: $(who | wc -l)"
echo ""

# 2. CPU Usage
section_header "CPU Usage"
total_cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
echo "Total CPU Usage: $total_cpu_usage"
echo ""

# 3. Memory Usage
section_header "Memory Usage"
free -h | awk '/^Mem:/ {print "Total: " $2, "Used: " $3, "Free: " $4}'
memory_percentage=$(free | awk '/Mem/{printf("Percentage Used: %.2f%"), $3/$2*100}')
echo "$memory_percentage"
echo ""

# 4. Disk Usage
section_header "Disk Usage"
df -h | awk '/^\/dev\// {print $1": " $3 " used out of " $2 " (" $5 ")"}'
echo ""

# 5. Top 5 Processes by CPU Usage
section_header "Top 5 Processes by CPU Usage"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
echo ""

# 6. Top 5 Processes by Memory Usage
section_header "Top 5 Processes by Memory Usage"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
echo ""

# 7. Failed Login Attempts (stretch goal)
section_header "Failed Login Attempts (last 24h)"
journalctl --since "24 hours ago" -t sshd | grep "Failed password" | wc -l | awk '{print "Total failed SSH attempts: " $1}'
echo ""

# 8. Network Connections (stretch goal)
section_header "Active Network Connections"
ss -s | head -n 4
echo ""
