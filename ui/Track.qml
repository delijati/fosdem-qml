import QtQuick 2.4
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import QtQuick.XmlListModel 2.0


BasePage {
    id: track
    title: "Tracks"
    visible: false

    property var model: ListModel {}

    Column {
        anchors {
            fill: parent
            margins: units.gu(2)
        }

        ListView {
            anchors.fill: parent
            model: track.model
            delegate: Standard {
                text: title
                progression: true
                onClicked: {
                    // XXX reset path and model
                    console.log("Path: " + path)
                    path = [path[0], track.model.get(index).title]
                    schedule.model.clear()
                    py.call("backend.find_events_by_day_track", path, function(events) {
                        console.log(events[0].title)
                        console.log(events[0].start)
                        console.log(events[0].end)
                        console.log(events[0].duration)
                        console.log(events[0].room)
                        console.log(events[0].persons)
                        console.log(events[0].lecture_checked)

                        for (var i=0; i < events.length; i++) {
                            schedule.model.append(events[i]);
                        }
                        pageStack.push(schedule)
                    })
                }
            }
        }
    }
}
