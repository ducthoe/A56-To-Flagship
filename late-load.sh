#!/system/bin/sh

[ -f /data/adb/modules/meta-overlayfs/mnt/a56_to_flagship/vendor/lib64/hw/camera.s5e8855.so ] || exit 0
mount | grep -q "KSU on /vendor " || exit 0
pkill -f vendor.samsung.hardware.camera.provider
exit 0
