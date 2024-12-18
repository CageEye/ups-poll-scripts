#!/bin/bash

if [ $# -eq 0 ]; then
	echo "No params provided."
	echo "This will run for an hour or untill we exit"
	POLL_TIME_SEC=3600 # seconds in an hour
else
	POLL_TIME_SEC=$1
fi

PREV_VOLTAGE=""

OUTPUT_FILE="/tmp/ups_voltage_poll_$(date +%Y%m%d_%H%M%S).log"

START_TIME=$(date +%s.%N)

echo "Starting to poll. Will poll for $POLL_TIME_SEC sec. Output file is $OUTPUT_FILE"
while (( $(echo "$(date +%s.%N) - $START_TIME < $POLL_TIME_SEC" | bc -l) )); do
    CURRENT_TIME=$(date +%s.%N)
    VOLTAGE=$(curl -s http://localhost:9199/ups_metrics | grep "^network_ups_tools_input_voltage" | awk '{print $2}')
    if [[ "$VOLTAGE" != "$PREV_VOLTAGE" ]]; then
	    echo "$(date +"%Y-%m-%d %H:%M:%S.%N") - Input Voltage: $VOLTAGE" >> "$OUTPUT_FILE"
	    PREV_VOLTAGE="$VOLTAGE"	
    fi   
    sleep 0.04
done

echo "Polling completed. Results saved to $OUTPUT_FILE"
