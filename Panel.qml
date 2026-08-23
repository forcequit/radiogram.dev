import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// Radiogram detail panel for Omarchy Quattro.
// Shows the current station and a play/pause or open-app action.
Panel {
  id: root
  moduleName: "radiogram.radiogram"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null

  function open() { root.controller.show() }
  function close() { root.controller.hide() }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.hostWidget || root, direction)
    return false
  }

  function safeTitle() {
    return root.hostWidget && typeof root.hostWidget.safeTitle === "function"
      ? root.hostWidget.safeTitle()
      : "No station"
  }

  function player() {
    return root.hostWidget ? root.hostWidget.radiogramPlayer : null
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(280))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(12)

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: "Radiogram"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
          wrapMode: Text.WordWrap
        }

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: root.player() ? root.safeTitle() : "No player"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: root.player() ? (root.player().isPlaying ? "Playing" : "Paused") : "Idle"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }

        Rectangle {
          width: parent.width
          height: Style.space(36)
          color: buttonMouse.containsPress ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
          radius: Style.space(6)

          Text {
            anchors.centerIn: parent
            textFormat: Text.PlainText
            text: root.player() ? (root.player().isPlaying ? "Pause" : "Play") : "Open Radiogram"
            color: root.barForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
          }

          MouseArea {
            id: buttonMouse
            anchors.fill: parent
            onClicked: {
              const p = root.player()
              if (p && p.canTogglePlaying) {
                p.togglePlaying()
              } else {
                Qt.openUrlExternally("https://radiogram.dev")
              }
            }
          }
        }
      }
    }
  }
}
