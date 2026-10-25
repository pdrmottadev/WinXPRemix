#!/usr/bin/env bash
# Instala e aplica o WinXPRemix para o usuário atual (sem sudo).
#
#   ./install.sh                 instala e aplica tudo
#   ./install.sh --no-apply      só copia os arquivos
#   ./install.sh --no-gtk4       não mexe em ~/.config/gtk-4.0/gtk.css
#   ./install.sh --no-wallpaper  não troca o papel de parede
#   ./install.sh --no-follow     não alterna Shell/GTK3 com o modo claro/escuro
#   ./install.sh --no-flatpak    não libera o gtk.css para apps Flatpak
set -euo pipefail

SRC="$(dirname "$(readlink -f "$0")")"

APPLY=1 GTK4=1 WALLPAPER=1 FOLLOW=1 FLATPAK=1
for arg in "$@"; do
  case "$arg" in
    --no-apply)     APPLY=0 ;;
    --no-gtk4)      GTK4=0 ;;
    --no-wallpaper) WALLPAPER=0 ;;
    --no-follow)    FOLLOW=0 ;;
    --no-flatpak)   FLATPAK=0 ;;
    -h|--help)      sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $arg" >&2; exit 1 ;;
  esac
done

THEMES_DIR="$HOME/.themes"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="$DATA_DIR/winxpremix"
BG_DIR="$DATA_DIR/backgrounds/winxpremix"
GTK4_CSS="$CONFIG_DIR/gtk-4.0/gtk.css"
FOLLOW_BIN="$HOME/.local/bin/winxpremix-follow-scheme"
AUTOSTART="$CONFIG_DIR/autostart/winxpremix-follow-scheme.desktop"
FLATPAK_OVERRIDES="$DATA_DIR/flatpak/overrides/global"
USER_THEME_UUID=user-theme@gnome-shell-extensions.gcampax.github.com
MARKER='WinXPRemix — GTK 4 / libadwaita'

step() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m aviso:\033[0m %s\n' "$*"; }

# --- Compilação -------------------------------------------------------------

if command -v sassc >/dev/null 2>&1; then
  step "Compilando o tema"
  "$SRC/build.sh" >/dev/null
elif [[ ! -d "$SRC/themes/WinXPRemix" ]]; then
  echo "erro: sassc não encontrado e não há tema pré-compilado em themes/" >&2
  exit 1
fi

# --- Arquivos ---------------------------------------------------------------

step "Copiando temas para $THEMES_DIR"
mkdir -p "$THEMES_DIR" "$STATE_DIR"
for name in WinXPRemix WinXPRemix-Dark; do
  rm -rf "${THEMES_DIR:?}/$name"
  cp -r "$SRC/themes/$name" "$THEMES_DIR/$name"
done

if (( GTK4 )); then
  step "Instalando override do libadwaita em $GTK4_CSS"
  mkdir -p "$(dirname "$GTK4_CSS")"
  if [[ -f "$GTK4_CSS" ]] && ! grep -q "$MARKER" "$GTK4_CSS"; then
    cp "$GTK4_CSS" "$STATE_DIR/gtk4-gtk.css.backup"
    warn "seu gtk.css anterior foi salvo em $STATE_DIR/gtk4-gtk.css.backup"
  fi
  cp "$SRC/themes/WinXPRemix/gtk-4.0/libadwaita.css" "$GTK4_CSS"
fi

# Apps Flatpak só enxergam o gtk.css com acesso de leitura a ~/.config/gtk-4.0.
# A marca em $STATE_DIR diz ao uninstall.sh que fomos nós que liberamos.
if (( GTK4 && FLATPAK )) && command -v flatpak >/dev/null 2>&1 &&
   ! grep -qs '^filesystems=.*xdg-config/gtk-4\.0' "$FLATPAK_OVERRIDES"; then
  step "Liberando o gtk.css para apps Flatpak"
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
  touch "$STATE_DIR/flatpak-override"
fi

if (( WALLPAPER )); then
  step "Instalando papéis de parede"
  mkdir -p "$BG_DIR" "$DATA_DIR/gnome-background-properties"
  cp "$SRC"/wallpapers/*.svg "$BG_DIR/"
  cat > "$DATA_DIR/gnome-background-properties/winxpremix.xml" <<EOF
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>WinXPRemix Colina</name>
    <filename>$BG_DIR/winxpremix-day.svg</filename>
    <filename-dark>$BG_DIR/winxpremix-night.svg</filename-dark>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#3a8bf2</pcolor>
    <scolor>#2a7a1a</scolor>
  </wallpaper>
</wallpapers>
EOF
fi

if (( FOLLOW )); then
  step "Instalando alternância automática claro/escuro"
  mkdir -p "$(dirname "$FOLLOW_BIN")" "$(dirname "$AUTOSTART")"
  install -m 755 "$SRC/extras/winxpremix-follow-scheme" "$FOLLOW_BIN"
  cat > "$AUTOSTART" <<EOF
[Desktop Entry]
Type=Application
Name=WinXPRemix: seguir modo claro/escuro
Exec=$FOLLOW_BIN
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF
fi

(( APPLY )) || { step "Pronto (sem aplicar)."; exit 0; }

# --- Aplicação --------------------------------------------------------------

# Guarda as configurações atuais uma única vez, para o uninstall.sh restaurar.
if [[ ! -f "$STATE_DIR/previous-settings" ]]; then
  {
    echo "gtk-theme=$(gsettings get org.gnome.desktop.interface gtk-theme)"
    echo "button-layout=$(gsettings get org.gnome.desktop.wm.preferences button-layout)"
    echo "picture-uri=$(gsettings get org.gnome.desktop.background picture-uri)"
    echo "picture-uri-dark=$(gsettings get org.gnome.desktop.background picture-uri-dark)"
    if gsettings list-keys org.gnome.shell.extensions.user-theme >/dev/null 2>&1; then
      echo "shell-theme=$(gsettings get org.gnome.shell.extensions.user-theme name)"
    fi
  } > "$STATE_DIR/previous-settings"
fi

case "$(gsettings get org.gnome.desktop.interface color-scheme)" in
  *dark*) THEME=WinXPRemix-Dark ;;
  *)      THEME=WinXPRemix ;;
esac

step "Aplicando $THEME"
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

if gnome-extensions info "$USER_THEME_UUID" >/dev/null 2>&1; then
  gnome-extensions enable "$USER_THEME_UUID" || true
  gsettings set org.gnome.shell.extensions.user-theme name "$THEME"
else
  warn "extensão User Themes não encontrada; o tema do Shell não foi aplicado."
  warn "Fedora: sudo dnf install gnome-shell-extension-user-theme"
fi

if (( WALLPAPER )); then
  gsettings set org.gnome.desktop.background picture-uri "file://$BG_DIR/winxpremix-day.svg"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$BG_DIR/winxpremix-night.svg"
fi

if (( FOLLOW )); then
  pkill -f "$FOLLOW_BIN" 2>/dev/null || true
  setsid "$FOLLOW_BIN" >/dev/null 2>&1 < /dev/null &
fi

step "Pronto! Apps já abertos precisam ser reabertos para pegar o novo visual."
