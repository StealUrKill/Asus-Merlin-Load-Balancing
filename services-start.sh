#!/bin/sh
# /jffs/scripts/services-start
# Dual-WAN Load Balance boot fix: delayed restart_wan
# Also includes a simple menu to configure delay (stored in nvram)

DELAY_KEY="wanlb_restart_delay"
DEFAULT_DELAY="60"

get_delay() {
  d="$(nvram get "$DELAY_KEY" 2>/dev/null)"
  [ -z "$d" ] && d="$DEFAULT_DELAY"
  echo "$d"
}

set_delay() {
  cur="$(get_delay)"
  echo
  echo "Current delay: ${cur} seconds"
  echo "Enter new delay in seconds (10-600), blank to cancel:"
  printf "> "
  read -r newd
  newd="${newd//[$'\t\r\n']/}"

  [ -z "$newd" ] && echo "Canceled." && return 0

  case "$newd" in
    *[!0-9]* ) echo "Invalid: must be a number." ; return 1 ;;
  esac

  [ "$newd" -lt 10 ] && echo "Too small (min 10)." && return 1
  [ "$newd" -gt 600 ] && echo "Too large (max 600)." && return 1

  nvram set "$DELAY_KEY=$newd"
  nvram commit
  echo "Saved: $DELAY_KEY=$newd"
}

menu() {
  while :; do
    echo
    echo "Dual-WAN Load Balance boot restart_wan helper"
    echo "--------------------------------------------"
    echo "1) Set delay before restart_wan (seconds)"
    echo "2) Show current settings"
    echo "3) Run now (simulate boot action)"
    echo "4) Disable (set delay to 0 = do nothing)"
    echo "5) Exit"
    printf "> "
    read -r choice
    choice="${choice//[$'\t\r\n']/}"

    case "$choice" in
      1) set_delay ;;
      2)
        echo
        echo "Delay key: $DELAY_KEY"
        echo "Delay:     $(get_delay) seconds"
        ;;
      3)
        echo
        echo "Running now..."
        main_run
        ;;
      4)
        nvram set "$DELAY_KEY=0"
        nvram commit
        echo "Disabled (set $DELAY_KEY=0)"
        ;;
      5|q|Q|exit) exit 0 ;;
      *) echo "Invalid selection." ;;
    esac
  done
}

main_run() {
  # delay
  DELAY="$(get_delay)"
  [ "$DELAY" = "0" ] && exit 0

  sleep "$DELAY"

  # Dual WAN enabled?
  DW="$(nvram get wans_dualwan 2>/dev/null)"
  [ -z "$DW" ] && exit 0
  [ "$DW" = "0" ] && exit 0

  # Load balance mode?
  MODE="$(nvram get wans_mode 2>/dev/null)"
  case "$MODE" in
    lb|1) service restart_wan ;;
    *) exit 0 ;;
  esac
}

case "$1" in
  menu|config|setup) menu ;;
  run) main_run ;;
  *) main_run ;;   # default = boot behavior
esac
