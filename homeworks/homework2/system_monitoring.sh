#!/bin/bash

MAX_THRESHOLD_DEFAULT=100
MAX_CPU_RATE_THRESHOLD=80
MIN_FREE_RAM_GB_THRESHOLD=10
MAX_USED_DISK_THRESHOLD_RATE=25
MIN_DISK_SPEED_READ_KB_SEC=150

# escape sequences to get rich logs
BLUE_C='\033[0;34m'
BOLD='\e[1m'
RED_C='\033[0;31m'
OFF_ESC='\033[0m'

VERBOSE=false
for arg in "$@"; do
    if [[ "$arg" == "--verbose" ]]; then
        VERBOSE=true
        break
    fi
done

_cpu_info() {
    echo -e "$BOLD Main CPU information: $OFF_ESC"
    echo -e "$BLUE_C $(top -bn1 | head -n 4) $OFF_ESC"
    CPU_IDLE_LOAD=$(top -bn1 | grep "Cpu(s)" | grep -oP '\d+,\d+ id' | sed 's/ id//' | sed 's/,/./')
    CPU_LOAD=$(echo "scale=2; $MAX_THRESHOLD_DEFAULT - $CPU_IDLE_LOAD" | bc)
    echo -e "Current CPU load (%): $CPU_LOAD%"
    if (( $(echo "$CPU_LOAD > $MAX_CPU_RATE_THRESHOLD" | bc -l) )); then
        echo -e "$BOLD $RED_C WARNING!$OFF_ESC CPU load exceed target threshold $MAX_CPU_RATE_THRESHOLD%!"
    fi
    echo ""
}

_ram_info() {
    echo -e "$BOLD Main RAM information: $OFF_ESC"
    echo -e "$BLUE_C $(free -h) $OFF_ESC"
    FREE_RAM_GB=$(free -h | grep Mem | awk '{print $4}' | sed 's/,/./' | sed 's/Gi//')
    echo "Current free RAM: $FREE_RAM_GB Gb"
    if (( $(echo "$FREE_RAM_GB < $MIN_FREE_RAM_GB_THRESHOLD" | bc -l) )); then
        echo -e "$BOLD $RED_C WARNING!$OFF_ESC Free RAM less than min target threshold $MIN_FREE_RAM_GB_THRESHOLD Gb!"
    fi
    echo ""
}

_disk_info() {
    echo -e "$BOLD Main Disk Mem information: $OFF_ESC"
    echo -e "$BLUE_C $(df -h) $OFF_ESC"
    USED_DISK_RATE=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
    echo "Current rate of disk usage: $USED_DISK_RATE%"
    if (( $(echo "$USED_DISK_RATE > $MAX_USED_DISK_THRESHOLD_RATE" | bc -l) )); then
        echo -e "$BOLD $RED_C WARNING!$OFF_ESC Disk rate usage exceed max target threshold $MAX_USED_DISK_THRESHOLD_RATE%!"
    fi
    echo ""
    echo "Disk I/O statistics:"
    if command -v iostat &> /dev/null; then
        echo -e "$BLUE_C $(iostat -dx 1 3 | awk 'NR==1 || NR==3 || NR==4 {print $0}') $OFF_ESC"
        DISK_SPEED_READ_KB_SEC=$(iostat -dx 1 1 | awk 'NR==4 {print $3}' | sed 's/,/./')
        echo "Current disk reading speed: $DISK_SPEED_READ_KB_SEC kB/s"
        if (( $(echo "$DISK_SPEED_READ_KB_SEC < $MIN_DISK_SPEED_READ_KB_SEC" | bc -l) )); then
        echo -e "$BOLD $RED_C WARNING!$OFF_ESC Disk reading speed less than min target threshold $MIN_DISK_SPEED_READ_KB_SEC kB/s!"
        fi
    else
        echo "iostat command not found. Please install sysstat package to get disk I/O statistics."
    fi
    echo ""
}

_network_info() {
    echo -e "$BOLD Main network connections information: $OFF_ESC"
    echo "Count network connections by state:"
    netstat -tun | awk '{print $6}' | sort | uniq -c | sort -nr
    echo ""

    if $VERBOSE; then
      echo "Verbose information about network connections:"
      netstat -tun
      echo ""
    fi
}

_cpu_info
_ram_info
_disk_info
_network_info
