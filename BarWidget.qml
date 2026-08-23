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

  // MPRIS metadata is external, untrusted input controlled by the browser or
  // player. Strip control characters and markup-shaped characters, and cap the
  // retained length before it reaches any text sink in the shared shell process.
  readonly property int maxTitleLength: 64

  function safeTitle() {
    const raw = root.radiogramPlayer ? root.radiogramPlayer.trackTitle : ""
    if (!raw || typeof raw !== "string") return "Radiogram"
    let t = raw.replace(/[\u0000-\u001f\u007f-\u009f]/g, " ")
    t = t.replace(/[<>&]/g, " ")
    t = t.replace(/\s+/g, " ").trim()
    if (t.length === 0) return "Radiogram"
    if (t.length > root.maxTitleLength) t = t.substring(0, root.maxTitleLength - 1) + "\u2026"
    return t
  }

  function displayText() {
    if (!root.radiogramPlayer) return "\u25cb Radiogram"
    const icon = root.radiogramPlayer.isPlaying ? "\u25b6" : "\u23f8"
    return icon + " " + root.safeTitle()
  }

  function tooltipText() {
    if (!root.radiogramPlayer) return "Radiogram is idle\nClick to open"
    const status = root.radiogramPlayer.isPlaying ? "Playing" : "Paused"
    return root.safeTitle() + "\nStatus: " + status + "\nClick to play/pause\nRight-click for panel"
  }

  function togglePlayback() {
    if (root.radiogramPlayer && root.radiogramPlayer.canTogglePlaying) {
      root.radiogramPlayer.togglePlaying()
    } else {
      Qt.openUrlExternally("https://radiogram.dev")
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
    // Sanitised, length-capped plain strings only: no markup or resource
    // references can reach the shared shell's text rendering.
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.togglePlayback()
      else if (buttonCode === Qt.RightButton) root.openPanel()
    }
  }
}
