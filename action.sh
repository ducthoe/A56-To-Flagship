#!/system/bin/sh

MODDIR=${0%/*}
echo "A56 To Flagship: return to stock"
echo
echo "This will reset the Samsung apps replaced by the port,"
echo "remove the added AI apps, and mark this module for removal."
echo "Affected app settings and private data will be deleted. No backups."
echo "Gallery photos and launcher layout are not reset."
echo "Run this BEFORE removing KernelSU. Reboot after it finishes."
echo
echo "VOLUME DOWN: confirm uninstall"
echo "VOLUME UP: cancel"
echo "No key within 30 seconds: cancel"

EVENT_FILE=$(mktemp "$MODDIR/.uninstall-key.XXXXXX") || exit 1
EVENT_PID=
cleanup() {
  if [ -n "$EVENT_PID" ]; then
    kill "$EVENT_PID" 2>/dev/null || true
    wait "$EVENT_PID" 2>/dev/null || true
  fi
  rm -f "$EVENT_FILE"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

getevent -ql > "$EVENT_FILE" 2>/dev/null &
EVENT_PID=$!
ATTEMPTS=0
CHOICE=
while [ "$ATTEMPTS" -lt 300 ] && kill -0 "$EVENT_PID" 2>/dev/null; do
  CHOICE=$(awk '
    /EV_KEY[[:space:]]+KEY_VOLUMEDOWN[[:space:]]+DOWN/ { print "down"; exit }
    /EV_KEY[[:space:]]+KEY_VOLUMEUP[[:space:]]+DOWN/ { print "up"; exit }
  ' "$EVENT_FILE")
  [ -n "$CHOICE" ] && break
  sleep 0.1
  ATTEMPTS=$((ATTEMPTS + 1))
done
cleanup
EVENT_PID=
trap - EXIT INT TERM

if [ "$CHOICE" != down ]; then
  echo "Cancelled. Nothing was uninstalled."
  exit 0
fi

echo "Uninstall confirmed. Keep KernelSU installed until this finishes."
exec sh "$MODDIR/restore-stock.sh" --confirmed
