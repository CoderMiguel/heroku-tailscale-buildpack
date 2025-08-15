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

  start_tailscale_daemon #


  if connect_to_tailnet; then
    # expose the Heroku dyno port to the tailnet
    tailscale serve --bg $PORT
  else
    log_tailscale_error "$(tailscale status)"
    exit 1
  fi
fi
