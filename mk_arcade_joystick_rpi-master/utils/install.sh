#!/bin/sh

if [ "$1" = "updatesystem" ]
then
	echo "Updating system"
	sudo apt-get update || 
         { echo "ERROR : Unable to apt-get update" && exit 1 ;}
	sudo apt-get upgrade -y || 
         { echo "ERROR : Unable to apt-get upgrade" && exit 1 ;}
	sudo rpi-update || 
         { echo "ERROR : Unable to updta the firmware" && exit 1 ;}
	echo "Please reboot if the message above asks for it"
else
	echo "Installing required dependencies"
	sudo apt-get install -y --force-yes dkms cpp-4.7 gcc-4.7 git joystick || 
         { echo "ERROR : Unable to install required dependencies" && exit 1 ;}
	echo "Downloading and installing current kernel headers"
	sudo apt-get install -y --force-yes raspberrypi-kernel-headers || 
         { echo "ERROR : Unable to install kernel headers" && exit 1 ;}
	echo "Downloading mk_arcade_joystick_rpi 0.1.4"
	wget https://github.com/recalbox/mk_arcade_joystick_rpi/releases/download/v0.1.4/mk-arcade-joystick-rpi-0.1.4.deb || 
         { echo "ERROR : Unable to find mk_arcade_joystick_package" && exit 1 ;}
	echo "Installing mk_arcade_joystick_rpi 0.1.4"
	sudo dpkg -i mk-arcade-joystick-rpi-0.1.4.deb || 
         { echo "ERROR : Unable to install mk_arcade_joystick_rpi" && exit 1 ;}
	echo "Installation OK"
	echo "Load the module with 'sudo modprobe mk_arcade_joystick_rpi map=1' for 1 joystick"
	echo "or with 'sudo modprobe mk_arcade_joystick_rpi map=1,2' for 2 joysticks"
	echo "See https://github.com/recalbox/mk_arcade_joystick_rpi#loading-the-driver for more details"
fi