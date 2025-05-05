#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-2.0+
# TUI based ethtool PLCA Configurator script
# Copyright (c) 2025 Microchip Technology Inc.

dpkg -s "dialog" &> /dev/null
if [ $? != 0 ]
then
echo "Package dialog is not installed...!"
echo "Do you want to install it ?"
echo " 	1. Yes
	0. No"
echo "Enter your option:"
read option
if [ $option == 1 ]
then
	sudo apt-get install dialog
elif [ $option == 0 ]
then
	echo "Please install dialog and try again...!"
	exit 0
else
	echo "Invalid input...!"
	exit 0
fi
fi

iface_mac="11:22:33:44:55:66"
iface_name=eth1
plca_mode=on
plca_node_id=0
plca_node_count=8
plca_burst_count=0x0
plca_burst_timer=0x80
plca_to_timer=0x20

while [ "${returncode:-99}" -ne 1 ] && [ "${returncode:-99}" -ne 250 ]; do
	exec 3>&1

	value=`dialog \
	      --clear --extra-label "Edit" --ok-label "Save" --cancel-label "Exit" \
	      --backtitle "PLCA Configurator" \
	      --inputmenu "PLCA Configurator" 35 70 55 \
	      "1. MAC Address (Ex: 11:22:33:44:55:66)"		"$iface_mac" \
	      "2. Interface Name (Ex: eth1)"			"$iface_name" \
	      "3. PLCA Mode (on/off)"				"$plca_mode" \
	      "4. PLCA Node ID (0-254)"				"$plca_node_id" \
	      "5. PLCA Node Count (2-255)"			"$plca_node_count" \
	      "6. PLCA Burst Count (0x0-0xFF)"			"$plca_burst_count" \
	      "7. PLCA Burst Timer (0x0-0xFF)"			"$plca_burst_timer" \
	      "8. PLCA TO Timer (0x0-0xFF)"			"$plca_to_timer" \
	      2>&1 1>&3 `

	returncode=$?
	exec 3>&-
	case $returncode in
	3) #Edit
		value=`echo "$value" | sed -e 's/^RENAMED //'`
		tag=`echo "$value" | sed -e 's/).*//'`
		item=`echo "$value" | sed -e 's/^[^)]*)[ 	][ 	]*//'`

		case "$tag" in
			"1. MAC Address (Ex: 11:22:33:44:55:66")
				if [[ $item =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
				iface_mac=$item
				else
				dialog --title "Error" --clear "$@" --msgbox "Invalid MAC Address Configuration" 10 30
				fi
				;;
			"2. Interface Name (Ex: eth1")
				iface_name=$item
				;;
			"3. PLCA Mode (on/off")
				if [[ $item == "on" ]] || [[ $item == "off" ]]
				then
				plca_mode=$item
				else
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA Mode Configuration" 10 30
				fi;;
			"4. PLCA Node ID (0-254")
				if [[ -n ${item//[0-9]/} ]];
				then
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA Node ID Configuration" 10 30
				else
				if [[ $item -lt 0 ]] || [[ $item -gt 254 ]]
				then
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA Node ID Configuration" 10 30
				else
				plca_node_id=$item
				fi
				fi;;
		        "5. PLCA Node Count (2-255")
				if [[ -n ${item//[0-9]/} ]];
				then
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA Node Count Configuration" 10 30
				else
				if [[ $item -lt 2 ]] || [[ $item -gt 255 ]]
				then
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA Node Count Configuration" 10 30
				else
				plca_node_count=$item
				fi
				fi;;
			"6. PLCA Burst Count (0x0-0xFF")
				v1=${item:0:2}
				if [[ $v1 == "0x" ]]
				then
				item=${item:2}
				fi
				if [[ ${#item} -lt 1 ]] || [[ ${#item} -gt 2 ]] || ! [[ $item =~ ^[0-9A-Fa-f]{1,}$ ]]
				then
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA Burst Count Configuration" 10 30
				else
				plca_burst_count=0x$item
				fi;;
			"7. PLCA Burst Timer (0x0-0xFF")
				v1=${item:0:2}
				if [[ $v1 == "0x" ]]
				then
				item=${item:2}
				fi
				if [[ ${#item} -lt 1 ]] || [[ ${#item} -gt 2 ]] || ! [[ $item =~ ^[0-9A-Fa-f]{1,}$ ]]
				then
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA Burst Timer Configuration" 10 30
				else
				plca_burst_timer=0x$item
				fi;;
			"8. PLCA TO Timer (0x0-0xFF")
				v1=${item:0:2}
				if [[ $v1 == "0x" ]]
				then
				item=${item:2}
				fi
				if [[ ${#item} -lt 1 ]] || [[ ${#item} -gt 2 ]] || ! [[ $item =~ ^[0-9A-Fa-f]{1,}$ ]]
				then
				dialog --title "Error" --clear "$@" --msgbox "Invalid PLCA TO Timer Configuration" 10 30
				else
				plca_to_timer=0x$item
				fi;;
		esac
		;;
	0) #Save
		data="SUBSYSTEM=="\"net\"", ACTION=="\"add\"", ATTR{address}=="\"$iface_mac\"", "RUN+="\"/sbin/ethtool --set-plca-cfg $iface_name enable $plca_mode node-id $plca_node_id node-cnt $plca_node_count to-tmr $plca_to_timer burst-cnt $plca_burst_count burst-tmr $plca_burst_timer\""""
		echo $data > 99-$iface_name-plca-config-service.rules
		sudo rm /etc/udev/rules.d/99-$iface_name-plca-config-service.rules
		sudo mv 99-$iface_name-plca-config-service.rules /etc/udev/rules.d/
		sudo systemctl restart systemd-udevd
		dialog --title "Important Info" --clear "$@" --msgbox "Please unplug and plug the EVB-LAN8670-USB device again OR reboot the system for the new configuration to get effect!" 10 30
		clear
		break
		;;
	1) #Exit
		clear
		;;
	255) #Escape
		dialog \
			--clear --backtitle "PLCA Configurator" \
			--yesno "Do you want to exit?" 10 40
		case $? in
		0) #OK
			clear
			break;;
		1) #Cancel
			returncode=99;;
		esac
	;;
	esac
	clear
done
