https://roadmap.sh/projects/server-stats

Server Performance Analysis Script - server-stats.sh
Overview
This script provides a comprehensive overview of server performance statistics, including CPU, memory, and disk usage, along with process information and system details. It's designed to be run on Linux servers for quick performance analysis.

Features
System Information: Hostname, OS version, kernel, uptime

CPU Usage: Total CPU utilization percentage

Memory Usage: Used/free memory with percentage

Disk Usage: Filesystem utilization for all mounted devices

Process Monitoring: Top 5 processes by CPU and memory usage

Security Monitoring: Failed login attempts (last 24 hours)

Network Overview: Active connections summary

Requirements
Linux-based operating system

Bash shell

Standard GNU utilities (top, ps, free, df, etc.)

Systemd (for journalctl commands - used in failed login tracking)

Installation
Download the script:

bash
wget https://example.com/path/to/server-stats.sh
Make it executable:

bash
chmod +x server-stats.sh
(Optional) Move to a directory in your PATH for easy access:

bash
sudo mv server-stats.sh /usr/local/bin/
Usage
Run the script with:

bash
./server-stats.sh
For regular monitoring, you might want to:

Run it periodically with cron

Redirect output to a log file

Pipe through less for better readability

Example Output
Server Performance Statistics - Tue May 7 10:30:45 UTC 2024

----------------------------------------
System Information
----------------------------------------
Hostname: server1
OS: Ubuntu 22.04.3 LTS
Kernel: 5.15.0-76-generic
Uptime: up 2 weeks, 3 days, 5 hours
Load Average: 0.12, 0.15, 0.18
Logged in Users: 3

----------------------------------------
CPU Usage
----------------------------------------
Total CPU Usage: 12.5%

----------------------------------------
Memory Usage
----------------------------------------
Total: 7.6Gi, Used: 5.2Gi, Free: 2.4Gi
Percentage Used: 68.42%

[... additional sections ...]
Customization
You can modify the script to:

Add more metrics by editing the script

Change output format (JSON, CSV) for automation

Adjust the number of processes shown (currently top 5)

Add email alerts for critical thresholds

Troubleshooting
If you encounter issues:

Ensure you have execute permissions

Check if required commands are installed

Some information might require root privileges

On non-systemd systems, modify the failed login check

License
This script is provided under the MIT License. Feel free to use and modify it for your needs.

Contributing
Contributions are welcome! Please open issues or pull requests for:

Bug fixes

Additional features

Compatibility improvements
