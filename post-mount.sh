#!/system/bin/sh

MODDIR=${0%/*}
PAYLOAD=$MODDIR/system/vendor/lib64/hw/camera.s5e8855.so
[ -f "$MODDIR/disable" ] && exit 0
[ -f "$MODDIR/remove" ] && exit 0
[ -f "$PAYLOAD" ] || exit 0

# Late-load runs before mounting; restart the provider only after our HAL is visible.
EXPECTED=$(sha256sum "$PAYLOAD" | cut -d ' ' -f 1)
CURRENT=$(sha256sum /vendor/lib64/hw/camera.s5e8855.so 2>/dev/null | cut -d ' ' -f 1)
if [ -n "$EXPECTED" ] && [ "$CURRENT" = "$EXPECTED" ]; then
  pkill -f '[v]endor.samsung.hardware.camera.provider' 2>/dev/null || true
fi
exit 0
