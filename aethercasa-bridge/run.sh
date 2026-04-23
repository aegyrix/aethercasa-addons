#!/usr/bin/with-contenv bashio
# Run script for the AetherCasa Bridge add-on.
# Reads user options from /data/options.json via bashio helpers and execs the
# bridge. SUPERVISOR_TOKEN is injected automatically by Supervisor and picked
# up by packages/bridge/src/config.ts when HA_TOKEN is not set.

set -e

PAIRING_CODE="$(bashio::config 'pairing_code')"
CLOUD_URL="$(bashio::config 'cloud_url')"
LOG_LEVEL="$(bashio::config 'log_level')"

export AETHERCASA_CLOUD_URL="${CLOUD_URL:-https://api.aethercasa.app}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

# Only export the pairing code on first boot. After that, /data/bridge.json
# is the persistent identity and the code is ignored (and should be blanked
# in add-on options by the user — we guard here just in case).
if [[ -n "$PAIRING_CODE" && ! -f /data/bridge.json ]]; then
  bashio::log.info "Pairing with code (first-boot)…"
  export AETHERCASA_PAIRING_CODE="$PAIRING_CODE"
elif [[ ! -f /data/bridge.json ]]; then
  bashio::exit.nok "No bridge identity yet — please set 'pairing_code' in the add-on options."
fi

exec node /app/dist/index.js
