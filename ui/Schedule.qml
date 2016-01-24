import QtQuick 2.4
import Ubuntu.Components 1.1
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 0.1


BasePage {
    id: schedule
    title: 'Schedule'
    visible: false

    property var model: ListModel {}

    Column {
        id: scheduleLayout

        anchors {
            fill: parent
            margins: units.gu(2)
        }

        ListView {
            anchors.fill: parent
            model: schedule.model

            delegate: Standard {
                progression: true
                onClicked: {
                    lecture.set_lecture(schedule.model.get(index))
                    pageStack.push(lecture)
                }
                Column {
                    spacing: units.gu(.5)
                    Label {
                        width: units.gu(44)
                        text: title
                        elide: Text.ElideMiddle
                    }
                    Row {
                        spacing: units.gu(1)
                        Label {
                            width: units.gu(8)
                            fontSize: "small"
                            text: start
                        }
                        Label {
                            width: units.gu(8)
                            fontSize: "small"
                            text: duration + "h"
                        }
                        Label {
                            width: units.gu(6)
                        }
                        Label {
                            width: units.gu(13)
                            fontSize: "small"
                            text: room
                        }
                    }
                }
            }
        }
    }
}
