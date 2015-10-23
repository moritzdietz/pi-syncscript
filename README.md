Raspberry Pi Sync Script
=======

This is a script to install and update your [BitTorrent Sync](https://www.getsync.com/) installation on your [Raspberry Pi](https://www.raspberrypi.org/).

### Why? I thought there already is a working "Debian Package"?!

Well, I have noticed that in the Sync community a lot of people have been downloading a package from a source that is no longer supported by it's creator thus it is outdated and causes a lot of headaches for people using it. Especially since it was originally meant for the Debian and Ubuntu platform but people have been using it on their Raspberry Pi's as well.  
TL;DR is: don't use it. It is not supported anymore. There are hints that BitTorrent Inc. will come up with their own solution. We'll see what happens ¯\\_(ツ)_/¯.

### What will this script do?

This script will do the following after you run it:
* It will ask you if you want to install or update an already existing installation using script
* Download the latest public available version of the ARM binary from BitTorrent Inc.'s website  
Make sure to have ```curl``` installed  
* Extract it to a predefined location (Default: ```/home/pi/.btsync```)
* Create a script ```/etc/init.d/btsync``` so it runs after boot and you can easily start/stop it
* Create a configuration file for BitTorrent Sync to run from (Default: ```/home/pi/.btsync/config```)
* Ask if you want to create a backup of your current running BitTorrent Sync installation

Prior of running this script you want to verify that the user variable on line 6 is correct.  
99% (that is my estimate ;D) are running and using the Raspberry Pi with the default user ```pi```.  
If that is the case for you, you don't need to do anything.

For the BitTorrent Sync configuration file, [here](http://help.getsync.com/customer/portal/articles/2018454-running-sync-in-configuration-mode) is a link to the help article that describes all options.

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
* Make sure to change the script at the appropriate places to your configuration (e.g. username you would like the script to run as, Sync configuration variables (listening port, username and password for WebGUI etc)).  
Starting from line ```122``` the BitTorrent Sync configuration file starts, there you insert your own configuration pieces.
My script will have a default configuration where BitTorrent Sync is available from but you should definitely modify it.
* Run the script
```
./btsync.sh
```
You can also provide a different URL of a direct link of an ARM binarie that has been posted from the Administrators on the forum, but is not yet available through the getsync.com website.  
You do this by using the following syntax ```./btsync.sh yourURLhere``` 

You will see some output to show you what it is doing or where it failed.  

After the script is done you want to have it automatically start after you reboot your Raspberry Pi.  
To do that, enter the following:```sudo update-rc.d btsync defaults```


If you have any kind of productive contribution to this project, create a pull request! I would love to see people improving it. Especially since I know people will be screaming at their screen how ugly it is.
