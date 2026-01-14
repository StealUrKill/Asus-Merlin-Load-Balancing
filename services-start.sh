#!/bin/sh
sleep 60

# Dual WAN enabled?
DW="$(nvram get wans_dualwan)"
# Example values vary, but empty/"0" usually means disabled
[ -z "$DW" ] && exit 0
[ "$DW" = "0" ] && exit 0

# Load balance mode? (var name can vary by firmware)
MODE="$(nvram get wans_mode)"
# Common: "lb" or "1" depending on build
case "$MODE" in
  lb|1) service restart_wan ;;
  *) exit 0 ;;
esac
