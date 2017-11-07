import QtQuick 2.4
import Ubuntu.Components 1.3


BasePage {
    id: schedule
    title: i18n.tr('Schedule')
    visible: false

    property var model: ListModel {}

    anchors {
        fill: parent
        margins: units.gu(2)
    }

    ListView {
        anchors.fill: parent
        model: schedule.model

        delegate: ListItem {

            height: layout.height + (divider.visible ? divider.height : 0)
            ListItemLayout {
                id: layout
                title.text: model.title
                subtitle.text: "[" + day +"] " + start + " - " + end + " in " + room

                CheckBox {
                    SlotsLayout.position: SlotsLayout.Leading
                    id: saved_lecture
                    checked: lecture_checked
                    enabled: false
                }

                ProgressionSlot {}
            }

            onClicked: {
                lecture.set_lecture(schedule.model.get(index))
                pageStack.push(lecture)
            }
        }
    }
}
