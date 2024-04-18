#!/bin/bash

# This script is used to analyze the ammount of futex calls made by a command.

# Check if command is provided
if [ -z "$1" ]; then
    echo "Please provide a command to analyze."
    exit 1
fi

echo "running $@"

# Run strace on the command, filter for futex calls and save them to a file
strace --follow-forks -e trace=futex -o futex_output.txt $@ 2> log.txt

# Analyze the file for futex calls and count them
echo -e "\nFutex from strace..."
awk '{print $2}' futex_output.txt | sort | uniq -c | sort -nr


# Same with the WASMTIME_LOG
echo -e "\n\nFutex from WASMTIME_LOG"
awk '/mem/ {print $4}' log.txt | sort | uniq -c | sort -nr


rm futex_output.txt log.txt
