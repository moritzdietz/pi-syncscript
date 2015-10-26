#!/bin/bash
#
#Change the $user variable to the user you would like Sync to be installed to and later run as
#Default is pi
user="pi"
# Don't alter variables below since they are relevant for running the script properly
btsdir="/home/$user/.btsync"
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
stat_y=${yellow}\?${reset}
stat_x=${red}X${reset}
stat_ok=${green}OK${reset}
dllink="$1"
err_cmd=""

if [ "$(id -u)" == "0" ]; then
    echo "[$stat_x]   This script cannot run as root"
    exit 1
fi

function stop_sync {
  echo "[$stat_y]   Trying to stop a running BitTorrent Sync instance"
  sleep 0.6
  syncpid="$(ps aux | grep btsync | grep -v grep | grep -v /bin/bash | awk '{print $2}')"
  if [ -z $syncpid ]; then
    echo "[$stat_ok]  There is no instance of BitTorrent Sync running   "
    sleep 0.6
  else
    err_cmd=$(sudo pkill -15 -x btsync 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: There was an error stopping the BitTorrent Sync process"
      if [ ! $err_cmd=="" ]; then
        echo "[$stat_x]   $err_cmd"
      fi
      sleep 0.6
      exit 1
    else
      echo "[$stat_ok]  The running instance of BitTorrent Sync has been stopped (PID: $syncpid)"
      sleep 0.6
    fi
  fi
}

function install_preperations {
  if [ ! -d "$btsdir" ]; then
    echo "[$stat_ok]  Trying to create installation folder $btsdir"
    sleep 0.6
    err_cmd=$(mkdir $btsdir 2>&1 >/dev/null)
      if [ $? -ne 0 ]; then
        echo "[$stat_x]   Could not create installation folder $btsdir"
        echo "[$stat_x]   $err_cmd"
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
        echo "[$stat_x]   Did not install into $btsdir"
        exit 1
    fi
      if [ -f $btsdir/btsync_arm.tar.gz ]; then
          echo "[$stat_y]   An outdated binary file already exists"
          sleep 0.6
          echo "[$stat_ok]  Trying to remove and re-download the latest binary"
          err_cmd=$(rm $btsdir/btsync_arm.tar.gz 2>&1 >/dev/null)
          if [ $? -ne 0 ]; then
            echo "[$stat_x]   Error: Could not remove $btsdir/btsync_arm.tar.gz"
            echo "[$stat_x]   $err_cmd"
            sleep 0.6
            exit 1
          fi
      fi
  fi
}

function install {
  sleep 0.6
  err_cmd=$(cd $btsdir 2>&1 >/dev/null)
  if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: Could not change to $btsdir since it does not exist"
      echo "[$stat_x]   $err_cmd"
      exit 1
  fi
  if [ -z $dllink ]; then
      echo "[$stat_ok]  Downloading the latest stable version from BitTorrent Inc"
      curl -# -o $btsdir/btsync_arm.tar.gz https://download-cdn.getsync.com/stable/linux-arm/BitTorrent-Sync_arm.tar.gz
      if [ $? -ne 0 ]; then
        echo "[$stat_x]   Error: There was an error downloading the BiTorrent Sync binary"
        exit 1
      else
        echo "[$stat_ok]  Successfully downloaded the BiTorrent Sync binary"
      fi
    else 
      echo "[$stat_ok]  Downloading the binary from the link provided"
      curl -# -o $btsdir/btsync_arm.tar.gz $dllink
      if [ $? -ne 0 ]; then
        echo "[$stat_x]   Error: There was an error downloading the file using the link you provided. Please check the URL and try again"
        exit 1
      else
        echo "[$stat_ok]  Successfully downloaded the binary"
      fi
  fi
  if [ $? -ne 0 ]; then
      echo -ne "[$stat_x]   Error: There was an error downloading the file\r"
      echo -ne '\n'
      exit 1
  fi
  err_cmd=$(sudo tar -zxvf $btsdir/btsync_arm.tar.gz -C /usr/bin/ btsync 2>&1 >/dev/null)
  if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: Could not extract btsync_arm.tar.gz"
      echo "[$stat_x]   $err_cmd"
      exit 1
  fi
  echo "[$stat_ok]  Extraced the BitTorrent Sync binary to /usr/bin/btsync"
  err_cmd=$(rm $btsdir/btsync_arm.tar.gz 2>&1 >/dev/null)
  if [ $? -ne 0 ]; then
      echo "[$stat_x]   Error: Could not remove $btsdir/btsync_arm.tar.gz"
      echo "[$stat_x]   $err_cmd"
      exit 1
  fi
}

function btsync_initscript {
  if [ -f /etc/init.d/btsync ]; then
    echo "[$stat_ok]  /etc/init.d/btsync script already exists"
  else
    err_cmd=$(curl -o $btsdir/btsync_init https://raw.githubusercontent.com/moritzdietz/pi-syncscript/master/configuration-files/btsync 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo "[$stat_x]   Error: There was an error downloading the BitTorrent Sync init.d script"
        echo "[$stat_x]   $err_cmd"
        sleep 0.6
        exit 1
      else
        sed -i.tmp "s/pi/$user/" $btsdir/btsync_init
        sudo mv $btsdir/btsync_init /etc/init.d/btsync
        chmod 755 /etc/init.d/btsync && sudo chown root:root /etc/init.d/btsync
        echo "[$stat_ok]  Created /etc/init.d/btsync script"
      fi
  fi
}

function btsyncconfig {
  if [ ! -f /etc/btsync/config.json ]; then
    err_cmd=$(curl -o $btsdir/config.json https://raw.githubusercontent.com/moritzdietz/pi-syncscript/master/configuration-files/config.json 2>&1 >/dev/null)
      if [ $? -ne 0 ]; then
        echo "[$stat_x]   Error: There was an error downloading the BitTorrent Sync configuration file"
        echo "[$stat_x]   $err_cmd"
        sleep 0.6
        exit 1
      else
        sed -i.tmp "s/pi/$user/" $btsdir/config.json
        if [ ! -d /etc/btsync/ ]; then
          sudo mkdir -p /etc/btsync/
        fi
        sudo mv $btsdir/config.json /etc/btsync/config.json
        echo "[$stat_ok]  Created BitTorrent Sync configuration file /etc/btsync/config.json"
      fi
  else
    echo "[$stat_ok]  Configuration file /etc/btsync/config.json already exists"
  fi
}

function backup {
  bkreason="[$stat_ok]  The BitTorrent Sync installation folder is being backed up as (${btsdir}_backup)"
  # Look for the 4 common signals that indicate this script was killed.
  # If the background command was started, kill it, too.
  if [ -e ${btsdir} ]; then
    trap '[ -z $! ] || kill $!' SIGHUP SIGINT SIGQUIT SIGTERM
    sudo cp -r ${btsdir} ${btsdir}_backup &>/dev/null && sudo cp /etc/init.d/btsync ${btsdir}_backup && sudo cp /etc/btsync/config.json ${btsdir}_backup & # Copy the file in the background.
  else
    # That actually doesn't work yet... still have to figure that one out
    echo "[$stat_x]   Error: Copying $btsdir failed"
    sleep 0.7
    exit 1
  fi
  # The /proc directory exists while the command runs.
  while [ -e /proc/$! ]; do
    echo -ne "[ooo] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[Ooo] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[oOo] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[ooO] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[ooo] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[ooO] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[oOo] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[Ooo] ${backuprsn}\r"
    sleep 0.2
    echo -ne "[ooo] ${backuprsn}\r"
  done
  echo -ne "[$stat_ok]  BitTorrent Sync has been successfully backed up                                        \r"
  echo -ne '\n'
  sudo chown $user:$(groups $user | awk '{print $3}') -R ${btsdir}_backup
}

function remove {
  echo "[$stat_x]   Are you sure you want to remove your BitTorrent Sync installation?"
  echo "[$stat_x]   That includes the following files and folders:"
  echo "[$stat_x]   /home/${user}/.btsync/ and all it's files and subfolders"
  echo "[$stat_x]   /etc/init.d/btsync"
  echo "[$stat_x]   /etc/btsync/config.json"
  echo "[$stat_x]   /usr/bin/btsync"
  echo "[$stat_x]   Files and folders that are being synced are not affected by this"
  read -r -p "[$stat_x]   Remove BiTtorrent Sync? Please type out your option (yes/no(default)): " response
    if [[ $response =~ ^([yY][eE][sS])$ ]]; then
      if [ -d /home/${user}/.btsync ]; then
        sudo rm -rf /home/${user}/.btsync
      fi
      if [ -f /etc/init.d/btsync ]; then
        sudo rm /etc/init.d/btsync
      fi      
      if [ -d /etc/btsync/ ]; then
        sudo rm -rf /etc/btsync/
      fi
      if [ -f /usr/bin/btsync ]; then
        sudo rm /usr/bin/btsync
      fi
      echo "[$stat_ok]  Successfully removed BiTtorrent Sync"
      exit 0
    else
      echo "[$stat_ok]  Cancled removing of BitTorrent Sync"
      exit 1
    fi
}

read -r -p "[$stat_y]   Choose one of the BitTorrent Sync Script options [(i)nstall(default)/(u)pdate/(b)ackup/(r)emove]: " response
    if [[ $response =~ ^([u|U]|[u|U]pdate)$ ]]; then
      stop_sync
      echo  "[$stat_ok]  Updating BitTorrent Sync to the latest version"
      install $dllink
      btsync_initscript
      btsyncconfig
      echo "[$stat_ok]  You can now start BitTorrent Sync by typing \"sudo service btsync start\""
      exit 0
    elif [[ $response =~ ^([b|B]|[b|B]ackup)$ ]]; then
      stop_sync
      backup
      echo "[$stat_ok]  You can now start BitTorrent Sync by typing \"sudo service btsync start\""
      exit 0
    elif [[ $response =~ ^(""|[i|I]|[i|I]nstall)$ ]]; then
      stop_sync
      install_preperations
      install
      btsync_initscript
      btsyncconfig
      echo "[$stat_ok]  You can now start BitTorrent Sync by typing \"sudo service btsync start\""
      exit 0
    elif [[ $response =~ ^(""|[r|R]|[r|R]emove)$ ]]; then
      remove
      exit 0
    else
      echo "[$stat_x]   You did not choose one of the provided script options. Please try again."
      exit 0
    fi
