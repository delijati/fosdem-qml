import QtQuick 2.9
import Ubuntu.Components 1.3


Page {
    id: schedule

    header: CommonHeader {
        title: i18n.tr('Schedule')
        flickable: scheduleListView
    }

    property var model: ListModel {}

    ListView {
        id: scheduleListView
        anchors.fill: parent
        model: schedule.model
        delegate: scheduleDelegate
    }

    Component {
        id: scheduleDelegate

        ListItem {
            divider.visible: false
            highlightColor: hlColor

            ListItemLayout {
                id: layout
                title.text: model.title
                subtitle.text: "[" + day +"] " + start + " - " + end + " " + i18n.tr('in') + " " + room

                Favorite {
                    id: saved_lecture
                    width: units.gu(2)
                    height: width
                    SlotsLayout.position: SlotsLayout.Leading
                    checked: lecture_checked
                }

                ProgressionSlot {}
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("Lecture.qml"), {"model": schedule.model.get(index)})
            }
        }
    }

    Loader {
        id: emptyStateLoader
        width: parent.width
        anchors.centerIn: parent
        active: schedule.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No schedule info')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
