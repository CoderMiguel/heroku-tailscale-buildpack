#!/usr/bin/env bash

set -e

. ./logging

#wait_for_tailscale_running() {
#  timeout=${TAILSCALE_RUNNING_TIMEOUT:-5} # Timeout in seconds
#  interval=0.5  # Interval between checks
#
#  # convert to milliseconds so we can use integer math
#  timeout_ms=$(awk "BEGIN {print $timeout * 1000}")
#  interval_ms=$(awk "BEGIN {print $interval * 1000}")
#
#  elapsed=0
#
#  while [ "$elapsed" -lt "$timeout_ms" ]; do
#    state=$(tailscale status -json | jq -r .BackendState)
#
#    if [ "$state" = "Running" ]; then
#      return 0
#    fi
#
#    sleep "$interval"
#
#    elapsed=$((elapsed + interval_ms))
#  done
#
#  return 1
#}

if [ -z "$TAILSCALE_AUTH_KEY" ]; then
  log "You need to add TAILSCALE_AUTH_KEY to your environment variables."
else
  log "Waiting to allow tailscale to finish set up."
  wait_for_tailscale_running
  log "Running 'tailscale status' You should see your accessible machines on your tailnet."
  tailscale status

#  log "Running `proxychains4 -f vendor/proxychains-ng/proxychains.conf curl hello.ts.net` "
#  log 'Things are working if you see <a href="https://hello.ts.net">Found</a>.'
#  proxychains4 -f vendor/proxychains-ng/proxychains.conf curl hello.ts.net
#  log "If you didn't see the Found message, then you may need to add the hello.ts.net machine into your tailnet."
#  log "Test complete. I hope you had your fingers crossed!"
fi
