import QtQuick 2.9
import Lomiri.Components 1.3

Page {
    id: track

    header: CommonHeader {
        title: i18n.tr('Track')
        flickable: listView
    }

    property var model: ListModel {}
    property var scheduleModel: ListModel {}

    anchors.fill: parent

    ListView {
        id: listView
        anchors.fill: parent
        model: track.model
        delegate: trackDelegate
    }

    Component {
        id: trackDelegate

        ListItem {
            divider.visible: false
            highlightColor: hlColor

            ListItemLayout {
                id: layout
                title.text: model.title || i18n.tr("Other")

                ProgressionSlot {}
            }

            onClicked: {
                path = [path[0], track.model.get(index).title]
                scheduleModel.clear()
                py.call("backend.find_events_by_day_track", path, function(events) {
                    for (var i=0; i < events.length; i++) {
                        scheduleModel.append(events[i]);
                    }

                    pageStack.push(Qt.resolvedUrl("Schedule.qml"), {"model": scheduleModel})
                })
            }
        }
    }

    Loader {
        id: emptyStateLoader
        width: parent.width
        anchors.centerIn: parent
        active: track.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No track info')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
