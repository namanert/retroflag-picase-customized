#!/bin/bash

# Removes artifacts left behind by a legacy (pre-Trixie) run of install.sh.
# Safe to run multiple times; no-ops on anything that isn't present.
# The real Debian boot config under /boot/firmware is never touched.

if [[ $EUID -ne 0 ]]; then
	echo "Please execute script as root."
	exit 1
fi

#Legacy config.txt lines written under /boot (not /boot/firmware)------------
LegacyConfig=/boot/config.txt
if [ -f "$LegacyConfig" ]; then
	if grep -q "RetroFlag_pw_io\|enable_uart" "$LegacyConfig"; then
		sed -i '/RetroFlag_pw_io/d;/enable_uart/d' "$LegacyConfig"
		echo "Removed RetroFlag/UART lines from $LegacyConfig."
	fi
fi

#Legacy overlay file----------------------------------------------------------
LegacyOverlay=/boot/overlays/RetroFlag_pw_io.dtbo
if [ -f "$LegacyOverlay" ]; then
	rm -f "$LegacyOverlay"
	echo "Removed $LegacyOverlay."
fi

#Legacy install directory------------------------------------------------------
if [ -d /opt/RetroFlag ]; then
	rm -rf /opt/RetroFlag
	echo "Removed /opt/RetroFlag."
fi

#Legacy rc.local hook----------------------------------------------------------
RC=/etc/rc.local
if [ -f "$RC" ] && grep -q "SafeShutdown.py" "$RC"; then
	sed -i '/SafeShutdown\.py/d' "$RC"
	echo "Removed SafeShutdown.py launch line from $RC."
fi

echo "Cleanup done. Your real boot config in /boot/firmware was never touched."
