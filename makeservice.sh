#!/bin/bash

# VARIABLES
SERVICE=$1
LOGFILE=/var/log/$1.log
DESCRIPTION="Restart smartscoket container if target memory is reached. Current version of smartsocket has memory leak."

if [ -d "$SERVICE" ]; then
	echo "WARNING: directory with name "$SERVICE" already exists. You have to remove it to continue"
	exit 1
else
	mkdir -p $SERVICE && cd $SERVICE
fi

# FUNCTIONS
# Create file $1 with $2 contents if not exists
CreateFile(){
	_file="$1"
	_contents=$2
	if [ -f "$_file" ]; then
		echo "File: $_file exists, overwrite it?"
		select yn in "Yes" "No" ; do
		    case $yn in
		        Yes ) break ;;
		        No ) exit;;
		    esac
		done
	fi
	echo "$_contents" > $_file
}

# Put here doc inside variable
# EOF expand bash variables, 'EOF' - dont expand bash variables
define(){ IFS='\n' read -r -d '' ${1} || true; }

######################
# LOGROTATION 
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

#####################
# SYSTEMD CONFIG
define fcont <<EOF
[Unit]
Description=$DESCRIPTION

[Service]
Type=simple
ExecStart=/bin/bash /usr/bin/$SERVICE.sh

[Install]
WantedBy=multi-user.target
EOF

CreateFile $SERVICE.service "$fcont"

#####################
# MAKE SCRIPT
define fcont <<'EOF'
#!/bin/bash
# DESCRIPTION
# FUNCTION DEFINITIONS 
logMessage(){
	_message=$1
	_logfile=$2
	echo `date +%Y%m%d_%H%M%S` $_message >> $_logfile
}
EOF
CreateFile $SERVICE.sh "$fcont"

define fcont <<EOF
# VARIABLE DEFINITIONS
LOGFILE=$LOGFILE
EOF
echo "$fcont">>$SERVICE.sh

#####################
# MAKE INSTALL SCRIPT
define fcont <<EOF
#!/bin/bash
#############
# DESCRIPTION
# $DESCRIPTION
cp $SERVICE.service /etc/systemd/system/
cp $SERVICE.sh /usr/bin
cp $SERVICE /etc/logrotate.d/
EOF
CreateFile ${SERVICE}_install.sh "$fcont"
echo "Systemd service template created inside $PWD/. Don't forget edit files a then run install."

#######################
# MAKE UNINSTALL SCRIPT
define fcont <<EOF
#!/bin/bash
rm -v /etc/systemd/system/$SERVICE.service 
rm -v /usr/bin/$SERVICE.sh 
rm -v /etc/logrotate.d/$SERVICE 
EOF
CreateFile ${SERVICE}_uninstall.sh "$fcont"
