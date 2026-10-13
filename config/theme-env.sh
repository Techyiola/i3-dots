#!/usr/bin/env bash
#
# theme-env.sh — Hinterlands theme environment (sourced, not executed).
# Loaded from ~/.xprofile (X11 sessions) and ~/.profile (login shells).
#
# Keeps the UI at a consistent 1.0x (100%) scale and sets the cursor/toolkit
# theme across GTK, Qt, Electron, Firefox, Java and SDL apps.
#

# ~/.local/bin on PATH (bt-menu and friends are called by absolute path in i3,
# but this makes them available in a shell too).
case ":$PATH:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Cursor theme for all toolkits
export XCURSOR_THEME="${XCURSOR_THEME:-Bibata-Modern-Classic}"
export XCURSOR_SIZE="${XCURSOR_SIZE:-18}"

# Qt: use the GTK platform theme so Qt apps match the GTK theme
export QT_QPA_PLATFORMTHEME="gtk3"

# Force a consistent 1.0x UI scale everywhere (HiDPI panel at 100%)
export GDK_SCALE=1
export GDK_DPI_SCALE=1
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1
export QT_SCREEN_SCALE_FACTORS=1
