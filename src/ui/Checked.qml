import QtQuick 2.9
import Ubuntu.Components 1.3


Page {
    id: checked

    header: CommonHeader {
        title: i18n.tr('Checked')
        flickable: checkedlistView
    }

    property var model: ListModel {}

    anchors.fill: parent

    Component.onCompleted: {
        checked.model.clear();
        py.call("backend.select_all", [], function (events) {
            for (var i=0; i < events.length; i++) {
                checked.model.append(events[i]);
            }
        });
    }

    ListView {
        id: checkedlistView
        anchors.fill: parent
        model: checked.model
        delegate: checkedDelegate
    }

    Component {
        id: checkedDelegate

        ListItem {
            divider.visible: false

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
                pageStack.push(Qt.resolvedUrl("Lecture.qml"), {"model": checked.model.get(index)})
            }
        }
    }

    Loader {
        id: emptyStateLoader
        width: parent.width
        anchors.centerIn: parent
        active: checked.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No favorites yet')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
