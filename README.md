![BitTorrent Sync loves Raspberry Pi](https://i.imgur.com/0lTAi8l.png) 
Raspberry Pi + Sync Script
=======

This is a script to manage your [BitTorrent Sync](https://www.getsync.com/) installation on your [Raspberry Pi](https://www.raspberrypi.org/).

### Why should I be using this script?

**EDIT:** You shouldn't! Please check [help.getsync.com](https://help.getsync.com) for information on how to add the repository and install Sync using apt.

There used to be a non-official repository people have been using to install BitTorrent Sync on their machines.  
The creator and maintainer of that repository has moved on and left his project to the community trying to fix bugs themselves.
It was a headache for everybody involved since things didn't work as expected and nobody was really digging into it.

Since I was testing and troubleshooting BitTorrent Sync a lot and had to re-install and update it on my machines, I wanted to have it a little bit nice and automated.  
People on the forum have frequently been asking for advice on how to setup, install and maintain BitTorrent Sync on their Raspberry Pis. Especially Linux beginners didn’t really know how to do that. This gave me a good reason to publish my script for all to share and use.

### Does BiTorrent Inc. host an official repository?
Yes, they do. They have been working on it for a while and now they have finally published a blog post telling users that they can use their official repository. Make sure to check out their blogpost [here](http://blog.getsync.com/2016/02/18/official-linux-packages-for-sync-now-available).

### What will this script do?

This script will do the following things when you run it:
* Ask if you want to install, update, backup or remove an already existing installation
 * Update, backup and remove only work when BitTorrent Sync was installed with this script
* Download the latest public available version of the ARM binary from BitTorrent Inc.'s website  
 * Make sure to have ```curl``` installed  
* Extract the downloaded binary to a predefined location ```/usr/bin/btsync```
* Create an ```/etc/init.d/btsync``` script so you can easily start/stop it
* Create a configuration file for it to run from ```/etc/btsync/config.json```
* Create a data directory for it's databases etc. in ```/home/<user>/.btsync/```

Backups will be created in ```~/<user>/``` directory using this format ```btsync_backup_dd-mm-yyyy_hh-mm-ss.tar.gz```

### Will this work on Raspbian Jessie?
As of right now this script only works on Wheezy since it uses init.d and does not support systemd.  
There is an error message after you run it on Raspbian Jessie  
```Failed to start btsync.service: Unit btsync.service failed to load: No such file or directory.```  
Feel free to fork it if you want to enhance support! I also love seeing PRs :) 


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
For example  ``` ./btsync.sh https://download-cdn.getsync.com/2.3.2/linux-arm/BitTorrent-Sync_arm.tar.gz ```  
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

<sub>**Disclaimer**</sub>

<sub><sub>This site is not affiliated, endorsed or supported by BitTorrent Inc. in any way. The use of information and software provided on this website may be used at your own risk. The information and software available on this website are provided as-is without any warranty or guarantee. By visiting this website you agree that: (1) We take no liability under any circumstance or legal theory for any software, error, omissions, loss of data or damage of any kind related to your use or exposure to any information provided on this site; (2) All software are made “AS AVAILABLE” and “AS IS” without any warranty or guarantee. All express and implied warranties are disclaimed. Some states do not allow limitations of incidental or consequential damages or on how long an implied warranty lasts, so the above may not apply to you.</sub></sub>
