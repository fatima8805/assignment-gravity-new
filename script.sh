#!/bin/bash

# Define the CPU usage threshold
THRESHOLD=80

# Get the current CPU usage as percentage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)

# Print the current CPU usage
echo "Current CPU usage is: $CPU_USAGE%"

# Check if CPU usage exceeds the threshold
if [ "$CPU_USAGE" -gt "$THRESHOLD" ]; then
    # Send an email notification if CPU usage is above the threshold
    echo "Warning: High CPU usage detected - $CPU_USAGE%" | mail -s "High CPU Usage Alert" user_email@example.com
fi