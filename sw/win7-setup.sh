#!/bin/bash
# After a clean Ubuntu installation this script installs the Win7 theme.
# It installs all the Windows 7 theme files globally so that they are available to all users.


# Setup variables
RELEASE=`lsb_release -cs`
LOG="$HOME/.win7-setup.log"
OFF_CAMPUS="Y"
ARCH=`uname -m`

# Prep 1 - Are we  "root" ?
if [ $UID -eq 0 ] ; then
	echo "We are root: `date`." >> $LOG
	else
	echo "Please run as the 'root' user by using sudo. See web page again."
fi
# Prep 2 - Remove previous theme tarball and folder
if [ -d $HOME/win7 ] ; then
	rm -rf $HOME/win7
fi
if [ -e $HOME/win7.tar.gz ] ; then
	rm -f $HOME/win7.tar.gz
fi
# Prep 3 - Backup gconf settings
tar -f win7-uninstall.tar.gz -cvz $HOME/.gconf
clear

# Check 1 - Is Zenity installed ?
if [ -x /usr/bin/zenity ] ; then
	echo "Zenity  installed: `date`." >> $LOG
	zenity --info \
	--width=600 \
	--no-wrap \
	--title="Windows 7 Theme Setup" \
	--text="The win7 theme installation will start now.\n\nPlease maxmise and watch the terminal in case you are needed to answer questions.\n\nThis has only been tested with Ubuntu 10.04 LTS!\n\nNo tests have been done for any of the latest versions of Ubuntu using the Unity desktop interface."
	else
	clear
	echo "Please install zenity."
	sleep 2
	exit 1
fi

# Check 2 - Is the system on the campus network ?
sudo ifconfig | grep "146.232"
if [ $? == 0 ] ; then
	OFF_CAMPUS="N"
	echo "System is on campus: `date`." >> $LOG
	else
	OFF_CAMPUS="Y"
	echo "System is off campus: `date`." >> $LOG
fi

# Check 3 - If on campus can we ping ftp.sun.ac.za
if [ $OFF_CAMPUS = "N" ] ; then
	echo "Checking network connection to campus ftp server."
	sleep 1
	ping -c 2 ftp.sun.ac.za
	if [ $? == 0 ] ; then 
		echo "ftp.sun.ac.za ping OK: `date`." >> $LOG
		else
		echo "ftp.sun.ac.za ping failed: `date`." >> $LOG
		zenity --error --title="Windows 7 Theme Setup" --text="Network error.\n\nPlease check network connection and proxy settings.\n\nAborting installation."
		exit 1
	fi
	else
	echo "No need to check campus ftp ping. The system is off campus." >> $LOG
fi

# Check 4 - Desktop session
if [ $DESKTOP_SESSION = "gnome-classic" ] ; then
	echo "Gnome desktop OK: `date`." >> $LOG
	else
	zenity --info --title="Windows 7 Theme Setup" --text="Please use the Gnome classic desktop for the Win7 theme installation."
	clear
	echo "Gnome desktop session is required. Please logout and select a Gnome desktop session during login." >> $LOG
	sleep 2
	exit 1
fi

# Check 5 - Get installation permission
zenity --width=600 --no-wrap --question --title="Windows 7 Theme Setup" --text="All Win 7 theme checks are complete.\n\nAre you sure you want to continue?.\n\nThis has only been tested with Ubuntu 10.04 LTS!\n\nNo tests have been done for any of the latest versions of Ubuntu using the Unity desktop interface.n\n***Click No to cancel or Yes to continue***."
if [ $? == 0 ] ; then
	echo "Win7 installation accepted by $USER: `date`." >> $LOG
	else
	echo "Win7 installation refused by $USER: `date`." >> $LOG
	clear
	exit 1
fi	

# Action 1 - Get the theme tarball downloaded and extracted
sudo wget http://web.lib.sun.ac.za/ubuntu/files/help/theme/gnome/win7.tar.gz
tar -xzvf $HOME/win7.tar.gz
echo "Downloaded and extracted theme tarball: `date`." >> $LOG

# Action 2 - Install required software
if [ $ARCH = "x86_64" ] ; then
	sudo apt-get --yes --force-yes install libc6-i386 ia32-libs
	echo "Installed 32 bit libraries for 64 bit system: `date`." >> $LOG
fi

sudo apt-get --yes --force-yes install \
mc \
nfs-common \
emerald \
ntp \
python \
python-software-properties \
python-xdg \
python-cairo \
python-gconf \
python-xlib \
thunderbird \
cups-pdf \
samba
echo "Installed required win7 theme software: `date`." >> $LOG

# Action 3 - Install theme software

## Install Gnomenu
sudo apt-get --yes --force-yes remove gnomenu
sudo dpkg -i $HOME/win7/debs/gnomenu_all.deb
echo "Installed Gnomenu software: `date`." >> $LOG

