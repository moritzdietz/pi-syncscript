![BitTorrent Sync loves Raspberry Pi](http://d3f61ff4egbtyy.cloudfront.net/monthly_2016_01/bts_loves_pi_forum.png.b4ba9fc38c01ea35e4b79a3ee7879ed5.png) 
Raspberry Pi + Sync Script
=======

This is a script to manage your [BitTorrent Sync](https://www.getsync.com/) installation on your [Raspberry Pi](https://www.raspberrypi.org/).

### Why? I thought there already is a working "Debian Package"?!

Well, I have noticed that in the Sync community a lot of people have been using a source that is no longer supported by it's creator, thus it is outdated and causes headaches for people using it and supporting BitTorrent Sync in general. TL;DR is: don't use it. It is not supported anymore. There are hints that BitTorrent Inc. will come up with their own solution. We'll see what happens ¯\\_(ツ)_/¯.

### What will this script do?

This script will do the following after you run it:
* Ask if you want to install, update, backup or remove an already existing installation
 * Update, backup and remove only work when BitTorrent Sync was installed with this script
* Download the latest public available version of the ARM binary from BitTorrent Inc.'s website  
 * Make sure to have ```curl``` installed  
* Extract the downloaded binary to a predefined location ```/usr/bin/btsync```
* Create an ```/etc/init.d/btsync``` script so you can easily start/stop it
* Create a configuration file for it to run from ```/etc/btsync/config.json```
* Create a data directory for it's databases etc. in ```/home/<user>/.btsync/```

Backups will be created in ```~/<user>/``` directory using this format ```btsync_backup_dd-mm-yyyy_hh-mm-ss.tar.gz```

### Instructions

* SSH into your Raspberry Pi
* Download the script to a folder where you keep all your scripts or just ```~/```
```
curl -O https://raw.githubusercontent.com/moritzdietz/pi-syncscript/master/btsync.sh
```
* Make the script executable
```
chmod +x btsync.sh
```
* Run the script
 * If you are running the script as a different user than ```pi```, which is the default, the script will ask you if you want to install it as that user instead
```
./btsync.sh
```
You can also provide a direct link to an ARM binary that has been posted from the Administrators on the forum, but is not yet available through the https://getsync.com website.  
You do this by using the syntax ```./btsync.sh yourURLhere```  
Please be mindful: by using other URLs/links I can not garantuee that the script will work like expected!  
Only use links provided by the Sync Staff on the forums or from the official BitTorrent Inc. website.

BitTorrent Sync will use a default configuration. Please make sure that it will work in your environment.
[Here](http://help.getsync.com/hc/en-us/articles/204762689-Running-Sync-in-configuration-mode) and [here](http://help.getsync.com/hc/en-us/articles/207371636-Power-user-preferences) are help articles from the [Sync Help Center](http://help.getsync.com/) that will guide you through the configuration options.

After the script is done, you want to have it automatically start after you reboot your Raspberry Pi.  
To do that enter the following:```sudo update-rc.d btsync defaults```

##### Where can I find information on fixes and features?
Please take a look at the [releases section](https://github.com/moritzdietz/pi-syncscript/releases) to see where this little project is headed and currently at.

If you have any kind of productive contribution to this project, create a pull request!  
I would love to see people improving it.

Oh I almost forgot...
##### "Your script sucks because X"
Well, fuck you. :)


<sub>**Disclaimer**</sub>

<sub><sub>This site is not affiliated, endorsed or supported by BitTorrent Inc. in any way. The use of information and software provided on this website may be used at your own risk. The information and software available on this website are provided as-is without any warranty or guarantee. By visiting this website you agree that: (1) We take no liability under any circumstance or legal theory for any software, error, omissions, loss of data or damage of any kind related to your use or exposure to any information provided on this site; (2) All software are made “AS AVAILABLE” and “AS IS” without any warranty or guarantee. All express and implied warranties are disclaimed. Some states do not allow limitations of incidental or consequential damages or on how long an implied warranty lasts, so the above may not apply to you.</sub></sub>
