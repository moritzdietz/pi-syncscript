#!/bin/bash

#
#Change the $user variable to the user you would like Sync to be installed to and later run as
#Default is pi
user="pi"
btsdir="/home/$user/.btsync"
# Don't alter variables below since they are relevant for running the script properly
btsbinary="btsync_arm.tar.gz"
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
stat_y=${yellow}?${reset}
stat_x=${red}X${reset}
stat_ok=${green}OK${reset}
dllink="$1"

if [ "$(id -u)" == "0" ]; then
    echo "[$stat_x]   This script cannot run as root"
    exit 1
fi

function initcheck {
  echo "[$stat_y]   Trying to stop a running BitTorrent Sync instance"
  sleep 0.6
  syncpid=$(ps aux | grep btsync | grep config | awk '{print $2}')
  sudo kill -15 $syncpid &>/dev/null
  if [ $? -ne 0 ]; then
    echo "[$stat_ok]  There is no instance of BitTorrent Sync running   "
    sleep 0.6
  else
    echo "[$stat_ok]  The running instance of BitTorrent Sync has been stopped"
    sleep 0.6
  fi
}

# This function is for the /etc/init.d/btsync script that you can call to start and stop the daemon
function btinitcscript {
  if [ -f /etc/init.d/btsync ]; then
    echo "[$stat_ok]  /etc/init.d/btsync script already exists"
  else
cat > $btsdir/btsync_init << "EOF"
#!/bin/sh
### BEGIN INIT INFO
# Provides: btsync
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Should-Start: $network
# Should-Stop: $network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: daemonized version of btsync.
# Description: Starts the btsync daemon for ${USER} user.
### END INIT INFO

# Replace with linux user you want to run BTSync client for
BTSYNC_USER="${USER}"
DAEMON=/home/${BTSYNC_USER}/.btsync/btsync

start() {
    config=/home/${BTSYNC_USER}/.btsync/config
    if [ -f $config ]; then
      echo "Starting BTSync for $BTSYNC_USER (pid $dbpid)"
      start-stop-daemon --start --quiet -b -o -c $BTSYNC_USER -u $BTSYNC_USER --exec $DAEMON -- --config $config
    else
      echo "Couldn't start BTSync (no $config found)"
    fi
}

stop() {
    dbpid=`pgrep -fu $BTSYNC_USER $DAEMON`
    if [ ! -z "$dbpid" ]; then
      echo "Stopping BitTorrent Sync for $BTSYNC_USER (pid $dbpid)"
      start-stop-daemon --stop -o -c $BTSYNC_USER -K -u $BTSYNC_USER -x $DAEMON
    fi
}

status() {
    dbpid=`pgrep -fu $BTSYNC_USER $DAEMON`
    if [ -z "$dbpid" ]; then
      echo "BitTorrent Sync for USER $BTSYNC_USER: not running"
    else
      echo "BitTorrent Sync for USER $BTSYNC_USER: running (pid $dbpid)"
    fi
}

case "$1" in
  start)
  start
  ;;
  stop)
  stop
  ;;
  restart|reload|force-reload)
  stop
  start
  ;;
  status)
  status
  ;;
  *)
  echo "Usage: /etc/init.d/btsync {start|stop|reload|force-reload|restart|status}"
    exit 1
esac

exit 0
EOF
  #The sed command is replacing the placehold ${USER} with the variable in $user
  #This is just super messy and not nicely written :(
  sudo sed -e "s/\${USER}/$user/" $btsdir/btsync_init > $btsdir/btsync_init2
  sudo mv $btsdir/btsync_init2 /etc/init.d/btsync
  sudo chmod 755 /etc/init.d/btsync
  echo "[$stat_ok]  Created /etc/init.d/btsync script"
  fi
}

# This function is for creating the configuration file read by the btsync binary
function btsyncconfig {
if [ ! -f /home/$user/.btsync/config ]; then
cat > /home/$user/.btsync/config << "EOF"
{
  "device_name": "Raspberry Pi",
  "listening_port" : 0,
  "use_upnp" : true,
  "use dht" : false,
  "profiler_enabled" : false,
  "send_statistics" : false,
  "lan_encrypt_data" : false,
  "webui" :
  {
    "listen" : "0.0.0.0:8888",
    "login" : "admin",
    "password" : "password",
    "allow_empty_password" : false,
    "directory_root" : "/",
    "directory_root_policy" : "all",
  }
}
EOF
echo "[$stat_ok]  Created BitTorrent Sync configuration file ($btsdir/config)"
fi
}


