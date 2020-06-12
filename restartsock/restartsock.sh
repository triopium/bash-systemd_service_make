#!/bin/bash
# DESCRIPTION
# FUNCTION DEFINITIONS 
logMessage(){
	_message=$1
	_logfile=$2
	echo `date +%Y%m%d_%H%M%S` $_message >> $_logfile
}

# VARIABLE DEFINITIONS
LOGFILE=/var/log/restartsock.log

