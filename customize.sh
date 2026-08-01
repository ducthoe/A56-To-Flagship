#!/system/bin/sh

SUITE_META=/data/adb/metamodule
META_MNT=$SUITE_META/mnt

[ -f "$SUITE_META/metainstall.sh" ] || abort "! meta-overlayfs is required"
[ -d "$MODPATH/system" ] || abort "! Module payload is incomplete"

if ! mountpoint -q "$META_MNT" 2>/dev/null; then
  mkdir -p "$META_MNT"
  chcon u:object_r:ksu_file:s0 "$SUITE_META/modules.img" 2>/dev/null || true
  mount -t ext4 -o loop,rw,noatime "$SUITE_META/modules.img" "$META_MNT" || \
    abort "! Failed to mount meta-overlayfs modules image"
fi

rm -rf "$META_MNT/a56_to_flagship" || abort "! Failed to replace prior A56 to Flagship payload"

find "$MODPATH/system" -type f -name '*.apk' -exec touch {} \; || true

label_tree() {
  SOURCE=$1
  REFERENCE=$2
  [ -d "$SOURCE" ] || return 0
  [ -e "$REFERENCE" ] || return 0
  find "$SOURCE" -exec chcon --reference="$REFERENCE" {} \; 2>/dev/null || true
}

label_tree "$MODPATH/system" /system
label_tree "$MODPATH/vendor" /vendor
label_tree "$MODPATH/vendor/lib64" /vendor/lib64

chcon --reference=/system/cameradata/camera-feature.xml \
  "$MODPATH/system/cameradata/camera-feature.xml" 2>/dev/null || true
chcon --reference=/system/lib64/libC2paDps.camera.samsung.so \
  "$MODPATH/system/lib64/libC2paDps.camera.samsung.so" 2>/dev/null || true
chcon --reference=/system/lib64/libandroid_runtime.so \
  "$MODPATH/system/lib64/libandroid_runtime.so" 2>/dev/null || true
chcon --reference=/system/lib64/libgui.so \
  "$MODPATH/system/lib64/libgui.so" 2>/dev/null || true
chcon --reference=/system/lib64/libui.so \
  "$MODPATH/system/lib64/libui.so" 2>/dev/null || true
chcon --reference=/system/etc/floating_feature.xml \
  "$MODPATH/system/etc/floating_feature.xml" 2>/dev/null || true
chcon --reference=/system/bin/surfaceflinger \
  "$MODPATH/system/bin/surfaceflinger" 2>/dev/null || true
chcon --reference=/vendor/lib64/hw/camera.s5e8855.so \
  "$MODPATH/vendor/lib64/hw/camera.s5e8855.so" 2>/dev/null || true

META_MODDIR=/data/adb/modules/meta-overlayfs
if [ -d "$META_MODDIR" ] && [ -f "$MODPATH/late-load.sh" ]; then
  cp "$MODPATH/late-load.sh" "$META_MODDIR/service.sh"
  chmod 755 "$META_MODDIR/service.sh"
  chcon u:object_r:ksu_file:s0 "$META_MODDIR/service.sh" 2>/dev/null || true
  ui_print "- late-load helper installed"
fi
