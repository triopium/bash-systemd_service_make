#!/bin/bash

# LOG ROTATION
SERVICE=$1
LOGFILE=/var/log/$1.log

mkdir -p $SERVICE && cd $SERVICE

# Create file $1 with $2 contents if not exists
CreateFile(){
	_file="$1"
	_contents=$2
	if [ -f "$_file" ]; then
		echo "File: $_file exists, overwrite it?"
		select yn in "Yes" "No"; do
		    case $yn in
		        Yes ) break ;;
		        No ) exit;;
		    esac
		done
	fi
	echo "$_contents" > $_file
}

# Put here doc inside variable
define(){ IFS='\n' read -r -d '' ${1} || true; }

# EOF expand bash variables, 'EOF' - dont expand bash variables
define fcont  <<EOF
$LOGFILE {
  rotate 5
  dayly
  size 10M
  compress
  missingok
  notifempty
}
EOF
CreateFile $SERVICE "$fcont"


# SYSTEMD CONFIG
define fcont <<EOF
[Unit]
Description=

[Service]
Type=simple
ExecStart=/bin/bash /usr/bin/$SERVICE.sh

[Install]
WantedBy=multi-user.target
EOF
CreateFile $SERVICE.service "$fcont"

# MAKE SCRIPT
define fcont <<'EOF'
#!/bin/bash
# FUNCTION DEFINITIONS 
logMessage(){
	_message=$1
	_logfile=$2
	echo `date +%Y%m%d_%H%M%S` $_message >> $_logfile
}
EOF
CreateFile $SERVICE.sh "$fcont"

# MAKE INSTALL SCRIPT
define fcont <<EOF
#!/bin/bash
cp $SERVICE.service /etc/systemd/system/
cp $SERVICE.sh /usr/bin
cp $SERVICE /etc/logrotate.d/
EOF
CreateFile ${SERVICE}_install.sh "$fcont"




