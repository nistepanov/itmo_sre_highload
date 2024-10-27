#!/bin/bash

echo "=== CPU Information ==="

cpu_model=$(lscpu | grep 'Model name:' | sed 's/Model name:[ \t]*//')
echo "CPU Model: $cpu_model"

cpu_logical_count=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
echo "CPU logical count: $cpu_logical_count"

cpu_mhz=$(lscpu | grep 'CPU MHz:' | awk '{print $3}')
echo "Current CPU MHz: $cpu_mhz"

cpu_max_mhz=$(lscpu | grep 'CPU max MHz:' | awk '{print $4}')
echo "Max CPU MHz: $cpu_max_mhz"

echo "Caches (sum of all):"
l1_cache=$(lscpu | grep 'L1d cache:' | awk '{print $3, $4, $5, $6}')
l2_cache=$(lscpu | grep 'L2 cache:' | awk '{print $3, $4, $5, $6}')
l3_cache=$(lscpu | grep 'L3 cache:' | awk '{print $3, $4, $5, $6}')
echo "L1 Cache: $l1_cache"
echo "L2 Cache: $l2_cache"
echo "L3 Cache: $l3_cache"

cpu_sockets=$(lscpu | grep 'Socket(s):' | awk '{print $2}')
echo "CPU sockets: $cpu_sockets"

cpu_cores=$(lscpu | grep 'Core(s) per socket:' | awk '{print $4}')
echo "Cores per socket: $cpu_cores"

threads_per_core=$(lscpu | grep 'Thread(s) per core:' | awk '{print $4}')
echo "Threads per core: $threads_per_core"

echo ""

echo "=== Memory Information ==="
if command -v dmidecode &> /dev/null; then
    dmidecode -t memory
else
    echo "dmidecode is not installed. Please install it to retrieve memory information."
fi
