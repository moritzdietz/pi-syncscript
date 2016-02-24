#!/bin/bash
#
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
stat_y=${yellow}\?${reset}
stat_x=${red}X${reset}
stat_ok=${green}OK${reset}
err_cmd=""

if [ "$(id -u)" == "0" ]; then
    echo "[$stat_x]   Error: This script cannot run as root"
    exit 1
fi
#
# Don't alter the variables below. If you don't want to install the script as pi the script will ask you if you want to install it as the currently logged in user.
# Default is pi
#
if [ "$(whoami)" != "pi" ]; then
  echo "[$stat_x]   Non-Default user $(whoami) detected. Default user to install script as is pi"
  read -r -p "[$stat_y]   Do you want to install the script as the user $(whoami) [yes/no]: " response
  if [[ $response =~ ^([yY][eE][sS])$ ]]; then
    user="$(whoami)"
    echo "[$stat_ok]  User variable set to $(whoami)"
  fi
else
  user="pi"
fi
btsdir="/home/$user/.btsync/data/.syncsystem"

fp=
if [ ! -z $1 ];then
  dllink="$1"
elif [ $(uname -m) == "armv7l" ]; then
      fp=hf
fi

default_dllink="https://download-cdn.getsync.com/stable/linux-arm$fp/BitTorrent-Sync_arm$fp.tar.gz"

