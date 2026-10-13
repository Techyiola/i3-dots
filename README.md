# Hinterlands — an i3 desktop

A monochrome, minimal i3 desktop for Arch-based distros (built on CachyOS),
styled after the **Omarchy "Hinterlands"** theme. Everything is a plain config
file that gets copied into `~/.config` by a single script.

```
palette   bg #222222   fg #ffffff   accent #686868   border #555555
```

Bar: **polybar** · Launcher: **rofi** · Notifications: **dunst**
Compositor: **picom** · Terminal: **alacritty** · Resource monitor: **btop**

<!-- drop a screenshot here: ![screenshot](screenshot.png) -->

---

## Install

```bash
git clone <your-fork-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` **copies** (never deletes) the files into place and backs up
anything it overwrites to `~/.dotfiles-backup-<timestamp>`. It is safe to
re-run.

Then install the dependencies it reports (see [`packages.txt`](packages.txt)):

```bash
sudo pacman -S --needed i3-wm polybar rofi dunst alacritty picom feh pamixer \
  libnotify networkmanager bluez bluez-utils xorg-xrandr xorg-xrdb \
  i3lock-color redshift xob dex polkit-gnome \
  ttf-hack ttf-meslo-nerd awesome-terminal-fonts

paru -S --needed bibata-cursor-theme-bin zen-browser-bin   # AUR
```

Finally **log out and back in** (to pick up `~/.profile` / `~/.xprofile`), then:

```
Mod+Shift+R                 # reload i3
~/.config/polybar/launch.sh # (re)start the bar
```

---

## Key bindings

| Key | Action |
| --- | --- |
| `Mod+Z` | terminal (alacritty) |
| `Mod+A` | opencode (terminal window) |
| `Mod+W` | Zen browser |
| `Mod+Space` | rofi launcher |
| `Mod+B` | Bluetooth manager (rofi text UI) |
| `Mod+Q` | close window |
| `Mod+L` | lock screen |
| `Mod+Shift+P` | calculator |
| `Mod+Shift+C` / `Mod+Shift+R` | reload / restart i3 |

`Mod` = Super (Windows key). See `~/.config/i3/config` for the full list.

---

## What's installed where

| Repo path | Goes to |
| --- | --- |
| `config/i3/` | `~/.config/i3/` (config, `display.sh`, wallpaper) |
| `config/polybar/` | `~/.config/polybar/` (config, `launch.sh`, scripts) |
| `config/rofi/` | `~/.config/rofi/` (Hinterlands theme) |
| `config/dunst/` | `~/.config/dunst/` |
| `config/alacritty/` | `~/.config/alacritty/` |
| `config/picom/` | `~/.config/picom/` |
| `config/btop/` | `~/.config/btop/` (+ Hinterlands theme) |
| `config/gtk-3.0/`, `config/gtk-4.0/` | GTK `gtk.css` overrides + settings |
| `config/theme-env.sh` | `~/.config/theme-env.sh` (cursor + 1.0x scaling) |
| `home/.Xresources`, `home/.xprofile` | `~/` |
| `bin/bt-menu` | `~/.local/bin/bt-menu` |
| `optional/zen-user.js` | copy into your Zen profile as `user.js` (optional) |

---

## Machine-specific things to check

These are the only bits that may differ on your hardware:

1. **Display / refresh rate** — edit `~/.config/i3/display.sh`:

   ```bash
   MODE="1920x1080"   # your resolution
   RATE="144"         # your refresh rate (falls back to auto if unsupported)
   ```

   It auto-detects the primary output, so you normally only touch these two
   values. Run `xrandr` to see valid names/modes.

2. **Fonts** — polybar and rofi need `Hack`, `MesloLGS Nerd Font` and a
   FontAwesome font (see the package list above).

3. **Cursor** — the config uses `Bibata-Modern-Classic`
   (`bibata-cursor-theme-bin`). Change `XCURSOR_THEME` in
   `~/.config/theme-env.sh` if you prefer another.

4. **Locale (optional cosmetic fix)** — if you see
   `xkbcommon: ERROR: No Compose file for locale ...`, set a UTF-8 locale, e.g.
   `sudo localectl set-locale LANG=en_US.UTF-8`.

5. **Wallpaper** — one is bundled at `~/.config/i3/wallpaper.png`; drop in your
   own to replace it.

---

## Notes

* **Copied, not symlinked.** After installing, the repo is the "master": if you
  edit your live configs and want to keep the changes, copy them back into the
  repo (or `./install.sh` again after editing the repo).
* Polybar spacing: a bare number in `padding-*` is *points*; use `10px` for
  exact pixels.
* The rofi build here defaults to a solarized/light theme, so
  `hinterlands.rasi` overrides **every** colour state explicitly.

## Credits

Theme inspired by [Omarchy](https://github.com/basecamp/omarchy)'s "Hinterlands".
Configs assembled for personal use — take what's useful.
