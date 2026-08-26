// theme-picker — a one-shot Quickshell shell.
// Launched by the Hyprland keybind `SUPER + ALT + T`:
//   qs -p ~/.config/quickshell/theme-picker
// Reads `theme-switcher --dump` once at open (JSON: {current, themes[]}),
// shows a centered grid of rounded rectangles colored by each theme's
// base00, labeled with each theme's name in its base0A primary color, and
// applies the selected theme via the existing theme-switcher script, then
// quits. State is held only for the lifetime of the picker.
//
// IMPORTANT: the shell ROOT must be a Window type (PanelWindow), NOT a plain
// `Item`. A bare top-level Item makes Quickshell open an extra WM-managed
// `org.quickshell` window that is tiled and displaces other windows; the
// PanelWindow is the layer-surface overlay (never WM-managed). Verified live
// via `hyprctl clients` (Item root -> +2 managed windows, PanelWindow root -> +0).

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    // Cover the whole screen so ESC/backdrop-click works anywhere and the grid
    // can center on the active screen. (Multi-monitor placement is deferred;
    // this shows on screens[0].)
    anchors { top: true; left: true; right: true; bottom: true }
    aboveWindows: true     // surface on the overlay layer, floats above normal windows
    focusable: true        // grab keyboard for vim/arrow/enter/esc nav
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: -1      // overlay, reserve no space
    color: Qt.rgba(0, 0, 0, 0.45) // dim the desktop behind the picker

    // Resolved at load. Assumes the repo lives at ~/ndots (same assumption as
    // the nixs/hms aliases). Move the repo -> update this path.
    readonly property string switcher:
        Quickshell.env("HOME") + "/ndots/tooling/theme-switcher/theme-switcher"

    // NOTE: Process.command is a QQmlListProperty -> only assignable at declaration
    // time (a literal array), never via a JS `= [..]` in a function body. So applying
    // a theme uses Quickshell.execDetached() instead of a runtime-configured Process.

    property var themes: []
    property int currentIndex: 0

    // Grid layout: 5 columns -> 10 current themes wrap to 2 rows. Adding/removing
    // a themes/*.yaml just flows into the grid; no manual count to keep.
    readonly property int columns: 5

    function quit() { Qt.quit() }

    function move(dr: int, dc: int) {
        if (!root.themes.length) return
        const cols = root.columns
        const rows = Math.ceil(root.themes.length / cols)
        let r = Math.floor(root.currentIndex / cols) + dr
        let c = (root.currentIndex % cols) + dc
        if (r < 0) r = 0; else if (r >= rows) r = rows - 1
        if (c < 0) c = 0; else if (c >= cols) c = cols - 1
        let ni = r * cols + c
        if (ni >= root.themes.length) ni = root.themes.length - 1
        root.currentIndex = ni
    }

    function apply(i: int) {
        if (i < 0 || i >= root.themes.length) return
        // fire-and-forget: the switcher applies the theme live and keeps running
        // after we quit.
        Quickshell.execDetached([root.switcher, root.themes[i].slug])
        root.quit()
    }

    // One-shot load of the theme list + current theme at open.
    Process {
        id: dumpProc
        command: [root.switcher, "--dump"]
        running: true
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                try {
                    const j = JSON.parse(collector.text)
                    root.themes = j.themes || []
                    // initial focus on the live theme, falling back to the first.
                    let idx = 0
                    for (let k = 0; k < root.themes.length; k++)
                        if (root.themes[k].slug === j.current) { idx = k; break }
                    root.currentIndex = idx
                } catch (e) {
                    console.error("theme-picker: bad --dump output: " + collector.text)
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event) => {
            switch (event.key) {
                case Qt.Key_Escape:    root.quit(); event.accepted = true; break
                case Qt.Key_Return:
                case Qt.Key_Enter:     root.apply(root.currentIndex); event.accepted = true; break
                case Qt.Key_H: case Qt.Key_Left:  root.move(0, -1); event.accepted = true; break
                case Qt.Key_L: case Qt.Key_Right: root.move(0,  1); event.accepted = true; break
                case Qt.Key_J: case Qt.Key_Down:  root.move( 1, 0); event.accepted = true; break
                case Qt.Key_K: case Qt.Key_Up:    root.move(-1, 0); event.accepted = true; break
            }
        }

        // Clicking the dimmed backdrop dismisses the picker.
        MouseArea {
            anchors.fill: parent
            onClicked: root.quit()
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            // size to the grid + padding
            width: grid.width + 2 * grid.spacing + 24
            height: grid.height + 2 * grid.spacing + 24
            radius: 22
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.15) // subtle frame

            GridLayout {
                id: grid
                anchors.centerIn: parent
                columns: root.columns
                rowSpacing: 18
                columnSpacing: 18

                Repeater {
                    model: root.themes
                    delegate: Rectangle {
                        width: 170
                        height: 96
                        radius: 16
                        color: "#" + modelData.bg

                        readonly property bool active: root.currentIndex === index

                        border.width: active ? 3 : 1
                        border.color: active ? "#ffffff" : Qt.rgba(255, 255, 255, 0.12)
                        scale: active ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 80 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            color: "#" + modelData.primary
                            font.bold: true
                            font.pixelSize: 15
                            // keep the label readable on any base color
                            style: Text.Raised
                            styleColor: Qt.rgba(0, 0, 0, 0.35)
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            width: parent.width - 16
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: root.currentIndex = index
                            onClicked: root.apply(index)
                        }
                    }
                }
            }
        }
    }
}