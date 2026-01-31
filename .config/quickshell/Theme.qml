pragma Singleton
import QtQuick

QtObject {
    // Theme colors - Tokyo Night (Storm)
    readonly property color colBg: "#24283b"                // Background
    readonly property color colBgTransparent: "transparent"
    readonly property color colFg: "#c0caf5"                // Foreground text
    readonly property color colMuted: "#565f89"             // Muted / separators

    // Modules / accents
    readonly property color colClock: "#ff9e64"             // Orange
    readonly property color colCpu: "#7aa2f7"               // Blue
    readonly property color colMem: "#9ece6a"               // Green
    readonly property color colDisk: "#e0af68"              // Yellow
    readonly property color colVol: "#9ece6a"               // Green
    readonly property color colNetwork: "#f7768e"           // Red/Pink
    readonly property color colBluetooth: "#7dcfff"         // Cyan
    readonly property color colSlack: "#bb9af7"             // Purple
    readonly property color colWhatsapp: "#73daca"          // Teal

    // Workspaces / window
    readonly property color colWorkspaceActive: "#c0caf5"   // Bright foreground
    readonly property color colWorkspaceInactive: "#565f89" // Muted
    readonly property color colWindow: "#bb9af7"            // Purple
    readonly property color colKernel: "#f7768e"            // Red

    // Font
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 15
}
