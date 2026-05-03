#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/tmp/hypr_vpn_select_errors.log"

entries="
DISCONNECT
Afghanistan
Albania
Algeria
Angola
Argentina
Armenia
Australia
Austria
Azerbaijan
Bahrain
Bangladesh
Belarus
Belgium
Bhutan
Bosnia and Herzegovina
Brazil
Brunei
Bulgaria
Cambodia
Cameroon
Canada
Chad
Chile
Colombia
Comoros
Costa Rica
Croatia
Cuba
Cyprus
Czech Republic
Denmark
Dominican Republic
Ecuador
Egypt
El Salvador
Eritrea
Estonia
Ethiopia
Finland
France
Georgia
Germany
Ghana
Greece
Guatemala
Honduras
Hong Kong
Hungary
Iceland
India
Indonesia
Iraq
Ireland
Israel
Italy
Ivory Coast
Japan
Jordan
Kazakhstan
Kenya
Kuwait
Laos
Latvia
Libya
Lithuania
Luxembourg
Macedonia
Malaysia
Malta
Mauritania
Mauritius
Mexico
Moldova
Mongolia
Montenegro
Morocco
Mozambique
Myanmar
Nepal
Netherlands
New Zealand
Nigeria
Norway
Oman
Pakistan
Palestinian Territory
Panama
Peru
Philippines
Poland
Portugal
Puerto Rico
Qatar
Romania
Russia
Rwanda
Saudi Arabia
Senegal
Serbia
Singapore
Slovakia
Slovenia
Somalia
South Africa
South Korea
South Sudan
Spain
Sri Lanka
Sudan
Sweden
Switzerland
Syria
Taiwan
Tajikistan
Tanzania
Thailand
Togo
Tunisia
Turkey
Turkmenistan
Uganda
Ukraine
United Arab Emirates
United Kingdom
United States
Uzbekistan
Venezuela
Vietnam
Yemen
"

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a "VPN" "$1" "${2:-}"
}

log_error() {
  local msg="$1"

  # Keep the log private-ish when created by this script.
  umask 077

  {
    printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')" "$msg"
  } >> "$LOG_FILE" 2>/dev/null || true

  chmod 600 "$LOG_FILE" 2>/dev/null || true
}

require_cmd() {
  local cmd="$1"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Missing required command: $cmd"
    notify "VPN picker FAILED ❌" "Missing required command: $cmd"
    exit 1
  fi
}

run_logged() {
  local desc="$1"
  shift

  local tmp rc
  tmp="$(mktemp "${TMPDIR:-/tmp}/hypr_vpn_select.XXXXXX")"

  if "$@" >"$tmp" 2>&1; then
    rm -f "$tmp"
    return 0
  fi

  rc=$?

  {
    printf '\n[%s] FAILED: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')" "$desc"
    printf 'exit_code: %s\n' "$rc"
    printf 'command:'
    printf ' %q' "$@"
    printf '\n'
    sed 's/^/output: /' "$tmp"
  } >> "$LOG_FILE" 2>/dev/null || true

  chmod 600 "$LOG_FILE" 2>/dev/null || true
  rm -f "$tmp"

  return "$rc"
}

require_cmd fuzzel
require_cmd protonvpn

# Pick country with fuzzel.
# Esc/cancel exits cleanly and does not log as a failure.
if ! choice="$(printf '%s\n' "$entries" | fuzzel --dmenu \
  --prompt='Country: ' \
  --width=23 \
  --lines=15 \
)"; then
  exit 0
fi

# User selected blank / no selection.
[[ -z "${choice:-}" ]] && exit 0

if [[ "$choice" == "DISCONNECT" ]]; then
  notify "ProtonVPN" "Disconnecting…"

  if run_logged "ProtonVPN disconnect" protonvpn disconnect; then
    notify "ProtonVPN" "Disconnected ✅"
    exit 0
  else
    notify "ProtonVPN" "Disconnect FAILED ❌"
    exit 1
  fi
fi

notify "ProtonVPN" "Connecting to: $choice…"

# Newer Proton CLI accepts full country names directly.
# This avoids parsing `protonvpn countries list`, which is more likely to break
# when the CLI output format changes.
if run_logged "ProtonVPN connect to country: $choice" protonvpn connect --country "$choice"; then
  notify "ProtonVPN" "Connected: $choice ✅"
else
  notify "ProtonVPN" "Connection FAILED: $choice ❌"
  notify "ProtonVPN" "Logged failure to /tmp/hypr_vpn_select_errors.log"
  exit 1
fi
