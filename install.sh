#!/usr/bin/env sh
set -eu

REPO="${REPO:-Melon1234123/Codexpet}"
BRANCH="${BRANCH:-main}"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
PET_DIR="$CODEX_HOME_DIR/pets/terminal-gremlin"
SKIP_SELECT="${SKIP_SELECT:-0}"

download() {
  url="$1"
  out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url"
  else
    echo "curl or wget is required to download pet files." >&2
    exit 1
  fi
}

copy_pet_files() {
  script_dir=""
  case "${0:-}" in
    */*) script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true) ;;
  esac

  if [ -n "$script_dir" ] &&
    [ -f "$script_dir/terminal-gremlin/pet.json" ] &&
    [ -f "$script_dir/terminal-gremlin/spritesheet.webp" ]; then
    cp -f "$script_dir/terminal-gremlin/pet.json" "$PET_DIR/pet.json"
    cp -f "$script_dir/terminal-gremlin/spritesheet.webp" "$PET_DIR/spritesheet.webp"
    return
  fi

  base_url="https://raw.githubusercontent.com/$REPO/$BRANCH/terminal-gremlin"
  download "$base_url/pet.json" "$PET_DIR/pet.json"
  download "$base_url/spritesheet.webp" "$PET_DIR/spritesheet.webp"
}

set_selected_pet() {
  config_path="$CODEX_HOME_DIR/config.toml"
  mkdir -p "$(dirname "$config_path")"

  if [ ! -f "$config_path" ]; then
    printf '[desktop]\nselected-avatar-id = "custom:terminal-gremlin"\n' > "$config_path"
    return
  fi

  tmp_path="${config_path}.tmp.$$"
  awk '
    BEGIN {
      in_desktop = 0
      desktop_seen = 0
      selected_done = 0
    }
    /^[[:space:]]*\[desktop\][[:space:]]*$/ {
      if (in_desktop && !selected_done) {
        print "selected-avatar-id = \"custom:terminal-gremlin\""
        selected_done = 1
      }
      in_desktop = 1
      desktop_seen = 1
      print
      next
    }
    /^[[:space:]]*\[/ {
      if (in_desktop && !selected_done) {
        print "selected-avatar-id = \"custom:terminal-gremlin\""
        selected_done = 1
      }
      in_desktop = 0
      print
      next
    }
    {
      if (in_desktop && $0 ~ /^[[:space:]]*selected-avatar-id[[:space:]]*=/) {
        if (!selected_done) {
          print "selected-avatar-id = \"custom:terminal-gremlin\""
          selected_done = 1
        }
        next
      }
      print
    }
    END {
      if (!desktop_seen) {
        print ""
        print "[desktop]"
        print "selected-avatar-id = \"custom:terminal-gremlin\""
      } else if (in_desktop && !selected_done) {
        print "selected-avatar-id = \"custom:terminal-gremlin\""
      }
    }
  ' "$config_path" > "$tmp_path"

  mv "$tmp_path" "$config_path"
}

mkdir -p "$PET_DIR"
copy_pet_files

if [ ! -s "$PET_DIR/pet.json" ]; then
  echo "pet.json was not installed." >&2
  exit 1
fi

if [ ! -s "$PET_DIR/spritesheet.webp" ]; then
  echo "spritesheet.webp was not installed." >&2
  exit 1
fi

if [ "$SKIP_SELECT" != "1" ]; then
  set_selected_pet
fi

echo "Installed Terminal Gremlin to: $PET_DIR"
if [ "$SKIP_SELECT" != "1" ]; then
  echo "Selected avatar id: custom:terminal-gremlin"
fi
echo "Restart Codex Desktop to load the pet."
