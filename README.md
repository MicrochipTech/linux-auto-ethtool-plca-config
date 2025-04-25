# linux-plca-configurator-tool

This tool can be used for configuring the PLCA settings in a linux system. It is based on the terminal user interface (tui) which uses dialog package.

## Motivation for this tool
Currently Linux doesn't have the PLCA settings stored for the network devices. Every time when the T1S network devices unplugged and plugged again OR the system is rebooted the user has to reconfigure the PLCA settings of the devices using ethtool application which is not user friendly. Instead, it would be cool if we have a solution which automatically configures the devices when they appear. This script does the job for us.

## Prerequisites

- Linux kernel version should be 6.6 or later.
- Ethtool version should be 6.7 or later.

## Tested platforms

- Raspberry Pi 4 with Linux kernel v6.6.51, ethtool v6.11
- x64, Ubuntu 24.4.2 LTS with Linux Kernel V6.11.0

## How to use
- Clone or download the package,
```
    $ git clone https://github.com/MicrochipTech/linux-auto-ethtool-plca-config.git
```
- Go to the **linux-plca-configurator-tool** directory,
```
    $ cd linux-plca-configurator-tool/
```
- Run the below commands,
```
    $ chmod +x plca_configurator_tui.sh
    $ ./plca_configurator_tui.sh
```
- As the tool is based on the **dialog package**, it will ask for your permission to install the package if it is not installed. You can provide "**Yes**" if you want the tool to install the package automatically before starting the application.
- A **terminal user interface (tui)** will appear with the below options,
    - Interface Name (Ex: eth1)
    - PLCA Mode (on/off)
    - PLCA Node ID (0-254)
    - PLCA Node Count (2-255)
    - PLCA Burst Count (0x0-0xFF)
    - PLCA Burst Timer (0x0-0xFF)
    - PLCA TO Timer (0x0-0xFF)
- After entering your desired settings, press **Save** and you are done.

**Important Note:** After the above configuration, unplug and plug the EVB-LAN8670-USB device (if used) again OR reboot the system for the new configuration to get effect.
