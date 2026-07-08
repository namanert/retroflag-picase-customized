#!/bin/bash

SourcePath=https://raw.githubusercontent.com/namanert/retroflag-picase-customized/master

#Check if root--------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "Please execute script as root."
   exit 1
fi
#-----------------------------------------------------------

#Debian (Trixie/Bookworm) mounts the boot partition at /boot/firmware,
#older Raspberry Pi OS uses /boot directly.
if [ -d /boot/firmware ]; then
	BootDir=/boot/firmware
else
	BootDir=/boot
fi
ConfigFile=$BootDir/config.txt
OverlayDir=$BootDir/overlays

#RetroFlag pw io ;2:in ;3:in ;4:in ;14:out 1----------------------------------------
wget -O "$OverlayDir/RetroFlag_pw_io.dtbo" "$SourcePath/RetroFlag_pw_io.dtbo"
if grep -q "RetroFlag_pw_io" "$ConfigFile";
	then
		sed -i '/RetroFlag_pw_io/c dtoverlay=RetroFlag_pw_io.dtbo' $ConfigFile
		echo "PW IO fix."
	else
		echo "dtoverlay=RetroFlag_pw_io.dtbo" >> $ConfigFile
		echo "PW IO enabled."
fi
if grep -q "enable_uart" "$ConfigFile";
	then
		sed -i '/enable_uart/c enable_uart=1' $ConfigFile
		echo "UART fix."
	else
		echo "enable_uart=1" >> $ConfigFile
		echo "UART enabled."
fi

#-----------------------------------------------------------

#Install GPIO dependency (Trixie blocks bare pip installs, so prefer apt)----
if ! python3 -c "import RPi.GPIO" 2>/dev/null; then
	apt-get update
	if apt-get install -y python3-rpi-lgpio; then
		:
	elif apt-get install -y python3-rpi.gpio; then
		:
	else
		pip3 install --break-system-packages RPi.GPIO
	fi
fi

#Download Python script-----------------------------
mkdir -p /opt/RetroFlag
script=/opt/RetroFlag/SafeShutdown.py
wget -O $script "$SourcePath/SafeShutdown.py"

#Enable Python script to run on start up via systemd------------
cat > /etc/systemd/system/retroflag-safeshutdown.service <<EOF
[Unit]
Description=RetroFlag Pi Case safe shutdown
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $script
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now retroflag-safeshutdown.service
echo "retroflag-safeshutdown.service enabled and started."
#-----------------------------------------------------------

#Reboot to apply changes----------------------------
echo "RetroFlag Pi Case installation done. Will now reboot after 3 seconds."
sleep 3
reboot
#-----------------------------------------------------------
