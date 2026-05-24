#!/usr/bin/env bash
set -euo pipefail

desktop_dirs=(
  "$HOME/.local/share/applications"
  "$HOME/.local/share/flatpak/exports/share/applications"
  /var/lib/flatpak/exports/share/applications
  /usr/local/share/applications
  /usr/share/applications
)

icon_dirs=(
  "$HOME/.local/share/icons"
  "$HOME/.icons"
  /usr/local/share/icons
  /usr/share/icons
  /usr/share/pixmaps
)

desktop_bases=()
desktop_names=()
desktop_icons=()
desktop_swms=()
desktop_entries_loaded=0
icon_file_result=""
icon_fallback_result=""

declare -A desktop_class_cache=()
declare -A icon_file_cache=()

desktop_value() {
  local key="$1" file="$2"

  awk -F= -v key="$key" '
    BEGIN { IGNORECASE=1 }
    $1 == key {
      sub(/\r$/, "", $2)
      print $2
      exit
    }
  ' "$file"
}

load_desktop_entries() {
  (( desktop_entries_loaded )) && return

  local dir file base name icon swm

  for dir in "${desktop_dirs[@]}"; do
    [[ -d "$dir" ]] || continue

    while IFS=$'\t' read -r file name icon swm; do
      [[ -n "$file" ]] || continue
      base="$(basename "$file" .desktop)"

      desktop_bases+=("${base,,}")
      desktop_names+=("$name")
      desktop_icons+=("$icon")
      desktop_swms+=("$swm")
    done < <(
      find "$dir" -type f -name '*.desktop' -exec awk -F= '
        function clean(value) {
          sub(/\r$/, "", value)
          gsub(/[\t\r\n]/, " ", value)
          return value
        }

        function emit() {
          if (file != "") {
            printf "%s\t%s\t%s\t%s\n", file, name, icon, tolower(swm)
          }
        }

        FNR == 1 {
          emit()
          file = FILENAME
          name = ""
          icon = ""
          swm = ""
        }

        {
          key = tolower($1)
          if (key == "name" && name == "") {
            name = clean($2)
          } else if (key == "icon" && icon == "") {
            icon = clean($2)
          } else if (key == "startupwmclass" && swm == "") {
            swm = clean($2)
          }
        }

        END { emit() }
      ' {} + 2>/dev/null
    )
  done

  desktop_entries_loaded=1
}

add_icon_candidate() {
  local candidate="$1"

  [[ -n "$candidate" ]] || return 0
  [[ ",$icon_candidates," == *",$candidate,"* ]] && return 0

  icon_candidates+="${icon_candidates:+,}$candidate"
}

