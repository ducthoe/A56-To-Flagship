#!/system/bin/sh

MODDIR=${0%/*}
PLAN=$MODDIR/cleanup-packages.list
CACHE_PLAN=$MODDIR/cleanup-cache.list

if [ "${1:-}" != --confirmed ]; then
  echo "Use the module Action button and confirm with Volume Down."
  exit 1
fi
if [ "$(id -u)" != 0 ]; then
  echo "Root is needed now. Run the Action before removing KernelSU."
  exit 1
fi
if [ "$(getprop sys.boot_completed)" != 1 ] || ! pm list users >/dev/null 2>&1; then
  echo "Wait for Android to finish booting, then use the Action again."
  exit 1
fi
[ -r "$PLAN" ] || { echo "Missing cleanup package list."; exit 1; }
[ -r "$CACHE_PLAN" ] || { echo "Missing parser cache list."; exit 1; }

mkdir "$MODDIR/.restore-running" 2>/dev/null || { echo "Stock restore is already running."; exit 1; }
trap 'rmdir "$MODDIR/.restore-running" 2>/dev/null || true' EXIT
trap 'exit 130' INT TERM
USERS=$(pm list users | sed -n 's/.*UserInfo{\([0-9][0-9]*\):.*/\1/p')
[ -n "$USERS" ] || { echo "Cannot determine Android user IDs."; exit 1; }

installed_for_user() {
  pm list packages --user "$1" "$2" 2>/dev/null | grep -Fxq "package:$2"
}

FAILED=0
while read -r MODE PACKAGE; do
  case "$MODE" in stock|port) ;; *) continue ;; esac
  echo "Restoring $PACKAGE..."
  for USER_ID in $USERS; do
    installed_for_user "$USER_ID" "$PACKAGE" || continue
    am force-stop --user "$USER_ID" "$PACKAGE" >/dev/null 2>&1 || true
  done
  if [ "$MODE" = stock ]; then
    # Keep the system APK; drop a downloaded update only when one is installed.
    PATHS=$(pm path "$PACKAGE" 2>/dev/null)
    case "$PATHS" in
      *package:/data/app/*)
        if ! pm uninstall-system-updates "$PACKAGE"; then
          FAILED=1
          continue
        fi
        ;;
    esac
  fi
  for USER_ID in $USERS; do
    installed_for_user "$USER_ID" "$PACKAGE" || continue
    if [ "$MODE" = stock ]; then
      RESULT=$(pm clear --user "$USER_ID" "$PACKAGE" 2>&1)
    else
      RESULT=$(pm uninstall --user "$USER_ID" "$PACKAGE" 2>&1)
    fi
    echo "$RESULT"
    case "$RESULT" in *Success*) ;; *) FAILED=1 ;; esac
    am force-stop --user "$USER_ID" "$PACKAGE" >/dev/null 2>&1 || true
  done
done < "$PLAN"

echo "Removing cached donor APK metadata..."
while IFS= read -r APK_DIR; do
  [ -n "$APK_DIR" ] || continue
  for CACHE_DIR in /data/system/package_cache/*; do
    [ -d "$CACHE_DIR" ] || continue
    for CACHE_FILE in "$CACHE_DIR/$APK_DIR"-*; do
      [ -f "$CACHE_FILE" ] || continue
      echo "Removing parser cache: ${CACHE_FILE##*/}"
      rm -f "$CACHE_FILE" || FAILED=1
    done
  done
done < "$CACHE_PLAN"

if [ "$FAILED" != 0 ]; then
  echo "Some cleanup failed. Keep KernelSU, fix the error above, then retry."
  exit 1
fi

am force-stop com.sec.android.app.camera >/dev/null 2>&1 || true
sh "$MODDIR/uninstall.sh" || exit 1
touch "$MODDIR/disable" "$MODDIR/remove" || exit 1
echo
echo "Stock restore prepared. This module is marked for removal."
echo "You can now remove KernelSU and reboot."
echo "No root script is needed after reboot."
echo "Reboot to reload the stock APK metadata and remove the mounts."
echo "Affected app settings and private data were deleted."
