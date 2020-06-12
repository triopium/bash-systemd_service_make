#!/bin/bash
# DESCRIPTION
# Restart smartscoket container if target memory is reached. Current version of smartsocket has memory leak.

# FUNCTION DEFINITIONS 
logMessage(){
	_message=$1
	_logfile=$2
	echo `date +%Y%m%d_%H%M%S` $_message >> $_logfile
}

containerGetId(){
	_cont=$1
	docker ps | grep $_cont | awk '{print $1}'
}

containerGetMem(){
	_cont=$1
	docker stats --no-stream | grep $_cont | awk '{print $7}'
}

# VARIABLE DEFINITIONS
LOGFILE=/var/log/restartsock.log
CONTAINER="r-KVv3-smart-socket"
MEMTRESH="65.00%"
CHECKPERIODE="5s"

## Check if container by name exists. Warning multpile containers with same name may exists
while true; do
sleep $CHECKPERIODE
cid=$(containerGetId $CONTAINER)
if [ -z $cid ] ; then
	# container with name not running
	logMessage "$CONTAINER not running" $LOGFILE
else
	# get memory usage of container
	mem=$(containerGetMem $CONTAINER)
	if [ $mem \< $MEMTRESH ] ; then
		message="container $CONTAINER memory usage $mem lower than treshold $MEMTRESH" 
		logMessage "$message" $LOGFILE
		continue
	else
		docker restart $cid
	fi
	if [ $? -ne 0 ] ; then
		message="error: container $CONTAINER restart failed: $res"
		logMessage "$message" $LOGFILE
	else
		message="container: $CONTAINER, id: $cid, restarted due to memory overflow"
		logMessage "$message" $LOGFILE
	fi
fi

done

