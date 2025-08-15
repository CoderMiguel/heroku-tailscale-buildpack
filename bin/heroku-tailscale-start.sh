#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/buildpack_helpers/tailscale_bash"

set -e

if [ -z "$TAILSCALE_AUTH_KEY" ]; then
  log_tailscale_info "skipping tailnet start-up because TAILSCALE_AUTH_KEY is not set"
#  exit 0
else
## TODO: configure allowed dyno types with override ENV variable
  #tailscaled -cleanup > /dev/null 2>&1
  #

  #set_tailscale_hostname
  #log "$TAILSCALE_HOSTNAME"
  #
  #(tailscaled -verbose ${TAILSCALED_VERBOSE:--1} \
  #            --tun=userspace-networking \
  #            --socks5-server=localhost:1055 > /dev/null 2>&1 &)
  #tailscale up \
  #  --authkey="${TAILSCALE_AUTH_KEY}" \
  #  --hostname="$TAILSCALE_HOSTNAME" \
  #  --advertise-tags=${TAILSCALE_ADVERTISE_TAGS:-} \
  #  ${TAILSCALE_ADDITIONAL_ARGS:---accept-routes --timeout=15s}

  start_tailscale_daemon > /dev/null 2>&1 &
  connect_to_tailnet

  if tailscale_running; then
    tailscale_log "Connected to tailnet as hostname=$TAILSCALE_HOSTNAME; SOCKS5 proxy available at localhost:1055"
    tailscale serve --bg $PORT # expose the Heroku dyno port to the tailnet
#    exit 0
  else
    tailscale_log "Warning - Backend did not reach 'Running' state within timeout"
    exit 1
  fi
fi
