# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## Unreleased

### Added

- Licensing: the code is under GPL-3.0-or-later (`LICENSE`), and the "Hill" wallpapers are under
  CC BY 4.0 (`wallpapers/LICENSE`), with SPDX tags in the SVG files. The README explains which
  license covers what, how to credit the wallpapers, and that the project is not affiliated with
  Microsoft.

### Changed

- The project is now in English: README, changelog, script messages, code comments and
  extension metadata. Screenshots were renamed to English file names, and the wallpaper is now
  called "Hill".

## 1.1.1 - 2026-10-25

### Fixed

- **Lock screen without the theme:** User Themes is disabled when the screen locks, and the Shell
  fell back to the default theme. Because of that, the 1.1.0 lock screen look never showed up. The
  new `winxpremix-lockscreen@winxpremix` extension, installed by `install.sh`, keeps the WinXPRemix
  theme while the screen is locked. You need to log out and back in once.
- **Lock screen details:**
  - a second blue panel showed up around the password field;
  - the avatar sat in a square with a round image inside; it is now round, with a white frame;
  - the password field is now white in dark mode too.
- **GTK3:** the selected button in the title bar (like the widget factory tabs) had white text on
  a white background, and hover left an orange outline inside the blue bar.

### Changed

- Screenshots retaken, with new images of the lock screen, the overview, the alert dialog and
  the toggle groups.

## 1.1.0 - 2026-10-25

### Added

- **"Welcome" lock screen:** the clock and the password field sit on a Luna blue panel, the
  avatar gets a white frame, the password field is white, the buttons follow the XP style and
  notifications become yellow balloons.
- **More GTK4/libadwaita widgets:**
  - alert dialogs with a blue strip on top and a frame;
  - the active tab takes the content color, with an orange hover;
  - toggle groups with the active item in blue;
  - flat buttons with a border on hover (translucent white in the title bar);
  - `.osd` buttons in the Shell OSD blue.
- **Flatpak:** `install.sh` gives Flatpak apps access to `~/.config/gtk-4.0` (`--no-flatpak`
  turns it off). `uninstall.sh` only undoes what the installer created and keeps your other
  overrides.
- `VERSION` file, which the build writes to `index.theme`.

### Changed

- **Single palette:** `src/_palette.scss` is the only source of colors. The build generates the
  GTK4 `--xp-*` variables from it (`src/gtk-4.0/palette.scss`), and GTK3 now uses the palette for
  the progress bar, sliders and checkboxes.
- **Dark mode:** the GTK3 title bar and the Shell dialogs use the same slightly deeper blue that
  GTK4 already used.

### Fixed

- **Misaligned headerbars on libadwaita 1.9:** when the title bar was stacked with another bar
  (like the search bar in Files and Settings), 3px dark strips appeared and the bar was shorter
  than the one in the other pane.
- `./install.sh --help` printed the `set -euo pipefail` line along with the help text.

## 1.0.0 - 2026-10-25

First release:
- GNOME Shell 50+ theme (Luna taskbar, Start button, notification area, menus, quick settings,
  notification balloons, Alt+Tab, OSD, dash);
- GTK3;
- libadwaita override;
- "Hill" day/night wallpapers;
- automatic light/dark switching;
- install and uninstall scripts.
