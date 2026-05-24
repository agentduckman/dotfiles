#!/usr/bin/env bash
set -euo pipefail

desktop_dirs=(
  "$HOME/.local/share/applications"
  "$HOME/.local/share/flatpak/exports/share/applications"
  /var/lib/flatpak/exports/share/applications
  /usr/local/share/applications
  /usr/share/applications
)

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

desktop_for_class() {
  local class="${1,,}"
  local file base name icon swm dir

  # Best case: .desktop explicitly declares StartupWMClass
  for dir in "${desktop_dirs[@]}"; do
    [[ -d "$dir" ]] || continue

    while IFS= read -r -d '' file; do
      swm="$(desktop_value StartupWMClass "$file" | tr '[:upper:]' '[:lower:]')"

      [[ -n "$swm" && "$swm" == "$class" ]] || continue

      name="$(desktop_value Name "$file")"
      icon="$(desktop_value Icon "$file")"

      printf '%s\t%s\n' "${name:-$1}" "${icon:-${class},application-x-executable}"
      return
    done < <(find "$dir" -type f -name '*.desktop' -print0 2>/dev/null)
  done

  # Fallback: match class against desktop filename
  for dir in "${desktop_dirs[@]}"; do
    [[ -d "$dir" ]] || continue

    while IFS= read -r -d '' file; do
      base="$(basename "$file" .desktop)"
      base="${base,,}"

      [[ "$base" == "$class" || "$base" == *".$class" || "$base" == *"$class"* ]] || continue

      name="$(desktop_value Name "$file")"
      icon="$(desktop_value Icon "$file")"

      printf '%s\t%s\n' "${name:-$1}" "${icon:-${class},application-x-executable}"
      return
    done < <(find "$dir" -type f -name '*.desktop' -print0 2>/dev/null)
  done

  # Last-resort fallback
  printf '%s\t%s\n' "$1" "${class},application-x-executable"
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
