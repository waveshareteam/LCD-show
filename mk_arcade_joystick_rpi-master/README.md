# mk_arcade_joystick_rpi #

The Raspberry Pi GPIO Joystick Driver

The mk_arcade_joystick_rpi is fully integrated in the **recalbox** distribution : see http://www.recalbox.com

**The branch [hotkeybtn](https://github.com/recalbox/mk_arcade_joystick_rpi/tree/hotkeybtn) now support one more button per player in place of MCP23017 support**

## Introduction ##

The RaspberryPi is an amazing tool I discovered a month ago. The RetroPie project made me want to build my own Arcade Cabinet with simple arcade buttons and joysticks.

So i started to wire my joysticks and buttons to my raspberry pi, and I wrote the first half of this driver in order to wire my joysticks and buttons directly to the RPi GPIOs.

However, the Raspberry Pi Board B Rev 2 has a maximum of 21 usable GPIOs, not enough to wire all the 28 switches (2 joystick and 20 buttons) that a standard panel requires.

UPDATE 0.1.5 : Added GPIO customization

UPDATE 0.1.4 : Compatibily with rpi2 

UPDATE 0.1.3 : Compatibily with 3.18.3 :

The driver installation now works with 3.18.3 kernel, distributed with the last firmware.

UPDATE 0.1.2 : Downgrade to 3.12.28+ :

As the module will not load with recent kernel and headers, we add the possibility of downgrading your firmware to a compatible version, until we find a fix.

UPDATE 0.1.1 : RPi B+ VERSION :

The new Raspberry Pi B+ Revision brought us 9 more GPIOs, so we are now able to connect 2 joysticks and 12 buttons directly to GPIOs. I updated the driver in order to support the 2 joysticks on GPIO configuration.

### Even More Joysticks ###

A little cheap chip named MCP23017 allows you to add 16 external GPIO, and take only two GPIO on the RPi. The chip allows you to use GPIO as output or input, input is what we are looking for if we want even more joysticks. 

If you want to use more than one chip, the i2c protocol lets you choose different addresses for the connected peripheral, but all use the same SDA and SCL GPIOs.

In theory you can connect up to 8 chips so 8 joystick.

## The Software ##
The joystick driver is based on the gamecon_gpio_rpi driver by [marqs](https://github.com/marqs85)

It is written for 4 directions joysticks and 8 buttons per player. Using a MCP23017 extends input numbers to 16 : 4 directions and 12 buttons.

It can read one joystick + buttons wired on RPi GPIOs (two on RPi B+ revision) and up to 5 other joysticks + buttons from MCP23017 chips. One MCP23017 is required for each joystick.

It uses internal pull-ups of RPi and of MCP23017, so all switches must be directly connected to its corresponding GPIO and to the ground.


## Common Case : Joysticks connected to GPIOs ##


### Pinout ###
Let's consider a 6 buttons cab panel with this button order : 

     ↑   Ⓨ Ⓧ Ⓛ  
    ← →	 Ⓑ Ⓐ Ⓡ  
     ↓  

With R = TR and L = TL


Here is the rev B GPIO pinout summary :

![GPIO Interface](https://github.com/recalbox/mk_arcade_joystick_rpi/raw/master/wiki/images/mk_joystick_arcade_GPIOs.png)

If you have a Rev B+ RPi or RPi2:


![GPIO Interface](https://github.com/recalbox/mk_arcade_joystick_rpi/raw/master/wiki/images/mk_joystick_arcade_GPIOsb+.png)

Of course the ground can be common for all switches.

### Installation ###

### Installation Script ###

Download the installation script : 
```shell
mkdir mkjoystick
cd mkjoystick
wget https://github.com/recalbox/mk_arcade_joystick_rpi/releases/download/v0.1.4/install.sh
```

Update your system :
```shell
sudo sh ./install.sh updatesystem
sudo reboot
```

Don't forget to reboot (or the next part won't work) and re-run the script without any arguments :
```shell
sudo sh ./install.sh
```

Now jump to [Loading the driver](#loading-the-driver)


### Manual Installation ###
Update system :
```shell
sudo apt-get update
sudo apt-get upgrade
sudo rpi-update
```


1 - Install all you need :
```shell
sudo apt-get install -y --force-yes dkms cpp-4.7 gcc-4.7 git joystick
```

2 - Install last kernel headers :
```shell
sudo apt-get install -y --force-yes raspberrypi-kernel-headers
```

3.a - Install driver from release (prefered):  
```shell
wget https://github.com/recalbox/mk_arcade_joystick_rpi/releases/download/v0.1.4/mk-arcade-joystick-rpi-0.1.4.deb
sudo dpkg -i mk-arcade-joystick-rpi-0.1.4.deb
```
3.b - Or compile and install with dkms:  

3.b.1 - Download the files:
```shell
git clone https://github.com/pinuct/mk_arcade_joystick_rpi/tree/customgpio
```
3.b.2 - Create a folder under  "/usr/src/*module*-*module-version*/"
```shell
mkdir /usr/src/mk_arcade_joystick_rpi-0.1.5/
```
3.b.3 - Copy the files into the folder:
```shell
cd mk_arcade_joystick_rpi/
cp -a * /usr/src/mk_arcade_joystick_rpi-0.1.5/
```
3.b.4 - Compile and install the module:
```shell
dkms build -m mk_arcade_joystick_rpi -v 0.1.5
dkms install -m mk_arcade_joystick_rpi -v 0.1.5
```

### Loading the driver ###

The driver is loaded with the modprobe command and take one parameter nammed "map" representing connected joysticks. 
When you will have to load the driver you must pass a list of parameters that represent the list of connected Joysticks. The first parameter will be the joystick mapped to /dev/input/js0, the second to js1 etc..

If you have connected a joystick on RPi GPIOs (joystick 1 on the pinout image) you must pass "map=1" as a parameter. If you are on B+ revision and you connected 2 joysticks you must pass map="1,2" as a parameter.

If you have one joystick connected on your RPi B or B+ version you will have to run the following command :

```shell
sudo modprobe mk_arcade_joystick_rpi map=1
```

If you have two joysticks connected on your RPi B+ version you will have to run the following command :

```shell
sudo modprobe mk_arcade_joystick_rpi map=1,2
```
If you have a TFT screen connected on your RPi B+ you can't use all the gpios. You can run the following command for using only the gpios not used by the tft screen (Be careful, not all tft screen use the same pins. GPIOs used with this map: 21,13,26,   19,5,6,22,4,20,17,27,16):

```shell
sudo modprobe mk_arcade_joystick_rpi map=4
```

If you don't want to use all pins or wants a **custom gpio** map use:
```shell
sudo modprobe mk_arcade_joystick_rpi map=5 gpio=pin1,pin2,pin3,.....,pin12
```
Where *pinx* is the number of the gpio you want. There are 12 posible gpio with **button order: Y-,Y+,X-,X+,start,select,a,b,tr,y,x,tl.** Use -1 for unused pins. For example `gpio=21,13,26,19,-1,-1,22,24,-1,-1,-1,-1` uses gpios 21,13,26,19 for axis and gpios 22 and 24 for A and B buttons, the rest of buttons are unused.

The GPIO joystick 1 events will be reported to the file "/dev/input/js0" and the GPIO joystick 2  events will be reported to "/dev/input/js1"

### Auto load at startup ###

Open `/etc/modules` :

```shell
sudo nano /etc/modules
```

and add the line you use to load the driver : 

```shell
mk_arcade_joystick_rpi
```

Then create the file `/etc/modprobe.d/mk_arcade_joystick.conf` :
```shell
sudo nano /etc/modprobe.d/mk_arcade_joystick.conf
```

and add the module configuration : 
```shell
options mk_arcade_joystick_rpi map=1,2
```

### Testing ###

Use the following command to test joysticks inputs :
```shell
jstest /dev/input/js0
```


## More Joysticks case : MCP23017 ##


Here is the MCP23017 pinout summary :


![MCP23017 Interface](https://github.com/recalbox/mk_arcade_joystick_rpi/raw/master/wiki/images/mk_joystick_arcade_mcp23017.png)


### Preparation of the RPi for MCP23017###

Follow the standards installation instructions.

Activate i2c on your RPi :
```shell
sudo nano /etc/modules
```
Add the following lines in order to load i2c modules automatically :
```shell
i2c-bcm2708 
i2c-dev
```

And if the file /etc/modprobe.d/raspi-blacklist.conf exists : 
```shell
sudo nano /etc/modprobe.d/raspi-blacklist.conf
```

Check if you have a line with :
```shell
i2c-bcm2708 
```
and add a # at the beginning of the line to remove the blacklisting

Reboot or load the two module :
```shell
modprobe i2c-bcm2708 i2c-dev
```

### Preparation of the MCP23017 chip ###


You must set the pins A0 A1 and A2 to 0 or 1 in order to set the i2c address of the chip. If you only have 1 chip, connect the 3 pins to the ground.
Just connect one of the pins to 3.3v to set its state to 1 and change the i2c address of the MCP23017.

You must also connect the RESET pin to 3.3v.




### Configuration ###
When you want to load the driver you must pass a list of parameters that represent the list of connected Joysticks. The first parameter will be the joystick mapped to /dev/input/js0, the second to js1 etc..

If you have connected a joystick on RPi GPIOs you must pass "1" as a parameter.

If you have connected one or more joysticks with MCP23017, you must pass the address of I2C peripherals connected, which you can get with the command :

```shell
sudo i2cdetect -y 1
```

The configuration of each MCP23017 is done by setting pads A0 A1 and A2 to 0 or 1.

If you configured your MCP23017 with A0 A1 and A2 connected to the ground, the address returned by i2cdetect should be 0x20

So if you have a joystick connected to RPi GPIOs and a joystick on a MCP23017 with the address 0x20, in order to load the driver, you must run the command :

```shell
sudo modprobe mk_arcade_joystick_rpi map=1,0x20
```

The GPIO joystick events will be reported to the file "/dev/input/js0" and the mcp23017 joystick events will be reported to "/dev/input/js1"

I tested up to 3 joystick, one on GPIOs, one on a MCP23017 on address 0x20, one on a MCP23017 on address 0x24 :

```shell
sudo modprobe mk_arcade_joystick_rpi map=1,0x20,0x24
```


## Known Bugs ##
If you try to read or write on i2c with a tool like i2cget or i2cset when the driver is loaded, you are gonna have a bad time... 

If you try i2cdetect when the driver is running, it will show you strange peripheral addresses...

256MB Raspberry Pi Model B is not supported by the current driver. If you want to make the driver work on your old RPi, you will have to change the address of BSC1_BASE to (BCM2708_PERI_BASE + 0x205000) in order to use the correct i2c address, and recompile.

Credits
-------------
-  [gamecon_gpio_rpi](https://github.com/petrockblog/RetroPie-Setup/wiki/gamecon_gpio_rpi) by [marqs](https://github.com/marqs85)
-  [RetroPie-Setup](https://github.com/petrockblog/RetroPie-Setup) by [petRockBlog](http://blog.petrockblock.com/)
-  [Low Level Programming of the Raspberry Pi in C](http://www.pieter-jan.com/node/15) by [Pieter-Jan](http://www.pieter-jan.com/)
