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
                title.text: model.title

                ProgressionSlot {}
            }

            onClicked: {
                // XXX reset path and model
                //console.log("Path: " + path)
                path = [path[0], track.model.get(index).title]
                scheduleModel.clear()
                py.call("backend.find_events_by_day_track", path, function(events) {
                    //console.log("Title: " + events[0].title)
                    //console.log("Start: " + events[0].start)
                    //console.log("End: " + events[0].end)
                    //console.log("Duration: " + events[0].duration)
                    //console.log("Room: " + events[0].room)
                    //console.log("Persons: " + events[0].persons)
                    //console.log("Checked: " + events[0].lecture_checked)

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
