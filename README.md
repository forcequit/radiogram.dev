# Radiogram for Omarchy Quattro

A native Omarchy Quattro bar-widget plugin for [Radiogram](https://radiogram.dev).

## What it does

- Shows the current Radiogram station and play/pause state in the Omarchy bar.
- Left-click the bar widget to play/pause.
- Right-click to open a detail panel with station info and an Open/Play action.
- Works through the browser's MPRIS bridge (Chromium/Firefox on Wayland).

## Requirements

- Omarchy Quattro
- A Chromium or Firefox browser playing Radiogram that exposes an MPRIS media session

The web app already sets `artist = "Radiogram"` in its Media Session metadata so the plugin can identify the player.

## Install

1. Clone or copy this folder into your Omarchy plugins directory:

```bash
mkdir -p ~/.config/omarchy/plugins/radiogram.radiogram
cp manifest.json BarWidget.qml Panel.qml ~/.config/omarchy/plugins/radiogram.radiogram/
```

2. Validate the plugin:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/radiogram.radiogram
```

3. Enable the widget in your Omarchy bar config (typically in the `center` section).

4. Reload the shell:

```bash
omarchy-shell shell rescanPlugins
```

## Uninstall

```bash
rm -rf ~/.config/omarchy/plugins/radiogram.radiogram
omarchy-shell shell rescanPlugins
```

## Development

```bash
omarchy plugin clone radiogram.radiogram --edit
```

Validate QML with `qmllint`:

```bash
PLUGIN_DIR="$HOME/.config/omarchy/plugins/radiogram.radiogram"
qmllint -I "$OMARCHY_PATH/shell" "$PLUGIN_DIR/BarWidget.qml" "$PLUGIN_DIR/Panel.qml"
```

## License

MIT
