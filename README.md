# NESPi4 Case — RetroFlag Safe Shutdown (Raspberry Pi 4B, Debian)

Fork of the official [RetroFlag/retroflag-picase](https://github.com/RetroFlag/retroflag-picase) scripts, trimmed and updated for a RetroFlag NESPi4 case on a Raspberry Pi 4B running plain Debian (Bookworm/Trixie).

### Turn switch "SAFE SHUTDOWN" to ON.

### Install
1. Make sure internet is connected.
2. In a terminal, run:

```
wget -O - "https://raw.githubusercontent.com/namanert/retroflag-picase-customized/master/install.sh" | sudo bash
```

### Undo a previous install run
If you already ran an older version of `install.sh` (the one that wrote to `/boot/config.txt` instead of `/boot/firmware/config.txt`), clean up its leftovers with:

```
wget -O - "https://raw.githubusercontent.com/namanert/retroflag-picase-customized/master/cleanup_legacy_install.sh" | sudo bash
```
