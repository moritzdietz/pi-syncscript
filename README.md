
Raspberry Pi + Sync Script
=======

This is a script to manage your [BitTorrent Sync](https://www.getsync.com/) installation on your [Raspberry Pi](https://www.raspberrypi.org/).

### Why? I thought there already is a working "Debian Package"?!

Well, I have noticed that in the Sync community a lot of people have been using a source that is no longer supported by it's creator, thus it is outdated and causes headaches for people using it and supporting BitTorrent Sync in general. It was originally meant for the Debian and Ubuntu platform but there was a way to install it on your Raspberry Pi and then doing some re-configuration of setup- and config-files to have it work properly.
TL;DR is: don't use it. It is not supported anymore. There are hints that BitTorrent Inc. will come up with their own solution. We'll see what happens ¯\\_(ツ)_/¯.

### What will this script do?

This script will do the following after you run it:
* Ask if you want to install it or update, backup, remove an already existing installation
 * Update, backup and remove only work when BitTorrent Sync was installed with this script
* Download the latest public available version of the ARM binary from BitTorrent Inc.'s website  
 * Make sure to have ```curl``` installed  
* Extract the downloaded binary to a predefined location ```/usr/bin/btsync```
* Create an ```/etc/init.d/btsync``` script so you can easily start/stop it
* Create a configuration file for BitTorrent Sync to run from ```/etc/btsync/config.json```
* Create a data directory for it's databases etc. in ```/home/pi/.btsync/```

Prior to running this script you want to verify that the user variable on line 6 is correct.  
99% (that is my estimate ;D) are running and using the Raspberry Pi with the default user ```pi```.  
If that is the case for you, you don't need to change anything. Just follow the instructions below.

### Instructions

* SSH into your Raspberry Pi
* Download the script to a folder where you keep all your scripts or just ```~/```
```
curl -o btsync.sh https://raw.githubusercontent.com/moritzdietz/pi-syncscript/master/btsync.sh
```
* Make the script executable
```
chmod +x btsync.sh
```
* Run the script
```
./btsync.sh
```
You can also provide a direct link to an ARM binary that has been posted from the Administrators on the forum, but is not yet available through the https://getsync.com website.  
You do this by using the syntax ```./btsync.sh yourURLhere```  
Please be mindful: by using other URLs/links I can not garantuee that the script will work like expected!  
Only use links provided by the Sync Staff on the forums or from the official BitTorrent Inc. website.

BitTorrent Sync will use a default configuration. Please make sure that it will work in your environment.
[Here](http://help.getsync.com/customer/portal/articles/2018454-running-sync-in-configuration-mode) and [here](http://help.getsync.com/customer/en/portal/articles/1902098-sync-preferences-general-advanced-more-options) are help articles from the [Sync Help Center](http://help.getsync.com/) that will guide you through the configuration options.

After the script is done, you want to have it automatically start after you reboot your Raspberry Pi.  
To do that enter the following:```sudo update-rc.d btsync defaults```

If you have any kind of productive contribution to this project, create a pull request!  
I would love to see people improving it.

<sub>**Disclaimer**</sub>

<sub><sub>This site is not affiliated, endorsed or supported by DRI in any way. The use of information and software provided on this website may be used at your own risk. The information and software available on this website are provided as-is without any warranty or guarantee. By visiting this website you agree that: (1) We take no liability under any circumstance or legal theory for any software, error, omissions, loss of data or damage of any kind related to your use or exposure to any information provided on this site; (2) All software are made “AS AVAILABLE” and “AS IS” without any warranty or guarantee. All express and implied warranties are disclaimed. Some states do not allow limitations of incidental or consequential damages or on how long an implied warranty lasts, so the above may not apply to you.</sub></sub>
