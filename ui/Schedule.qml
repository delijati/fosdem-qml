import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem


BasePage {
    id: schedule
    title: i18n.tr('Schedule')
    visible: false

    property var model: ListModel {}

    Column {
        anchors {
            fill: parent
            margins: units.gu(2)
        }

        ListView {
            anchors.fill: parent
            model: schedule.model

            delegate: ListItem.Standard {
                progression: true
                onClicked: {
                    lecture.set_lecture(schedule.model.get(index))
                    pageStack.push(lecture)
                }

                Row {
                    id: checkbox_row
                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: saved_lecture
                        anchors.verticalCenter: parent.verticalCenter
                        checked: lecture_checked
                        enabled: false
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: checkbox_row.right
                    spacing: units.gu(1)
                    anchors.margins: units.gu(1)

                    Column {

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            width: units.gu(38)
                            text: title
                            fontSize: "small"
                            elide: Text.ElideMiddle
                        }
                    }

                    Row {
                        anchors.top: parent.bottom

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            width: units.gu(10)
                            text: "[" + day +"]"
                            fontSize: "small"
                        }

                        Label {
                            width: units.gu(6)
                            fontSize: "small"
                            text: start
                        }

                        Label {
                            width: units.gu(6)
                            fontSize: "small"
                            text: end
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
