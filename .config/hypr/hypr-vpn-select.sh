#!/usr/bin/env bash
set -euo pipefail

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

# --- Minimal user feedback (Option A): desktop notifications ---
notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  # usage: notify "Title" "Body"
  notify-send -a "VPN" "$1" "${2:-}"
}

# --- Pick country with fuzzel ---
choice="$(printf '%s\n' "$entries" | fuzzel --dmenu \
  --prompt='Country: ' \
  --width=23 \
  --lines=15 \
)"

# User hit Esc / no selection
[[ -z "${choice:-}" ]] && exit 0

if [[ "$choice" == "DISCONNECT" ]]; then
  notify "ProtonVPN" "Disconnecting…"
  if protonvpn disconnect; then
    notify "ProtonVPN" "Disconnected ✅"
    exit 0
  else
    notify "ProtonVPN" "Disconnect FAILED ❌"
    exit 1
  fi
fi

# --- Resolve a ProtonVPN country code robustly, regardless of word count ---
# We scan each line from `protonvpn countries` and try to match the start-of-line
# country name to the exact selected country. When it matches, we emit the *next*
# field, which is the country code your old script was extracting via awk $2/$3/$4.
cc="$(
  protonvpn countries list | awk -v target="$choice" '
    {
      name=""
      for (i=1; i<=NF; i++) {
        name = (i==1 ? $i : name " " $i)
        if (name == target) {
          if (i+1 <= NF) { print $(i+1); exit 0 }
          exit 1
        }
      }
    }
  '
)"


if [[ -z "${cc:-}" ]]; then
  notify "ProtonVPN" "Could not resolve country code for: $choice ❌"
  exit 1
fi

notify "ProtonVPN" "Connecting to: $choice…"

if protonvpn connect --country "$cc"; then
  notify "ProtonVPN" "Connected: $choice ✅"
else
  notify "ProtonVPN" "Connection FAILED: $choice ❌"
  exit 1
fi
