#!/system/bin/sh

MODDIR=${0%/*}
[ -f "$MODDIR/disable" ] && exit 0
[ -f "$MODDIR/remove" ] && exit 0
[ -f "$MODDIR/.restore-port-packages" ] || exit 0
USER_ID=$(am get-current-user 2>/dev/null)
case "$USER_ID" in ''|*[!0-9]*) exit 0 ;; esac

# A prior stock restore may have marked these system packages uninstalled for the user.
FAILED=0
while read -r MODE PACKAGE; do
  [ "$MODE" = port ] || continue
  if ! pm install-existing --user "$USER_ID" "$PACKAGE"; then
    FAILED=1
  fi
done < "$MODDIR/cleanup-packages.list"
[ "$FAILED" = 0 ] && rm -f "$MODDIR/.restore-port-packages"
exit 0
