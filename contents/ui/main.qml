import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.clock as PlasmaClock
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.calendar as PlasmaCalendar

PlasmoidItem {
    id: root
    toolTipMainText: ""
    toolTipSubText: ""

    Layout.minimumWidth: Kirigami.Units.gridUnit * 4
    Layout.minimumHeight: Kirigami.Units.gridUnit * 2.5

    PlasmaClock.Clock {
        id: clock
        trackSeconds: root.expanded
    }

    compactRepresentation: Item {
        Layout.preferredWidth: container.implicitWidth
        Layout.preferredHeight: container.implicitHeight

        Column {
            id: container
            anchors.centerIn: parent
            spacing: Plasmoid.configuration.spacing

            PlasmaComponents.Label {
                id: timeLabel
                text: {
                    var d = clock.dateTime;
                    var hours = d.getHours();
                    var ampm = hours >= 12 ? "PM" : "AM";
                    hours = hours % 12;
                    hours = hours ? hours : 12;
                    var minutes = d.getMinutes().toString().padStart(2, "0");
                    return hours + ":" + minutes + " " + ampm;
                }
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font.pixelSize: Plasmoid.configuration.timeFontSize > 0 ? Plasmoid.configuration.timeFontSize : 16
                font.family: Plasmoid.configuration.useCustomFont && Plasmoid.configuration.fontFamily !== "" ? Plasmoid.configuration.fontFamily : ""
                font.bold: Plasmoid.configuration.fontBold
                font.italic: Plasmoid.configuration.fontItalic
                color: Plasmoid.configuration.useCustomColor ? Plasmoid.configuration.fontColor : Kirigami.Theme.textColor
            }

            PlasmaComponents.Label {
                id: dateLabel
                text: {
                    var d = clock.dateTime;
                    return (d.getMonth() + 1) + "/" + d.getDate() + "/" + d.getFullYear().toString().slice(-2);
                }
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font.pixelSize: Plasmoid.configuration.dateFontSize > 0 ? Plasmoid.configuration.dateFontSize : 11
                font.family: Plasmoid.configuration.useCustomFont && Plasmoid.configuration.fontFamily !== "" ? Plasmoid.configuration.fontFamily : ""
                font.bold: Plasmoid.configuration.fontBold
                font.italic: Plasmoid.configuration.fontItalic
                color: Plasmoid.configuration.useCustomColor ? Plasmoid.configuration.fontColor : Kirigami.Theme.textColor
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 24
        Layout.preferredHeight: Kirigami.Units.gridUnit * 27

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.20
            radius: 0
            z: 0
        }

        Connections {
            target: root
            function onExpandedChanged() {
                if (root.expanded) {
                    calendarView.today = new Date();
                    calendarView.resetToToday();
                }
            }
        }

        Component.onCompleted: {
            calendarView.today = new Date();
            calendarView.resetToToday();
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit
            spacing: Kirigami.Units.gridUnit
            z: 1

            // Time with seconds: e.g. 11:47:35 AM
            PlasmaComponents.Label {
                id: popupTimeLabel
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 2.8
                font.bold: true
                font.family: Plasmoid.configuration.useCustomFont && Plasmoid.configuration.fontFamily !== "" ? Plasmoid.configuration.fontFamily : ""
                color: Plasmoid.configuration.useCustomColor ? Plasmoid.configuration.fontColor : Kirigami.Theme.textColor
                text: {
                    var d = clock.dateTime;
                    var hours = d.getHours();
                    var ampm = hours >= 12 ? "PM" : "AM";
                    hours = hours % 12;
                    hours = hours ? hours : 12;
                    var minutes = d.getMinutes().toString().padStart(2, "0");
                    var seconds = d.getSeconds().toString().padStart(2, "0");
                    return hours + ":" + minutes + ":" + seconds + " " + ampm;
                }
            }

            // Calendar MonthView Container (Read-Only)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                PlasmaCalendar.MonthView {
                    id: calendarView
                    anchors.fill: parent
                    showWeekNumbers: false
                    today: new Date()
                    currentDate: new Date()
                    borderWidth: 0

                    Component.onCompleted: {
                        if (viewHeader) {
                            if (viewHeader.todayButton) {
                                viewHeader.todayButton.visible = false;
                            }
                            if (viewHeader.heading) {
                                viewHeader.heading.horizontalAlignment = Text.AlignHCenter;
                            }
                        }
                    }
                }

                // Transparent MouseArea that absorbs all clicks on the day grid
                // while leaving the header controls (month/year changers) fully interactive.
                MouseArea {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    y: (calendarView.viewHeader ? calendarView.viewHeader.height : 0)
                    height: parent.height - y
                    hoverEnabled: true
                }
            }
        }
    }
}
