#!/usr/bin/env bash

. "$(dirname "${BASH_SOURCE[0]}")/buildpack_helpers/tailscale_bash"

set -e

if [ -z "$TAILSCALE_AUTH_KEY" ]; then
  log_tailscale_info "skipping tailnet start-up because TAILSCALE_AUTH_KEY is not set"
else
  # TODO: configure allowed dyno types with override ENV variable
  start_tailscale_daemon

  if connect_to_tailnet; then
    expose_heroku_port_to_tailnet
  else
    log_tailscale_error "$(tailscale status)"
    exit 1
  fi
fi
