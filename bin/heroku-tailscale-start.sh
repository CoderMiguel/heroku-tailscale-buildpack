#!/usr/bin/env bash

set -e

if [ -z "$TAILSCALE_AUTH_KEY" ]; then
  echo "[tailscale]: Will not be available because TAILSCALE_AUTH_KEY is not set"
  exit 0
fi

wait_for_tailscale_running() {
  timeout=${TAILSCALE_RUNNING_TIMEOUT:-5} # Timeout in seconds
  interval=0.5  # Interval between checks

  # convert to milliseconds so we can use integer math
  timeout_ms=$(awk "BEGIN {print $timeout * 1000}")
  interval_ms=$(awk "BEGIN {print $interval * 1000}")

  elapsed=0

  while [ "$elapsed" -lt "$timeout_ms" ]; do
    state=$(tailscale status -json | jq -r .BackendState)
    echo "[tailscale]: ($elapsed < $timeout_ms) Current backend state: $state"
    if [ "$state" = "Running" ]; then
      return 0
    fi
    sleep "$interval"
    elapsed=$((elapsed + interval_ms))
  done

  return 1
}

if [ -z "$TAILSCALE_HOSTNAME" ]; then
  HEROKU_APP_NAME=${HEROKU_APP_NAME:-$APP_NAME}

  if [ -z "$HEROKU_APP_NAME" ]; then
    TAILSCALE_HOSTNAME=$(hostname)
  else
    # Only use the first 8 characters of the commit sha.
    # Swap the . and _ in the dyno with a - since tailscale doesn't
    # allow for periods.
    DYNO=${DYNO//./-}
    DYNO=${DYNO//_/-}
    TAILSCALE_HOSTNAME="heroku-$HEROKU_APP_NAME-${HEROKU_SLUG_COMMIT:0:8}-$DYNO"
  fi
else
  TAILSCALE_HOSTNAME="$TAILSCALE_HOSTNAME"
fi
tailscaled -cleanup > /dev/null 2>&1

(tailscaled -verbose ${TAILSCALED_VERBOSE:--1} \
            --tun=userspace-networking \
            --socks5-server=localhost:1055 > /dev/null 2>&1 &)
tailscale up \
  --authkey="${TAILSCALE_AUTH_KEY}" \
  --hostname="$TAILSCALE_HOSTNAME" \
  --advertise-tags=${TAILSCALE_ADVERTISE_TAGS:-} \
  ${TAILSCALE_ADDITIONAL_ARGS:---accept-routes --timeout=15s}

#export ALL_PROXY=socks5://localhost:1055/
#export HTTP_PROXY=http://localhost:1055/
#export http_proxy=http://localhost:1055/ ./my-app

if wait_for_tailscale_running; then
  echo "[tailscale]: Connected to tailnet as hostname=$TAILSCALE_HOSTNAME; SOCKS5 proxy available at localhost:1055"
  echo "[tailscale]: Status = > $(tailscale status)"
else
  echo "[tailscale]: Warning - Backend did not reach 'Running' state within timeout"
fi