function stop_sync {
  echo "[$stat_y]   Trying to stop a running BitTorrent Sync instance"
  sleep 0.5
  syncpid="$(ps aux | grep btsync | grep -v grep | grep -v /bin/bash | awk '{print $2}')"
  if [ -z $syncpid ]; then
    echo "[$stat_ok]  There is no instance of BitTorrent Sync running   "
    sleep 0.5
  else
    err_cmd=$(sudo pkill -15 -x btsync 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: There was an error stopping the BitTorrent Sync instance"
      if [ ! $err_cmd=="" ]; then
        echo "[$stat_x]   $err_cmd"
      fi
      sleep 0.5
      exit 1
    else
      echo "[$stat_ok]  The running instance of BitTorrent Sync has been stopped (PID: $syncpid)"
      sleep 0.5
    fi
  fi
}

function install_preperations {
  if [ ! -d "$btsdir" ]; then
    echo "[$stat_ok]  Trying to create installation folder ($btsdir)"
    sleep 0.5
    err_cmd=$(mkdir -p $btsdir 2>&1 >/dev/null)
      if [ $? -ne 0 ]; then
        echo "[$stat_x]   Error: Could not create installation folder $btsdir"
        echo "[$stat_x]   $err_cmd"
        exit 1
      fi
    echo "[$stat_ok]  BitTorrent Sync installation folder has been created ($btsdir)"
    sleep 0.5
  else
    echo "[$stat_y]   BitTorrent Sync installation folder $btsdir already exists"
    sleep 0.5
    read -r -p "[$stat_y]   Delete all files and sub-folders inside $btsdir? [Y/N]: " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -ne "[$stat_y]   Deleting all files in $btsdir\r"
        err_cmd=$(rm -r $btsdir 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
          echo "[$stat_x]   Error: Could not remove $btsdir/btsync_arm.tar.gz"
          echo "[$stat_x]   $err_cmd"
          sleep 0.5
          exit 1
        fi
        echo "[$stat_ok]  Deleteted all files and sub-folders from $btsdir"
        echo "[$stat_y]   Please restart the script"
        exit 0
    else
        echo "[$stat_x]   Error: Did not install into $btsdir"
        exit 1
    fi
  fi
}

function install {
  sleep 0.5
  err_cmd=$(cd $btsdir 2>&1 >/dev/null)
  if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: Could not change to $btsdir since it does not exist"
      echo "[$stat_x]   $err_cmd"
      exit 1
  fi
  if [ -z $dllink ]; then
      echo "[$stat_y]   Downloading the latest stable version from BitTorrent Inc"
      #Check for HTTP Status code - if other than 200 quit script
      smart_file_download $default_dllink "BiTorrent Sync binary"
    else 
      echo "[$stat_y]   Downloading the binary from the link provided"
      #Check for HTTP Status code - if other than 200 quit script
      smart_file_download $dllink "BiTorrent Sync binary"
  fi
  # So right now all BitTorrent Sync binary files are expected to be a .tar.gz file. If they are not the following command and thus the script will fail and exit.
  err_cmd=$(sudo tar -zxvf $btsdir/*.tar.gz -C /usr/bin/ btsync 2>&1 >/dev/null)
  if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: Could not extract binary archive"
      echo "[$stat_x]   $err_cmd"
      exit 1
  fi
  echo "[$stat_ok]  Extraced the binary to /usr/bin/btsync"
  err_cmd=$(rm $btsdir/*.tar.gz 2>&1 >/dev/null)
  if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: Could not remove binary archive"
      echo "[$stat_x]   $err_cmd"
      exit 1
  fi
}

function btsync_initscript {
  if [ -f /etc/init.d/btsync ]; then
    echo "[$stat_ok]  /etc/init.d/btsync script already exists"
  else
    smart_file_download "https://raw.githubusercontent.com/moritzdietz/pi-syncscript/master/configuration-files/btsync" "init.d script"
    sed -r -i.tmp "s/\bpi\b/$user/g" $btsdir/btsync
    sudo mv $btsdir/btsync /etc/init.d/btsync
    chmod 755 /etc/init.d/btsync && sudo chown root:root /etc/init.d/btsync
    echo "[$stat_ok]  Created /etc/init.d/btsync script"
  fi
}

function btsyncconfig {
  if [ -f /etc/btsync/config.json ]; then
    echo "[$stat_ok]  Configuration file /etc/btsync/config.json already exists"
  else
    smart_file_download "https://raw.githubusercontent.com/moritzdietz/pi-syncscript/master/configuration-files/config.json" "configuration file"
    sed -r -i.tmp "s/\bpi\b/$user/g" $btsdir/config.json
    if [ ! -d /etc/btsync/ ]; then
      sudo mkdir -p /etc/btsync/
    fi
    sudo mv $btsdir/config.json /etc/btsync/config.json
    echo "[$stat_ok]  Created BitTorrent Sync configuration file /etc/btsync/config.json"
  fi
}

function backup {
  backup_date=$(date +"%d-%m-%Y_%H-%M-%S")
  backup_reason="BitTorrent Sync is being backed up"
  # Look for the 4 common signals that indicate this script was killed.
  # If the background command was started, kill it, too.
  if [ -e $btsdir ]; then
    trap '[ -z $! ] || kill $!' SIGHUP SIGINT SIGQUIT SIGTERM
    tar -czPf /home/$user/btsync_backup_$backup_date.tar.gz /etc/init.d/btsync /etc/btsync/config.json /usr/bin/btsync $btsdir --exclude="*.journal" --exclude="*.journal.zip" --exclude="*.log"  --exclude="sync.log.*.zip" & # Backup the files in the background.
  else
    # That actually doesn't work yet... still have to figure that one out
    echo "[$stat_x]   Error: Backup failed"
    echo "[$stat_x]   Error: $btsdir does not exist"
    sleep 0.7
    exit 1
  fi
  # The /proc directory exists while the command runs.
  while [ -e /proc/$! ]; do
    echo -ne "[ooo] $backup_reason\r" && sleep 0.2
    echo -ne "[Ooo] $backup_reason\r" && sleep 0.2
    echo -ne "[oOo] $backup_reason\r" && sleep 0.2
    echo -ne "[ooO] $backup_reason\r" && sleep 0.2
    echo -ne "[ooo] $backup_reason\r" && sleep 0.2
    echo -ne "[ooO] $backup_reason\r" && sleep 0.2
    echo -ne "[oOo] $backup_reason\r" && sleep 0.2
    echo -ne "[Ooo] $backup_reason\r" && sleep 0.2
    echo -ne "[ooo] $backup_reason\r"
  done
  echo -e "\e[0K\r[$stat_ok]  BitTorrent Sync has been successfully backed up at /home/$user/btsync_backup_$backup_date.tar.gz"
}

function remove {
  echo "[$stat_x]   Are you sure you want to remove your BitTorrent Sync installation?"
  echo "[$stat_x]   That includes the following files and folders:"
  echo "[$stat_x]   /home/$user/.btsync/ and all it's files and subfolders"
  echo "[$stat_x]   /etc/init.d/btsync"
  echo "[$stat_x]   /etc/btsync/config.json"
  echo "[$stat_x]   /usr/bin/btsync"
  echo "[$stat_x]   Files and folders that are being synced are not affected by this"
  read -r -p "[$stat_x]   Remove BiTtorrent Sync? (yes/no(default)): " response
    if [[ $response =~ ^([yY][eE][sS])$ ]]; then
      sudo service btsync stop
      sleep 3
      if [ -d /home/$user/.btsync ]; then
        sudo rm -r /home/$user/.btsync
      fi
      if [ -f /etc/init.d/btsync ]; then
        sudo rm /etc/init.d/btsync
      fi      
      if [ -d /etc/btsync/ ]; then
        sudo rm -r /etc/btsync/
      fi
      if [ -f /usr/bin/btsync ]; then
        sudo rm /usr/bin/btsync
      fi
      echo "[$stat_ok]  Successfully removed BitTorrent Sync"
      exit 0
    else
      echo "[$stat_ok]  Aborted removing of BitTorrent Sync"
      exit 1
    fi
}

function version_check {
  if [ -f /usr/bin/btsync ]; then
    echo $(/usr/bin/btsync -help | grep "BitTorrent Sync" | awk {'print $3" "$4'})
  fi
}

function smart_file_download {
    # This function checks for the HTTP Status Code prior of trying to donwnload any file. If the code is not 200 it will quit and let the user know what code came back
    status_code=`curl -s -I $1 | grep HTTP/1.1 | awk {'print $2'}`
    if [ $status_code -ne 200 ];then
      echo -en "\e[1A"; echo -e "\e[0K\r[$stat_x]   Error: There was an error downloading the $2"
      echo "[$stat_x]   Error: HTTP Status Code $status_code"
      exit 1
    else
      cd $btsdir
      curl -# -O $1
      echo -en "\e[1A"; echo -e "\e[0K\r[$stat_ok]  Successfully downloaded the $2"
    fi
}

read -r -p "[$stat_y]   Choose one of the BitTorrent Sync Script options [(i)nstall(default)/(u)pdate/(b)ackup/(r)emove]: " response
if [[ $response =~ ^([u|U]|[u|U]pdate)$ ]]; then
  stop_sync
  echo  "[$stat_ok]  Updating BitTorrent Sync from version $(version_check) to the latest available version"
  install $dllink
  btsync_initscript
  btsyncconfig
  echo "[$stat_ok]  Updated BitTorrent Sync to version $(version_check)"
  echo "[$stat_ok]  You can now start BitTorrent Sync by typing \"sudo service btsync start\""
  exit 0
elif [[ $response =~ ^([b|B]|[b|B]ackup)$ ]]; then
  stop_sync
  backup
  exit 0
elif [[ $response =~ ^(""|[i|I]|[i|I]nstall)$ ]]; then
  stop_sync
  install_preperations
  install
  btsync_initscript
  btsyncconfig
  echo "[$stat_ok]  Installed BitTorrent Sync version $(version_check)"
  echo "[$stat_ok]  You can now start BitTorrent Sync by typing \"sudo service btsync start\""
  exit 0
elif [[ $response =~ ^(""|[r|R]|[r|R]emove)$ ]]; then
  remove
  exit 0
else
  echo "[$stat_x]   Error: You did not choose one of the provided script options. Please try again."
  exit 0
fi
