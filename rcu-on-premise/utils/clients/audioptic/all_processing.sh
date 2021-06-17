#!/bin/bash

# Get current day
DAY=$(date +%d)

# Current log file
FILE=~/rcu-logs/rcu_*.log

# Move the current log file to the history directory on the first day of the month
if ([ -f $FILE ] && [ $DAY == '01' ])
then
    mv ~/rcu-logs/rcu_*.log ~/rcu-logs/log-history
fi

# Environment variables
source ~/.bashrc
PYTHON_PATH=~/.virtualenvs/rcu/bin/python3.6

# Go to src directory
cd ~/rcu-on-premise/src/

# Main command
$PYTHON_PATH manage.py run-all audioptic

# Get current year and month
YEAR_MONTH=$(date +%Y_%m)

# Update the log file
echo "---" >> ~/rcu-logs/rcu_$YEAR_MONTH.log
cat ~/rcu-on-premise/src/rcu.log >> ~/rcu-logs/rcu_$YEAR_MONTH.log
