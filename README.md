
# Android NetHunter Chroot Launcher

A robust, root-level shell script designed to launch a Kali Linux NetHunter chroot environment on Android devices (optimized for modern devices like the S23 Ultra). This script fixes common issues with terminal signals (Ctrl+C), networking permissions, and storage mounting.

## 🚀 Key Problems It Solves

* **Broken Job Control (Ctrl+C):** Standard chroot entries often fail to pass keyboard signals. By mounting `devpts` correctly, this script restores the ability to interrupt processes (SIGINT).
* **Networking Permissions:** Fixes the infamous `socket: Permission denied` error in Kali by mapping the Android `aid_inet` GID (3003) within the chroot.
* **Android Root Visibility:** Unlike standard launchers, this mounts the Android root `/` into `/android` inside Kali, allowing you to audit the host system's files.
* **Mount Pollution:** Uses a clean `trap` mechanism and `mountpoint` checks to ensure that filesystems are unmounted gracefully, preventing "Device or resource busy" errors on subsequent runs.

## 🛠 Features

* **Robust Cleanup:** Automatically unmounts all virtual filesystems on exit.
* **Modern Shell Best Practices:** Implements `pipefail` and `nounset` for safer execution.
* **Dynamic Pathing:** Accepts a custom path as an argument or defaults to the standard NetHunter directory.
* **Full Storage Access:** Maps both `/sdcard` and `/storage/emulated/0` for maximum compatibility with Android's storage scoped runtime.

## 📋 Prerequisites

* A **rooted** Android device.
* A Kali Linux ARM64 rootfs extracted on your internal storage.
* Terminal emulator (e.g., Termux).

## 💻 Usage

1. Move the script to an executable partition (e.g., `/data/local/`):
```bash
cp launcher.sh /data/local/nh.sh
chmod +x /data/local/nh.sh

```


2. Run as root:
```bash
su -c /data/local/nh.sh

```


3. (Optional) Pass a custom rootfs path:
```bash
su -c "/data/local/nh.sh /your/custom/path"

```


## 📝 Technical Details

The script performs the following mounts to bridge Android with Kali:

| Mount Point | Type | Purpose |
| --- | --- | --- |
| `/dev` | bind | Hardware access |
| `/dev/pts` | devpts | Pseudo-terminals (Fixes Ctrl+C) |
| `/proc` & `/sys` | virtual | Kernel interface & Process info |
| `/` | bind | Direct access to Android OS from Kali |

