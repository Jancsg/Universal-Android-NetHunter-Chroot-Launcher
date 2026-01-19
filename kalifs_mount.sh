#!/system/bin/sh
# Universal Android NetHunter Chroot Launcher
set -euo pipefail

readonly KALI_HOME="${1:-/data/local/nhsystem/kalifs/kali-arm64}"
readonly MOUNTS=("dev/pts" "dev" "proc" "sys" "sdcard" "storage/emulated/0" "android")

# Initial validation
if [ ! -d "$KALI_HOME" ]; then
    echo "Error: KALI_HOME directory not found: $KALI_HOME" >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Root privileges required" >&2
    exit 1
fi

# Cleanup on exit (trap)
cleanup() {
    echo "[!] Unmounting filesystems..."
    for mnt in "${MOUNTS[@]}"; do
        if mountpoint -q "$KALI_HOME/$mnt" 2>/dev/null; then
            umount -l "$KALI_HOME/$mnt" || true
        fi
    done
}
trap cleanup EXIT

# Deep cleanup before starting
for mnt in "${MOUNTS[@]}"; do
    if mountpoint -q "$KALI_HOME/$mnt" 2>/dev/null; then
        umount -l "$KALI_HOME/$mnt" || true
    fi
done

# Bind Mounts
mount -o bind /dev "$KALI_HOME/dev"
mount -t devpts devpts "$KALI_HOME/dev/pts"
mount -t proc proc "$KALI_HOME/proc"
mount -t sysfs sysfs "$KALI_HOME/sys"
mount -o bind /sdcard "$KALI_HOME/sdcard" || true
mount -o bind /storage/emulated/0 "$KALI_HOME/storage/emulated/0" || true
mount -o bind / "$KALI_HOME/android" || true

# Robust Networking Fix
if [ -f "$KALI_HOME/etc/group" ]; then
    if ! grep -q "^aid_inet:" "$KALI_HOME/etc/group"; then
        echo "aid_inet:x:3003:root" >> "$KALI_HOME/etc/group"
    fi
fi

# DNS Fix: Overwrite resolv.conf to fix repository resolution issues
echo "nameserver 8.8.8.8" > "$KALI_HOME/etc/resolv.conf"
echo "nameserver 8.8.4.4" >> "$KALI_HOME/etc/resolv.conf"

# Enter Chroot with terminal control environment
exec chroot "$KALI_HOME" /usr/bin/env -i \
    HOME=/root \
    TERM=xterm-256color \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /bin/bash --login