function download {
  sleep 0.6
  cd $btsdir
  if [ $? -ne 0 ]
    then
      echo -ne "[$stat_x]   Error: Could not change to $btsdir since it does not exist\r"
      echo -ne '\n'
      exit 1
  fi
  if [ -z "$dllink" ]; then
      echo "[$stat_ok]  Downloading the latest stable version from BitTorrent Inc"
      curl -# -o btsync_arm.tar.gz https://download-cdn.getsync.com/stable/linux-arm/BitTorrent-Sync_arm.tar.gz
      if [ $? -ne 0 ]; then
        echo -ne "[$stat_x]   Error: There was an error downloading the file\r"
        echo -ne '\n'
        exit 1
      fi
    else 
      echo "[$stat_ok]  Downloading the binary from the link provided"
      curl -# -o btsync_arm.tar.gz "$dllink"
      if [ $? -ne 0 ]; then
        echo -ne "[$stat_x]   Error: There was an error downloading the file. Check the URL and try again\r"
        echo -ne '\n'
        exit 1
      fi
  fi
  if [ $? -ne 0 ]; then
      echo -ne "[$stat_x]   Failed to download the file\r"
      echo -ne '\n'
      exit 1
  fi
  echo "[$stat_ok]  Successfully downloaded the binary"
  cd $btsdir
  tar -zxvf btsync_arm.tar.gz btsync &>/dev/null
  if [ $? -ne 0 ]; then
      echo -ne "[$stat_x]   Error: Could not extract $btsbinary\r"
      echo -ne '\n'
      exit 1
  fi
  echo "[$stat_ok]  Extraced the files to $btsdir"
  rm btsync_arm.tar.gz &>/dev/null
  if [ $? -ne 0 ]; then
      echo -ne "[$stat_x]   Error: Could not remove $btsdir/$btsbinary\r"
      echo -ne '\n'
      exit 1
  fi
}


function install {
  # Calling the initial function to end any current btsync processes
  initcheck

  if [ ! -d "$btsdir" ]; then
    echo "[$stat_ok]  Trying to create installation folder $btsdir"
    sleep 0.6
    mkdir $btsdir
      if [ $? -ne 0 ]; then
        echo -ne "[$stat_x]   Could not create installation folder $btsdir\r"
        echo -ne '\n'
        exit 1
      fi
    echo "[$stat_ok]  The BitTorrent Sync installation folder has been created ($btsdir)"
    sleep 0.6
  else
    echo -ne "[$stat_x]   The installation folder $btsdir already exists\r"
    echo -ne '\n'
    sleep 0.6
    read -r -p "[$stat_x]   Remove files and folders inside $btsdir? [Y/N]: " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -ne "[$stat_y]   Removing all files in $btsdir\r"
        sudo rm -rf ${btsdir}
        echo "[$stat_ok]  Removed all files from $btsdir"
        echo "[$stat_y]   Please restart the script"
        exit 0
    else
        echo -ne "[$stat_x]   Cannot install into $btsdir\r"
        exit 1
    fi
    cd $btsdir
      if [ -f $btsdir"/"$btsbinary ]; then
          echo "[$stat_y]   An outdated binary file already exists"
          sleep 1
          echo "[$stat_ok]  Trying to remove and re-download the latest binary"
          rm $btsdir"/"$btsbinary &>/dev/null
          if [ $? -ne 0 ]; then
          echo -ne "[$stat_x]   Error: Could not remove $btsdir"/"$btsbinary\r"
          sleep 0.6
          exit 1
          fi
      fi
  fi
  # Calling download function to download the binary and extract it
  download
  # Calling btinitcscript to create the /etc/init.d/btsync script
  btinitcscript
  # Calling the btsyncconfig script to create the configuration file for inside /home/pi/.btsync/
  btsyncconfig
}

function _backup {
  bkreason="[$stat_ok]  The BitTorrent Sync installation folder is being backed up as (${btsdir}_backup)"
  # Look for the 4 common signals that indicate this script was killed.
  # If the background command was started, kill it, too.
  if [ -e ${btsdir} ]; then
    trap '[ -z $! ] || kill $!' SIGHUP SIGINT SIGQUIT SIGTERM
    sudo cp -r ${btsdir} ${btsdir}_backup &>/dev/null & # Copy the file in the background.
  else
    # That actually doesn't work yet... still have to figure that one out
    echo -ne '\n'
    echo "[$stat_x]   Error: Copying files failed"
    sleep 0.7
    exit 1
  fi
  # The /proc directory exists while the command runs.
  while [ -e /proc/$! ]; do
    echo -ne "[ooo] ${bkreason}\r"
    sleep 0.2
    echo -ne "[Ooo] ${bkreason}\r"
    sleep 0.2
    echo -ne "[oOo] ${bkreason}\r"
    sleep 0.2
    echo -ne "[ooO] ${bkreason}\r"
    sleep 0.2
    echo -ne "[oOo] ${bkreason}\r"
    sleep 0.2
    echo -ne "[Ooo] ${bkreason}\r"
    sleep 0.2
    echo -ne "[ooo] ${bkreason}\r"
  done
  echo -ne '\n'
  echo -ne "[$stat_ok]  BitTorrent Sync has been successfully backed up\r"
  echo -ne '\n'
  sudo chown $user:$(groups $user | awk '{print $3}') -R ${btsdir}_backup
}


function update {
  initcheck
  echo  "[$stat_ok]  Updating BitTorrent Sync to the latest version"
  download $dllink
  echo  "[$stat_ok]  Done"
  btinitcscript
}

read -r -p "[$stat_y]   Do you want to install BitTorrent Sync or update it? [install(default)/(u)pdate/(b)ackup]: " response
    if [[ $response =~ ^([u|U]|[u|U]pdate)$ ]]; then
      update
      exit 0
    elif [[ $response =~ ^([b|B]|[b|B]ackup)$ ]]; then
      initcheck
      _backup
      exit 0
    fi
