Raspberry Pi Sync Script
=======

This is a script to install and update your [BitTorrent Sync](https://www.getsync.com/) installation on your [Raspberry Pi](https://www.raspberrypi.org/).

### Why? I thought there already is a working "Debian Package"?!

Well, I have noticed that in the Sync community a lot of people have been downloading a package from a source that is no longer supported by it's creator thus it is outdated and causes a lot of headaches for people using it. Especially since it was originally meant for the Debian and Ubuntu platform but people have been using it on their Raspberry Pi's as well.  
TL;DR is: don't use it. It is not supported anymore. There are hints that BitTorrent Inc. will come up with their own solution. We'll see what happens ¯\\_(ツ)_/¯.

### What will this script do?

This script will do the following after you run it:
* Ask you if you want to install, update, backup or remove an already existing installation
* Download the latest public available version of the ARM binary from BitTorrent Inc.'s website  
Make sure to have ```curl``` installed  
* Extract the downloaded binary to a predefined location ```/usr/bin/btsync```
* Create an ```/etc/init.d/btsync``` script so you can easily start/stop it
* Create a configuration file for BitTorrent Sync to run from ```/etc/btsync/config.json```
* Create a data directory for it's databases etc. in ```/home/pi/.btsync```

Prior of running this script you want to verify that the user variable on line 6 is correct.  
99% (that is my estimate ;D) are running and using the Raspberry Pi with the default user ```pi```.  
If that is the case for you, you don't need to do anything.

### How to use the script

* SSH into your Raspberry Pi
* Download the script to a folder of your liking e.g. a folder where you keep all your scripts or just ```~/```
```
curl -# -o btsync.sh https://raw.githubusercontent.com/moritzdietz/pi-syncscript/master/btsync.sh
```
* Make the script executable
```
chmod +x btsync.sh
```
* Run the script
```
./btsync.sh
```
* BitTorrent Sync will use a default configuration. Please make sure that it will work in your environment.
[Here](http://help.getsync.com/customer/portal/articles/2018454-running-sync-in-configuration-mode) and [here](http://help.getsync.com/customer/en/portal/articles/1902098-sync-preferences-general-advanced-more-options) are help articles from the [Sync Help Center](http://help.getsync.com/) that will guide you through the configuration options.

You can also provide a direct link to an ARM binarie that has been posted from the Administrators on the forum, but is not yet available through the getsync.com website.  
You do this by using the following syntax ```./btsync.sh yourURLhere``` 
Please be mindful that other URLs/links I can not garantuee that the script might work like expected. Only use links provided by the Sync Staff on the forums!

After the script is done you want to have it automatically start after you reboot your Raspberry Pi.  
To do that, enter the following:```sudo update-rc.d btsync defaults```


If you have any kind of productive contribution to this project, create a pull request! I would love to see people improving it. Especially since I know people will be screaming at their screen how ugly it is.
