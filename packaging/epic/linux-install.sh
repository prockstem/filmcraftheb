#!/bin/sh
# Installs @APP@ for the current user (no administrator password needed):
#   program  ~/.local/share/@ID@/@BIN@   (+ a link in ~/.local/bin)
#   menu     ~/.local/share/applications/@ID@.desktop, icons in ~/.local/share/icons
# Run ./uninstall.sh to remove it.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
data=${XDG_DATA_HOME:-$HOME/.local/share}
dest="$data/@ID@"
mkdir -p "$dest" "$HOME/.local/bin" "$data/applications"
cp "$here/@BIN@" "$dest/@BIN@"
chmod 755 "$dest/@BIN@"
ln -sf "$dest/@BIN@" "$HOME/.local/bin/@BIN@"
(cd "$here/icons" && find . -type f) | while read -r f; do
  mkdir -p "$data/icons/$(dirname "$f")"
  cp "$here/icons/$f" "$data/icons/$f"
done
sed -e "s|^Exec=@BIN@|Exec=\"$dest/@BIN@\"|" -e "s|^TryExec=@BIN@|TryExec=$dest/@BIN@|" \
  "$here/@ID@.desktop" >"$data/applications/@ID@.desktop"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$data/applications" 2>/dev/null || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t "$data/icons/hicolor" 2>/dev/null || true
echo "@APP@ is installed. Open it from your applications menu, or run: $dest/@BIN@"
