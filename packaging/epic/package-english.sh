#!/usr/bin/env bash
# Package an English Epic build: packaging/epic/package-english.sh windows|linux|macos
# App details come from packaging/epic/app.env. Output: dist/epic/<App>-<version>-English-<platform>.<ext>
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
# shellcheck source=/dev/null
. "$HERE/app.env"
platform=$1
version=$(sed -n 's/^version = "\(.*\)"/\1/p' "$ROOT/Cargo.toml" | head -1)
slug=$(echo "$APP" | tr ' ' '-')
out="$ROOT/dist/epic"
work="$ROOT/dist/epic-work"
rm -rf "$work" && mkdir -p "$out" "$work/$APP"
stage="$work/$APP"
sub() {
  sed -e "s|@APP@|$APP|g" -e "s|@BIN@|$BIN|g" -e "s|@ID@|$ID|g" -e "s|@VERSION@|$version|g" \
    -e "s|@ARCHIVE@|${ARCHIVE:-}|g" -e "s|@DESC@|$DESC|g" -e "s|@LANG@|$LANG_NOTE|g" \
    -e "s|@UPSTREAM@|$UPSTREAM|g" -e "s|@UPSTREAM_URL@|$UPSTREAM_URL|g" -e "s|@SOURCE_URL@|$SOURCE_URL|g" "$1"
}
licences() {
  cp "$ROOT/LICENSE-MIT" "$ROOT/LICENSE-APACHE" "$ROOT/NOTICE" "$stage/"
  for f in ATTRIBUTION.md ASSETS.md; do if [ -f "$ROOT/$f" ]; then cp "$ROOT/$f" "$stage/"; fi; done
}
case "$platform" in
  windows)
    cp "$ROOT/target/x86_64-pc-windows-gnu/release/$BIN.exe" "$stage/$APP.exe"
    licences
    sub "$HERE/README-windows.txt" | sed 's/$/\r/' >"$stage/README.txt"
    (cd "$work" && zip -q -9 -r "$out/$slug-$version-English-Windows-x64.zip" "$APP")
    ;;
  linux)
    ARCHIVE="$slug-$version-English-Linux-x86_64.tar.gz"
    cp "$ROOT/target/x86_64-unknown-linux-gnu/release/$BIN" "$stage/$BIN" && chmod 755 "$stage/$BIN"
    mkdir -p "$stage/icons/hicolor"
    cp -r "$ROOT/assets/app-icon/hicolor/." "$stage/icons/hicolor/"
    find "$stage/icons" -type f ! -name "$ID.*" -delete
    cp "$ROOT/packaging/linux/$ID.desktop" "$stage/"
    licences
    sub "$HERE/linux-install.sh" >"$stage/install.sh"
    sub "$HERE/linux-uninstall.sh" >"$stage/uninstall.sh"
    sub "$HERE/README-linux.txt" >"$stage/README.txt"
    chmod 755 "$stage/install.sh" "$stage/uninstall.sh"
    (cd "$work" && tar --owner=0 --group=0 -czf "$out/$ARCHIVE" "$APP")
    ;;
  macos)
    dmg=$(ls "$ROOT"/dist/release/*-macos-universal.dmg | head -1)
    cp "$dmg" "$stage/$APP.dmg"
    licences
    sub "$HERE/README-macos.txt" >"$stage/README.txt"
    (cd "$work" && zip -q -9 -r "$out/$slug-$version-English-macOS.zip" "$APP")
    ;;
  *) echo "usage: $0 windows|linux|macos" >&2; exit 2 ;;
esac
ls -la "$out"
