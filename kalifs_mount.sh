#!/system/bin/sh
set -euo pipefail

readonly KALI_HOME="${1:-/data/local/nhsystem/kalifs/kali-arm64}"
readonly MOUNTS=("dev/pts" "dev" "proc" "sys" "sdcard" "storage/emulated/0" "android")

# Validación inicial
if [ ! -d "$KALI_HOME" ]; then
    echo "Error: KALI_HOME no existe: $KALI_HOME" >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Este script requiere privilegios de root" >&2
    exit 1
fi

# Cleanup en exit (trap)
cleanup() {
    echo "Desmontando filesystems..."
    for mnt in "${MOUNTS[@]}"; do
        if mountpoint -q "$KALI_HOME/$mnt" 2>/dev/null; then
            umount -l "$KALI_HOME/$mnt" || true
        fi
    done
}
trap cleanup EXIT

# Limpieza profunda
for mnt in "${MOUNTS[@]}"; do
    if mountpoint -q "$KALI_HOME/$mnt" 2>/dev/null; then
        umount -l "$KALI_HOME/$mnt" || true
    fi
done

# Montajes
mount -o bind /dev "$KALI_HOME/dev"
mount -t devpts devpts "$KALI_HOME/dev/pts"
mount -t proc proc "$KALI_HOME/proc"
mount -t sysfs sysfs "$KALI_HOME/sys"
mount -o bind /sdcard "$KALI_HOME/sdcard" || true
mount -o bind /storage/emulated/0 "$KALI_HOME/storage/emulated/0" || true
mount -o bind / "$KALI_HOME/android" || true

# Fix de Red - robusto
if [ -f "$KALI_HOME/etc/group" ]; then
    if ! grep -q "^aid_inet:" "$KALI_HOME/etc/group"; then
        echo "aid_inet:x:3003:root" >> "$KALI_HOME/etc/group"
    fi
fi

# Entrada con control de terminal
exec chroot "$KALI_HOME" /usr/bin/env -i \
    HOME=/root \
    TERM=xterm-256color \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /bin/bash --login
