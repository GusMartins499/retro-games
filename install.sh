#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RA_ID="org.libretro.RetroArch"
RA_DIR="$HOME/.var/app/$RA_ID/config/retroarch"
ESDE_DIR="$HOME/ES-DE"
ESDE_APPIMAGE="$HOME/Applications/ES-DE_x64.AppImage"
ESDE_RELEASES="https://gitlab.com/api/v4/projects/es-de%2Femulationstation-de/releases?per_page=1"
CORES_URL="https://buildbot.libretro.com/nightly/linux/x86_64/latest"
CORES=(pcsx_rearmed mednafen_psx_hw snes9x mupen64plus_next)
SYSTEMS=(psx snes n64)

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

install_retroarch() {
  log "RetroArch (Flatpak)"
  flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install --user -y --noninteractive flathub "$RA_ID"
}

install_cores() {
  log "Cores: ${CORES[*]}"
  mkdir -p "$RA_DIR/cores"
  local tmp core
  tmp="$(mktemp -d)"
  for core in "${CORES[@]}"; do
    [[ -f "$RA_DIR/cores/${core}_libretro.so" ]] && continue
    curl -fsSL -o "$tmp/$core.zip" "$CORES_URL/${core}_libretro.so.zip"
    unzip -oq "$tmp/$core.zip" -d "$RA_DIR/cores"
  done
  rm -rf "$tmp"
}

install_esde() {
  log "ES-DE (AppImage)"
  [[ -x "$ESDE_APPIMAGE" ]] && return
  local url
  url="$(curl -fsSL "$ESDE_RELEASES" | python3 -c '
import json, sys
links = json.load(sys.stdin)[0]["assets"]["links"]
print(next(l["url"] for l in links if l["name"] == "ES-DE_x64.AppImage"))
')"
  mkdir -p "$(dirname "$ESDE_APPIMAGE")"
  curl -fsSL -o "$ESDE_APPIMAGE" "$url"
  chmod +x "$ESDE_APPIMAGE"
}

set_retroarch_option() {
  local key="$1" value="$2" file="$RA_DIR/retroarch.cfg"
  touch "$file"
  if grep -q "^$key = " "$file"; then
    sed -i "s|^$key = .*|$key = \"$value\"|" "$file"
  else
    printf '%s = "%s"\n' "$key" "$value" >> "$file"
  fi
}

configure_retroarch() {
  log "RetroArch: saves e states em $REPO"
  mkdir -p "$RA_DIR" "$REPO/saves" "$REPO/states"
  [[ -d "$RA_DIR/saves" ]] && cp -rn "$RA_DIR/saves/." "$REPO/saves/"
  [[ -d "$RA_DIR/states" ]] && cp -rn "$RA_DIR/states/." "$REPO/states/"
  set_retroarch_option savefile_directory "$REPO/saves"
  set_retroarch_option savestate_directory "$REPO/states"
  set_retroarch_option sort_savefiles_enable true
  set_retroarch_option sort_savestates_enable true
}

link_dir() {
  local target="$1" link="$2"
  mkdir -p "$target" "$(dirname "$link")"
  if [[ -L "$link" ]]; then
    ln -sfn "$target" "$link"
    return
  fi
  if [[ -d "$link" ]]; then
    cp -rn "$link/." "$target/"
    mv "$link" "$link.bak-$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$target" "$link"
}

configure_esde() {
  log "ES-DE: settings e gamelists em $REPO/es-de"
  link_dir "$REPO/es-de/settings" "$ESDE_DIR/settings"
  link_dir "$REPO/es-de/gamelists" "$ESDE_DIR/gamelists"
}

create_rom_dirs() {
  log "Pastas de ROMs em ~/ROMs"
  local system
  for system in "${SYSTEMS[@]}"; do
    mkdir -p "$HOME/ROMs/$system"
  done
}

create_desktop_entry() {
  log "Atalho do ES-DE no menu"
  mkdir -p "$HOME/.local/share/applications"
  cat > "$HOME/.local/share/applications/es-de.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=ES-DE
Comment=Biblioteca de jogos retrô
Exec=$ESDE_APPIMAGE
Icon=applications-games
Categories=Game;
Terminal=false
EOF
}

install_retroarch
install_cores
install_esde
configure_retroarch
configure_esde
create_rom_dirs
create_desktop_entry
log "Pronto. Coloque as ROMs em ~/ROMs/{psx,snes,n64} e abra o ES-DE."
