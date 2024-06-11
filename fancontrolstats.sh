#!/bin/bash

# Output file with absolute path
OUTPUT_FILE="stats.csv"

# iDRAC credentials and commands
IDRAC_IP="192.168.168.168"
IDRAC_USER="root"
IDRAC_PASSWORD="calvin"
IDRAC_KEY="0000000000000000000000000000000000000000"
IDRAC_FAN_COMMAND="ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD -y $IDRAC_KEY sdr type fan"
IDRAC_TEMP_COMMAND="ipmitool -I lanplus -H $IDRAC_IP -U $IDRAC_USER -P $IDRAC_PASSWORD -y $IDRAC_KEY sdr type temperature"

# Function to get the number of fans
get_fan_count() {
    $IDRAC_FAN_COMMAND | grep "RPM" | wc -l
}

# Function to get fan headers
get_fan_headers() {
    local fan_count=$(get_fan_count)
    local headers=""
    for ((i=1; i<=fan_count; i++)); do
        headers+=",Fan Speed ${i} (RPM)"
    done
    echo "$headers"
}

# Function to get temperature sensor names and headers
get_temp_headers() {
    local headers=""
    local temp_sensors=$($IDRAC_TEMP_COMMAND | grep "degrees C" | awk -F'|' '{print $1}' | tr -d ' ')
    for sensor in $temp_sensors; do
        headers+=",${sensor} (°C)"
    done
    echo "$headers"
}

# Write headers to the output file if it does not exist
if [ ! -f "$OUTPUT_FILE" ]; then
    FAN_HEADERS=$(get_fan_headers)
    TEMP_HEADERS=$(get_temp_headers)
    echo "Timestamp,CPU Utilization (%)$TEMP_HEADERS$FAN_HEADERS" > "$OUTPUT_FILE"
fi

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# CPU Utilization
CPU_UTIL=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Temperature values
TEMP_VALUES=$($IDRAC_TEMP_COMMAND | grep "degrees C" | awk -F'|' '{print $5}' | sed 's/degrees C//' | tr -d ' ' | tr '\n' ',' | sed 's/,$//')

# Fan Speeds
FAN_SPEEDS=$($IDRAC_FAN_COMMAND | grep "RPM" | awk -F'|' '{print $5}' | sed 's/RPM//' | tr -d ' ' | tr '\n' ',' | sed 's/,$//')

# Handle cases where there are no fan speeds
if [ -z "$FAN_SPEEDS" ]; then
    FAN_SPEEDS="N/A"
fi

# Append the data to the CSV file
echo "$TIMESTAMP,$CPU_UTIL,$TEMP_VALUES,$FAN_SPEEDS" >> "$OUTPUT_FILE"
