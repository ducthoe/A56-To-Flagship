#!/system/bin/sh

[ -d "$MODPATH/system" ] || abort "! Module payload is incomplete"

find "$MODPATH/system" -type f -name '*.apk' -exec touch {} \; || true

label_tree() {
  SOURCE=$1
  REFERENCE=$2
  [ -d "$SOURCE" ] || return 0
  [ -e "$REFERENCE" ] || return 0
  find "$SOURCE" -print | while IFS= read -r ENTRY; do
    RELATIVE=${ENTRY#"$SOURCE"}
    LABEL_FROM=$REFERENCE$RELATIVE
    while [ ! -e "$LABEL_FROM" ] && [ "$LABEL_FROM" != / ]; do
      LABEL_FROM=${LABEL_FROM%/*}
      [ -n "$LABEL_FROM" ] || LABEL_FROM=/
    done
    chcon --reference="$LABEL_FROM" "$ENTRY" 2>/dev/null || true
  done
}

set_perm_recursive "$MODPATH/system" 0 0 0755 0644
set_perm "$MODPATH/system/bin/surfaceflinger" 0 2000 0755
set_perm "$MODPATH/post-mount.sh" 0 0 0755
set_perm "$MODPATH/boot-completed.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/restore-stock.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

label_tree "$MODPATH/system" /system
label_tree "$MODPATH/system/vendor" /vendor
chcon u:object_r:vendor_file:s0 "$MODPATH/system/vendor/lib64/hw/camera.s5e8855.so"
touch "$MODPATH/.restore-port-packages"
ui_print "- One UI 9 payload prepared"
ui_print "- Mount backend: Magic Mount-rs"
ui_print "- Camera helper runs after mounting, including late-load mode"
ui_print "- To uninstall before unrooting: Action, then Volume Down"
