import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

Text {
    id: volumeWidget

    property int volumeLevel: 0
    property bool volumeMuted: false
    property string audioSink: "speaker"     // speaker, headphone, hdmi, bluetooth
    property string defaultSinkName: ""      // actual pactl sink name

    property string volumeIcon: {
        if (volumeMuted) return "󰖁"
        if (audioSink === "headphone") return "󰋋"
        if (audioSink === "bluetooth") return "󰂰"
        if (audioSink === "hdmi") return "󰡁"
        if (volumeLevel < 30) return "󰕿"
        if (volumeLevel < 70) return "󰕾"
        return "󰕾"
    }

    text: volumeIcon + " " + volumeLevel + "%"
    color: volumeMuted ? Theme.colMuted :
           audioSink === "headphone" ? "#f1fa8c" :
           audioSink === "bluetooth" ? Theme.colBluetooth :
           Theme.colVol
    font.pixelSize: Theme.fontSize
    font.family: Theme.fontFamily
    font.bold: true

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: volumeControlProc.running = true
    }

    // 1) Get default sink name (PulseAudio)
    Process {
        id: defaultSinkProc
        command: ["pactl", "get-default-sink"]
        stdout: SplitParser {
            onRead: function(data) {
                if (!data) return
                volumeWidget.defaultSinkName = data.trim()
            }
        }
    }

    // 2) Get sink volume (PulseAudio)
    Process {
        id: volProc
        // we’ll set command dynamically once defaultSinkName is known
        stdout: SplitParser {
            onRead: function(data) {
                if (!data) return

                // Example line:
                // Volume: front-left: 65536 / 100% / 0.00 dB, front-right: 65536 / 100% / 0.00 dB
                var match = data.match(/\/\s*(\d+)%/);
                if (match) volumeWidget.volumeLevel = parseInt(match[1], 10)
            }
        }
    }

    // 3) Get sink mute (PulseAudio)
    Process {
        id: muteProc
        stdout: SplitParser {
            onRead: function(data) {
                if (!data) return
                // Example: "Mute: yes" / "Mute: no"
                volumeWidget.volumeMuted = data.toLowerCase().includes("yes")
            }
        }
    }

    // 4) Audio sink type detection (your existing logic, slightly safer)
    Process {
        id: sinkTypeProc
        command: ["pactl", "get-default-sink"]
        stdout: SplitParser {
            onRead: function(data) {
                if (!data) return
                var sink = data.toLowerCase()

                if (sink.includes("headphone") || sink.includes("headset")) {
                    volumeWidget.audioSink = "headphone"
                } else if (sink.includes("hdmi") || sink.includes("displayport")) {
                    volumeWidget.audioSink = "hdmi"
                } else if (sink.includes("bluez") || sink.includes("bluetooth")) {
                    volumeWidget.audioSink = "bluetooth"
                } else {
                    volumeWidget.audioSink = "speaker"
                }
            }
        }
    }

    // Volume control launcher (PulseAudio mixer UI)
    Process {
        id: volumeControlProc
        command: ["pavucontrol"]
    }

    function refreshVolume() {
        // Ensure we know the sink name first
        if (!volumeWidget.defaultSinkName || volumeWidget.defaultSinkName.length === 0) {
            defaultSinkProc.running = true
            sinkTypeProc.running = true
            return
        }

        // Set commands using the current default sink
        volProc.command = ["pactl", "get-sink-volume", volumeWidget.defaultSinkName]
        muteProc.command = ["pactl", "get-sink-mute", volumeWidget.defaultSinkName]

        volProc.running = true
        muteProc.running = true
        sinkTypeProc.running = true
    }

    Component.onCompleted: {
        // Initial load
        defaultSinkProc.running = true
        sinkTypeProc.running = true
        refreshVolume()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: refreshVolume()
    }
}
