import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell

Item {
    id: appsRoot
    
    property int dockSize: 40
    property real spacing: 8
    
    // Model to store running applications
    ListModel {
        id: runningApps
    }
    
    // Hyprland client to get window information
    Component.onCompleted: {
        updateRunningApps()
        // Set up periodic updates or use Hyprland events
        refreshTimer.start()
    }
    
    // Timer to periodically refresh app list
    Timer {
        id: refreshTimer
        interval: 2000 // Update every 2 seconds
        repeat: true
        running: false
        onTriggered: updateRunningApps()
    }
    
    // Function to get running apps from Hyprland
    function updateRunningApps() {
    const raw = Hyprland.sendCommand("j/clients")
    console.log("RAW CLIENTS:", raw, typeof raw)
}


    
    // Actual apps layout
    Row {
        id: appsRow
        anchors.centerIn: parent
        spacing: appsRoot.spacing
        
        Repeater {
            model: runningApps
            
            Item {
                id: appItem
                
                width: appsRoot.dockSize
                height: appsRoot.dockSize
                
                // App icon representation
                Rectangle {
                    id: appIcon
                    anchors.centerIn: parent
                    width: appsRoot.dockSize * 0.8
                    height: appsRoot.dockSize * 0.8
                    radius: 8
                    color: model.minimized ? "#888888" : "#ffffff" // Gray if minimized
                    
                    Text {
                        anchors.centerIn: parent
                        text: model.name.charAt(0).toUpperCase()
                        font.pixelSize: appsRoot.dockSize * 0.3
                        font.bold: true
                        color: "#000000"
                    }
                    
                    // Active indicator (dot below icon)
                    Rectangle {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.bottom
                            topMargin: 2
                        }
                        width: 6
                        height: 6
                        radius: 3
                        color: model.minimized ? "#ff9900" : "#00ff00" // Orange if minimized, green if active
                        visible: true
                    }
                }
                
                // Hover effect with magnification
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    onEntered: {
                        appIcon.scale = 1.2
                    }
                    onExited: {
                        appIcon.scale = 1.0
                    }
                    
                    onClicked: {
                        // Focus the window using Hyprland command
                        Hyprland.sendCommand(`dispatch focuswindow address:${model.address}`)
                        console.log("Focusing app:", model.name, "Address:", model.address)
                    }
                }
                
                // Animation for smooth scaling
                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }
        }
    }
    
    // Listen to Hyprland events for real-time updates
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "openwindow" || 
                event.name === "closewindow" || 
                event.name === "movewindow" ||
                event.name === "changefloatingmode") {
                updateRunningApps()
            }
        }
    }
}