#!/usr/bin/env bash
# Remove o WinXPRemix e restaura as configurações salvas pelo install.sh.
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="$DATA_DIR/winxpremix"
GTK4_CSS="$CONFIG_DIR/gtk-4.0/gtk.css"
FOLLOW_BIN="$HOME/.local/bin/winxpremix-follow-scheme"
FLATPAK_OVERRIDES="$DATA_DIR/flatpak/overrides/global"
MARKER='WinXPRemix — GTK 4 / libadwaita'

step() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

step "Parando alternância automática"
pkill -f "$FOLLOW_BIN" 2>/dev/null || true
rm -f "$FOLLOW_BIN" "$CONFIG_DIR/autostart/winxpremix-follow-scheme.desktop"

step "Restaurando configurações"
if [[ -f "$STATE_DIR/previous-settings" ]]; then
  while IFS='=' read -r key value; do
    case "$key" in
      gtk-theme)        gsettings set org.gnome.desktop.interface gtk-theme "$value" ;;
      button-layout)    gsettings set org.gnome.desktop.wm.preferences button-layout "$value" ;;
      picture-uri)      gsettings set org.gnome.desktop.background picture-uri "$value" ;;
      picture-uri-dark) gsettings set org.gnome.desktop.background picture-uri-dark "$value" ;;
      shell-theme)      gsettings set org.gnome.shell.extensions.user-theme name "$value" ;;
    esac
  done < "$STATE_DIR/previous-settings"
else
  gsettings reset org.gnome.desktop.interface gtk-theme
  gsettings list-keys org.gnome.shell.extensions.user-theme >/dev/null 2>&1 &&
    gsettings reset org.gnome.shell.extensions.user-theme name
fi

if [[ -f "$GTK4_CSS" ]] && grep -q "$MARKER" "$GTK4_CSS"; then
  step "Removendo override do libadwaita"
  if [[ -f "$STATE_DIR/gtk4-gtk.css.backup" ]]; then
    mv "$STATE_DIR/gtk4-gtk.css.backup" "$GTK4_CSS"
  else
    rm -f "$GTK4_CSS"
  fi
fi

# Só desfaz a liberação do Flatpak se foi o install.sh que a criou, e tira
# apenas essa entrada (--reset apagaria os outros overrides do usuário).
if [[ -f "$STATE_DIR/flatpak-override" && -f "$FLATPAK_OVERRIDES" ]]; then
  step "Removendo a liberação do gtk.css para apps Flatpak"
  sed -i -E '/^filesystems=/ s#(=|;)xdg-config/gtk-4\.0:ro;#\1#' "$FLATPAK_OVERRIDES"
  sed -i '/^filesystems=$/d' "$FLATPAK_OVERRIDES"
fi

step "Removendo arquivos"
rm -rf "$HOME/.themes/WinXPRemix" "$HOME/.themes/WinXPRemix-Dark" \
       "$DATA_DIR/backgrounds/winxpremix" \
       "$DATA_DIR/gnome-background-properties/winxpremix.xml" \
       "$STATE_DIR"

step "WinXPRemix removido."
