#!/bin/sh
# Removes what install.sh installed for the current user (your settings and documents stay).
set -eu
data=${XDG_DATA_HOME:-$HOME/.local/share}
rm -rf "$data/@ID@"
rm -f "$HOME/.local/bin/@BIN@" "$data/applications/@ID@.desktop"
find "$data/icons/hicolor" -name '@ID@.*' -delete 2>/dev/null || true
echo "@APP@ is uninstalled."
