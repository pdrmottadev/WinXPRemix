#!/usr/bin/env bash
# Compila os fontes SCSS/CSS de src/ para themes/WinXPRemix e themes/WinXPRemix-Dark.
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

if ! command -v sassc >/dev/null 2>&1; then
  echo "erro: sassc não encontrado (Fedora: sudo dnf install sassc)" >&2
  exit 1
fi

OUT=themes
VERSION=$(cat VERSION)
GTK4_DEFAULT='resource:///org/gtk/libgtk/theme/Default'

write_index() { # $1 = nome do tema
  cat > "$OUT/$1/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=$1
Comment=Windows XP Luna reimaginado para GNOME 50+ (v$VERSION)
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=$1
IconTheme=Adwaita
CursorTheme=Adwaita
ButtonLayout=appmenu:minimize,maximize,close
EOF
}

# CSS do GTK4: variáveis --xp-* geradas da paleta + regras de src/gtk-4.0/gtk.css
gtk4_css() {
  sassc -t expanded src/gtk-4.0/palette.scss
  echo
  cat src/gtk-4.0/gtk.css
}

# Tema GTK4 "standalone" (apps GTK4 sem libadwaita): base Default + overrides
write_gtk4_theme() { # $1 = destino, $2 = folha base do GTK4
  {
    echo "@import url(\"$GTK4_DEFAULT/$2\");"
    echo
    gtk4_css
  } > "$1"
}

rm -rf "$OUT"

for name in WinXPRemix WinXPRemix-Dark; do
  mkdir -p "$OUT/$name/gnome-shell" "$OUT/$name/gtk-3.0" "$OUT/$name/gtk-4.0"
  write_index "$name"
done

# GNOME Shell
sassc -t expanded src/gnome-shell/gnome-shell.scss      "$OUT/WinXPRemix/gnome-shell/gnome-shell.css"
sassc -t expanded src/gnome-shell/gnome-shell-dark.scss "$OUT/WinXPRemix-Dark/gnome-shell/gnome-shell.css"

# GTK 3
sassc -t expanded src/gtk-3.0/gtk.scss      "$OUT/WinXPRemix/gtk-3.0/gtk.css"
sassc -t expanded src/gtk-3.0/gtk-dark.scss "$OUT/WinXPRemix/gtk-3.0/gtk-dark.css"
cp "$OUT/WinXPRemix/gtk-3.0/gtk-dark.css"   "$OUT/WinXPRemix-Dark/gtk-3.0/gtk.css"

# GTK 4
write_gtk4_theme "$OUT/WinXPRemix/gtk-4.0/gtk.css"      gtk-light.css
write_gtk4_theme "$OUT/WinXPRemix/gtk-4.0/gtk-dark.css" gtk-dark.css
write_gtk4_theme "$OUT/WinXPRemix-Dark/gtk-4.0/gtk.css" gtk-dark.css
# Override para libadwaita (instalado em ~/.config/gtk-4.0/gtk.css)
gtk4_css > "$OUT/WinXPRemix/gtk-4.0/libadwaita.css"

echo "Tema compilado em $OUT/"
