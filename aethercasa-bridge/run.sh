#!/usr/bin/with-contenv bashio
# Run script for the AetherCasa Bridge add-on.
# Reads user options from /data/options.json via bashio helpers and execs the
# bridge. SUPERVISOR_TOKEN is injected automatically by Supervisor and picked
# up by packages/bridge/src/config.ts when HA_TOKEN is not set.

set -e
set -o pipefail

PAIRING_CODE="$(bashio::config 'pairing_code')"
CLOUD_URL="$(bashio::config 'cloud_url')"
LOG_LEVEL="$(bashio::config 'log_level')"

CLOUD_URL="${CLOUD_URL:-https://api.aethercasa.app}"

# The add-on schema's 'url' type accepts http://, but pairing hands this bridge
# a long-lived credential and the relay carries full control of the home, so a
# cleartext endpoint would let any LAN MITM claim the bridge. Refuse non-TLS.
if [[ "$CLOUD_URL" != https://* ]]; then
  bashio::exit.nok "cloud_url must use https:// — refusing to pair or relay over cleartext."
fi

export AETHERCASA_CLOUD_URL="$CLOUD_URL"
export LOG_LEVEL="${LOG_LEVEL:-info}"

# First boot only. Once /data/bridge.json exists it is the persistent identity
# and any leftover pairing code in the add-on options is ignored. With no code
# configured the bridge self-pairs via device flow; the code path is legacy.
if [[ ! -f /data/bridge.json ]]; then
  if bashio::config.has_value 'pairing_code'; then
    bashio::log.info "Pairing with code (first-boot)…"
    export AETHERCASA_PAIRING_CODE="$PAIRING_CODE"
  else
    # No code configured: fall through to device-flow pairing, which prints an
    # activation URL + user code to this log for approval in the web app.
    bashio::log.info "No bridge identity yet — starting device-flow pairing."
    bashio::log.info "Watch this log for the activation URL and code."
  fi
fi

exec node /app/dist/index.js
