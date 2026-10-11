@APP@ @VERSION@ — Linux (64-bit x86)
@DESC@
Ubuntu 20.04 or newer, Debian 11+, Linux Mint 20+, Fedora 32+ and similar.

Installation
1. Extract:  tar -xzf @ARCHIVE@
2. Run:      cd "@APP@" && ./install.sh
   (No administrator password; installs for the current user and adds a menu entry.)
You can also run it without installing: ./@BIN@
To uninstall: ./uninstall.sh
@LANG@
If the app does not start: sudo apt install libxkbcommon-x11-0  (Fedora: sudo dnf install libxkbcommon-x11)

@APP@ is based on @UPSTREAM@ (@UPSTREAM_URL@), open source under MIT OR Apache-2.0; see
LICENSE-MIT, LICENSE-APACHE and NOTICE. Source code: @SOURCE_URL@
