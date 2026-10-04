#!/bin/bash
# status: exit 0 = wlsunset running
case "${1:?on|off|status}" in
  on)     pgrep -x wlsunset >/dev/null || exec "$HOME/.local/bin/wlsunset-start.sh" ;;
  off)    pkill -x wlsunset ;;
  status) pgrep -x wlsunset ;;
esac
