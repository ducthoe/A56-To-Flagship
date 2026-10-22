#!/system/bin/sh

chown 1000:1000 /dev/cam_throughput /dev/intcam_throughput || exit 1
chmod 0600 /dev/cam_throughput /dev/intcam_throughput
