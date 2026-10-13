#!/usr/bin/env bash
#
# install.sh — install the Hinterlands i3 dotfiles by copying them into $HOME.
#
# What it does:
#   * config/<app>/... -> ~/.config/<app>/...
#   * home/.<file>     -> ~/.<file>
#   * bin/*            -> ~/.local/bin/*
#   * writes ~/.config/rofi/config (legacy theme pointer) with your $HOME
#   * sources ~/.config/theme-env.sh from ~/.profile (once)
#
# Anything it would overwrite is backed up to ~/.dotfiles-backup-<timestamp>.
# Safe to re-run. Nothing is deleted from your existing configs (merge copy).
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HOME}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="${DEST}/.dotfiles-backup-${STAMP}"

R=$'\033[0m'; B=$'\033[1m'; Y=$'\033[33m'; G=$'\033[32m'; D=$'\033[2m'
log()  { printf '%s==>%s %s\n' "$B" "$R" "$*"; }
warn() { printf '%s!!%s  %s\n' "$Y" "$R" "$*"; }
ok()   { printf ' %s✓%s %s\n' "$G" "$R" "$*"; }

backup() {
    local t="$1"
    [ -e "$t" ] || [ -L "$t" ] || return 0
    local rel="${t#"$DEST"/}"
    mkdir -p "$BACKUP/$(dirname "$rel")"
    cp -a "$t" "$BACKUP/$rel"
}
copy_file() { mkdir -p "$(dirname "$2")"; backup "$2"; cp -a "$1" "$2"; }
copy_dir()  { mkdir -p "$2"; backup "$2"; cp -a "$1"/. "$2"/; }

log "Hinterlands dotfiles  (repo: ${REPO})"

# 1) ~/.config/*
shopt -s nullglob
for entry in "$REPO"/config/*; do
    name="$(basename "$entry")"
    if [ -d "$entry" ]; then copy_dir "$entry" "${DEST}/.config/${name}"
    else                     copy_file "$entry" "${DEST}/.config/${name}"; fi
done
shopt -u nullglob

# 2) home dotfiles -> $HOME
if [ -d "$REPO/home" ]; then
    while IFS= read -r -d '' f; do
        copy_file "$f" "${DEST}/${f#"$REPO"/home/}"
    done < <(find "$REPO/home" -mindepth 1 -print0)
fi

# 3) bin -> ~/.local/bin
if [ -d "$REPO/bin" ]; then
    while IFS= read -r -d '' f; do
        copy_file "$f" "${DEST}/.local/bin/${f#"$REPO"/bin/}"
    done < <(find "$REPO/bin" -mindepth 1 -print0)
fi

# 4) make sure executables stay executable
chmod +x "${DEST}/.local/bin/"* 2>/dev/null || true
chmod +x "${DEST}/.config/polybar/launch.sh" \
         "${DEST}/.config/polybar/scripts/"*.sh \
         "${DEST}/.config/i3/display.sh" \
         "${DEST}/.config/theme-env.sh" 2>/dev/null || true

# 5) rofi legacy config needs an absolute path -> generate at install time
printf 'rofi.theme: %s/.config/rofi/hinterlands.rasi\n' "$HOME" > "${DEST}/.config/rofi/config"

# 6) source theme-env.sh from ~/.profile (idempotent)
PROFILE="${DEST}/.profile"
MARK='# Hinterlands dotfiles: theme + UI scaling'
if ! grep -qF "$MARK" "$PROFILE" 2>/dev/null; then
    backup "$PROFILE"
    printf '\n%s\n[ -f "$HOME/.config/theme-env.sh" ] && . "$HOME/.config/theme-env.sh"\n' "$MARK" >> "$PROFILE"
    ok "linked theme-env.sh into ~/.profile"
fi
ok "configs installed"

# ---------------------------------------------------------------------------
# dependency report
# ---------------------------------------------------------------------------
trap - ERR
PKGS=(i3-wm polybar rofi dunst alacritty picom feh pamixer libnotify \
      networkmanager bluez bluez-utils xorg-xrandr xorg-xrdb \
      i3lock-color redshift xob dex polkit-gnome \
      ttf-hack ttf-meslo-nerd awesome-terminal-fonts)
AUR=(bibata-cursor-theme-bin zen-browser-bin)

miss=(); miss_aur=()
command -v pacman >/dev/null 2>&1 || { warn "not an Arch-based system; skipping package check"; }
if command -v pacman >/dev/null 2>&1; then
    for p in "${PKGS[@]}";     do pacman -Q "$p" >/dev/null 2>&1 || miss+=("$p");     done
    for p in "${AUR[@]}";      do pacman -Q "$p" >/dev/null 2>&1 || miss_aur+=("$p"); done
fi

if [ "${#miss[@]}" -gt 0 ] || [ "${#miss_aur[@]}" -gt 0 ]; then
    warn "Some packages are missing:"
    [ "${#miss[@]}" -gt 0 ]     && printf '    pacman -S --needed %s\n' "${miss[*]}"
    [ "${#miss_aur[@]}" -gt 0 ] && printf '    paru  -S --needed %s   %s(AUR)%s\n' "${miss_aur[*]}" "$D" "$R"
else
    ok "all packages present"
fi

# fonts actually resolvable? (avoid a pipe here: `fc-list | grep -q` can trip
# pipefail with SIGPIPE and report a false negative)
fonts="$(fc-list 2>/dev/null || true)"
for f in "Hack" "MesloLGS Nerd Font" "FontAwesome"; do
    grep -qi -- "$f" <<<"$fonts" || warn "font not found: $f"
done

cat <<EOF

${B}Done.${R} Backups (if any) are in ${D}${BACKUP}${R}

Next steps:
  1. Log out and back in (so ~/.profile / ~/.xprofile env vars apply).
  2. In i3, reload:  Mod+Shift+R      (or: i3-msg reload)
  3. Restart the bar:  ~/.config/polybar/launch.sh
  4. Drop your own wallpaper at ~/.config/i3/wallpaper.png (one is bundled).
  5. Edit ~/.config/i3/display.sh if your monitor/refresh differ.
EOF
