#!/bin/bash

# Installed to /lib/systemd/system-shutdown/, systemd runs every executable
# in that directory at the very end of shutdown -- after all services are
# stopped and filesystems are unmounted, immediately before the kernel
# actually halts/powers off/reboots -- passing the action as $1.
#
# This gives the case's power-cutoff circuit an explicit, deterministic
# "safe to cut power" signal on GPIO4 instead of relying on it incidentally
# dropping as the kernel tears down the GPIO subsystem.

case "$1" in
	poweroff|halt)
		python3 -c "import RPi.GPIO as GPIO; GPIO.setmode(GPIO.BCM); GPIO.setup(4, GPIO.OUT); GPIO.output(4, GPIO.LOW)"
		;;
esac