icon_file_for_name() {
  local name="$1"
  local dir file
  icon_file_result=""

  [[ -n "$name" && "$name" != */* ]] || return 0

  if [[ -v "icon_file_cache[$name]" ]]; then
    icon_file_result="${icon_file_cache[$name]}"
    return
  fi

  for dir in "${icon_dirs[@]}"; do
    [[ -d "$dir" ]] || continue

    while IFS= read -r -d '' file; do
      icon_file_cache["$name"]="$file"
      icon_file_result="$file"
      return
    done < <(find "$dir" -type f \( -name "$name.png" -o -name "$name.svg" -o -name "$name.xpm" \) -print0 2>/dev/null)
  done

  icon_file_cache["$name"]=""
}

add_icon_files_for_name() {
  icon_file_for_name "$1"
  add_icon_candidate "$icon_file_result"
}

icon_fallbacks() {
  local desktop_icon="$1" desktop_id="$2"
  local icon_candidates=""
  shift 2

  add_icon_candidate "$desktop_icon"
  add_icon_files_for_name "$desktop_icon"

  add_icon_candidate "$desktop_id"
  add_icon_files_for_name "$desktop_id"

  local key
  for key in "$@"; do
    add_icon_candidate "$key"
    add_icon_files_for_name "$key"
  done

  add_icon_candidate application-x-executable
  icon_fallback_result="$icon_candidates"
}

class_lookup_keys() {
  local class="${1,,}"
  local key existing
  local keys=()

  while IFS= read -r key; do
    [[ -n "$key" ]] || continue

    for existing in "${keys[@]}"; do
      [[ "$existing" == "$key" ]] && continue 2
    done

    keys+=("$key")
  done < <(
    printf '%s\n' "$class"
    tr '.:_/ -' '\n' <<< "$class"
  )

  printf '%s\n' "${keys[@]}"
}

desktop_for_class() {
  local class="${1,,}"
  local base name icon swm match_type key i
  local keys=()

  if [[ -v "desktop_class_cache[$class]" ]]; then
    printf '%s\n' "${desktop_class_cache[$class]}"
    return
  fi

  load_desktop_entries

  mapfile -t keys < <(class_lookup_keys "$class")

  # Best case: .desktop explicitly declares StartupWMClass
  for key in "${keys[@]}"; do
    for i in "${!desktop_bases[@]}"; do
      swm="${desktop_swms[$i]}"

      [[ -n "$swm" && "$swm" == "$key" ]] || continue

      name="${desktop_names[$i]}"
      icon="${desktop_icons[$i]}"
      base="${desktop_bases[$i]}"

      icon_fallbacks "$icon" "$base" "${keys[@]}"
      desktop_class_cache["$class"]="${name:-$1}"$'\t'"$icon_fallback_result"
      printf '%s\n' "${desktop_class_cache[$class]}"
      return
    done
  done

  # Fallback: match class against desktop filename, preferring exact IDs.
  for key in "${keys[@]}"; do
    for match_type in exact suffix contains; do
      for i in "${!desktop_bases[@]}"; do
        base="${desktop_bases[$i]}"

        case "$match_type" in
          exact) [[ "$base" == "$key" ]] || continue ;;
          suffix) [[ "$base" == *".$key" ]] || continue ;;
          contains) [[ "$base" == *"$key"* ]] || continue ;;
        esac

        name="${desktop_names[$i]}"
        icon="${desktop_icons[$i]}"

        icon_fallbacks "$icon" "$base" "${keys[@]}"
        desktop_class_cache["$class"]="${name:-$1}"$'\t'"$icon_fallback_result"
        printf '%s\n' "${desktop_class_cache[$class]}"
        return
      done
    done
  done

  # Last-resort fallback
  icon_fallbacks "" "" "${keys[@]}"
  desktop_class_cache["$class"]="$1"$'\t'"$icon_fallback_result"
  printf '%s\n' "${desktop_class_cache[$class]}"
}

addr="$(
  while IFS=$'\t' read -r addr ws class title; do
    [[ -n "${addr:-}" && -n "${class:-}" && "$class" != "null" ]] || continue

    IFS=$'\t' read -r app icon < <(desktop_for_class "$class")

    [[ -n "$title" && "$title" != "null" ]] || title="$app"

    title="${title//$'\n'/ }"
    title="${title//$'\t'/ }"

    (( ${#title} > 100 )) && title="${title:0:97}..."

    display="[$ws]  $app  —  $title"

    printf '%s\t%s\0icon\x1f%s\n' "$addr" "$display" "$icon"
  done < <(
    hyprctl clients -j |
      jq -r '.[] | select(.mapped == true) |
        [
          .address,
          (.workspace.name // (.workspace.id | tostring)),
          (.class // .initialClass // "unknown"),
          (.title // "")
        ] | map(tostring | gsub("[\t\r\n]"; " ")) | @tsv'
  ) |
  fuzzel --dmenu \
    --prompt='window> ' \
    --width=95 \
    --with-nth=2 \
    --accept-nth=1 \
    --match-nth=2 \
    --no-sort \
    --no-run-if-empty
)"

[[ -n "${addr:-}" ]] && hyprctl dispatch focuswindow "address:$addr"
