import QtQuick 2.4
import Ubuntu.Components 1.1
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 0.1


BasePage {
    id: days
    title: 'Days'
    visible: false

    property string xmlsource: ""

    Column {
        id: daysLayout

        anchors {
            fill: parent
            margins: units.gu(2)
        }

        ListView {
            id: daylist
            anchors.fill: parent
            model: XmlListModel {
                id: daymodel
                source: days.xmlsource
                query: "/schedule/day"
                XmlRole {
                    name: "date"
                    query: "@date/string()"
                    //query: '*[name()="pentabarf:title"]/string()'
                }                
            }
            delegate: Standard {
                text: date
                progression: true
                onClicked: {
                    // XXX reset path and model
                    console.log("Path: " + path)
                    path = [daymodel.get(index).date]
                    track.model.clear()
                    py.call("backend.find_tracks_by_day", path, function(tracks) {                        
                        for (var i=0; i < tracks.length; i++) {
                            track.model.append(tracks[i]);
                        }
                        pageStack.push(track)
                    })
                }
            }

        }
    }
}


