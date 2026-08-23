import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

// Radiogram bar widget for Omarchy Quattro.
// Finds the browser's MPRIS player by artist == "Radiogram" and shows
// the current station. Click to play/pause; right-click to open the panel.
Item {
  id: root

  property var bar: null
  property var radiogramPlayer: null

  function findRadiogramPlayer() {
    const players = Mpris.players
    const count = players.count
    for (let i = 0; i < count; i++) {
      const p = players.get(i)
      if (p.trackArtist === "Radiogram") {
        root.radiogramPlayer = p
        return
      }
    }
    root.radiogramPlayer = null
  }

  function displayText() {
    if (!root.radiogramPlayer) return "\u25cb Radiogram"
    const icon = root.radiogramPlayer.isPlaying ? "\u25b6" : "\u23f8"
    const title = root.radiogramPlayer.trackTitle || "Radiogram"
    return icon + " " + title
  }

  function tooltipText() {
    if (!root.radiogramPlayer) return "Radiogram is idle\nClick to open"
    const status = root.radiogramPlayer.isPlaying ? "Playing" : "Paused"
    const title = root.radiogramPlayer.trackTitle || "Radiogram"
    return title + "\nStatus: " + status + "\nClick to play/pause\nRight-click for panel"
  }

  function togglePlayback() {
    if (root.radiogramPlayer && root.radiogramPlayer.canTogglePlaying) {
      root.radiogramPlayer.togglePlaying()
    } else {
      Wt.openUrlExternally("https://radiogram.dev")
    }
  }

  function openPanel() {
    if (panelLoader.item) panelLoader.item.open()
  }

  Component.onCompleted: findRadiogramPlayer()

  // Mpris.players is an ObjectModel; its signals are not always reliably
  // exposed, so we poll lightly to detect new or removed players.
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.findRadiogramPlayer()
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.panelLoader.item.bar = root.bar
      root.panelLoader.item.anchorItem = button
      root.panelLoader.item.hostWidget = root
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.displayText()
    tooltipText: root.tooltipText()
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.togglePlayback()
      else if (buttonCode === Qt.RightButton) root.openPanel()
    }
  }
}