## Install Talika
if [ $ARCH = "x86_64" ] ; then
	sudo apt-get --yes --force-yes remove talika
	sudo dpkg -i $HOME/win7/debs/talika_amd64.deb
	echo "Installed 64 bit Talika software: `date`." >> $LOG
	else
	sudo apt-get --yes --force-yes remove talika
	sudo dpkg -i $HOME/win7/debs/talika_i386.deb
	echo "Installed 32 bit Talika software: `date`." >> $LOG
fi

## Install gtk2-oria engine
if [ $ARCH = "x86_64" ] ; then
	sudo apt-get --yes --force-yes remove gtk2-engine-oria-amd64
	sudo dpkg -i $HOME/win7/debs/gtk2-engine-oria_amd64.deb
	echo "Installed 64 bit gtk2-engine-oria software: `date`." >> $LOG
	else
	sudo apt-get --yes --force-yes remove gtk2-engine-oria-i386
	sudo dpkg -i $HOME/win7/debs/gtk2-engine-oria_i386.deb
	echo "Installed 32 bit gtk2-engine-oria software: `date`." >> $LOG
fi

# Action 4 - Install theme files
cd $HOME/win7

sudo tar -C /usr/share/icons/ -xzvf win7-icons.tar.gz
sudo chown -R root.root /usr/share/icons/
sudo chmod -R 0777 /usr/share/icons/

sudo tar -C /usr/share/fonts/truetype -xzvf win7-fonts.tar.gz
sudo chown -R root.root /usr/share/fonts/truetype/
sudo chmod -R 0777 /usr/share/fonts/truetype/

sudo tar -C /usr/share/sounds/ -xzvf win7-sounds.tar.gz
sudo chown -R root.root /usr/share/sounds/
sudo chmod -R 0777 /usr/share/sounds/

sudo tar -C /usr/share/gnomenu/Themes/Menu/ -xzvf gnomenu/menu/win7.tar.gz
sudo chown -R root.root /usr/share/gnomenu/Themes/Menu/
sudo chmod -R 0777 /usr/share/gnomenu/Themes/Menu/

sudo tar -C /usr/share/gnomenu/Themes/Button/ -xzvf gnomenu/button/win7.tar.gz
sudo chown -R root.root /usr/share/gnomenu/Themes/Button/
sudo chmod -R 0777 /usr/share/gnomenu/Themes/Button/

sudo tar -C /usr/share/gnomenu/Themes/Icon/ -xzvf gnomenu/icon/win7.tar.gz
sudo chown -R root.root /usr/share/gnomenu/Themes/Icon/
sudo chmod -R 0777 /usr/share/gnomenu/Themes/Icon/

sudo tar -C /usr/share/gnomenu/Themes/Sound/ -xzvf gnomenu/sound/win7.tar.gz
sudo chown -R root.root /usr/share/gnomenu/Themes/Sound/
sudo chmod -R 0777 /usr/share/gnomenu/Themes/Sound/

sudo tar -C /usr/share/themes/ -xzvf win7-gtk.tar.gz
sudo chown -R root.root /usr/share/themes/
sudo chmod -R 0777 /usr/share/themes/

sudo cp backgrounds/* /usr/share/backgrounds
sudo chown -R root.root /usr/share/backgrounds/
sudo chmod -R 0777 /usr/share/backgrounds/

sudo tar -C /usr/local/etc/ -xzvf win7-emerald.tar.gz
sudo chown -R root.root /usr/local/etc/
sudo chmod -R 0777 /usr/local/etc/

sudo mkdir /usr/share/emerald/theme/win7
sudo cp -R /usr/local/etc/win7-emerald/win7/ /usr/share/emerald/theme/win7/
sudo chown -R root.root /usr/share/emerald/theme/win7
sudo chmod -R 0777 /usr/share/emerald/theme/win7

sudo tar -C /usr/local/etc/ -xzvf win7-theme.tar.gz
sudo chown -R root.root /usr/local/etc/
sudo chmod -R 0777 /usr/local/etc/

sudo cp $HOME/win7/setup-win7-theme.sh /usr/local/bin/setup-win7-theme
sudo chmod 0755 /usr/local/bin/setup-win7-theme
sudo chown root.root /usr/local/bin/setup-win7-theme
echo "Installed win7 theme files: `date`." >> $LOG

# Action 5 - Inform user of win7 setup readme file
cp $HOME/win7/win7-read-me.html $HOME/Desktop/
zenity --info \
--width=450 \
--no-wrap \
--title="Windows 7 Theme Setup" \
--text="The Windows 7 theme files have been installed.\n\nAn instruction web page has been copied to your desktop folder.\n\nDouble click on it to find out how to setup the Windows 7 theme per user."

exit 0
