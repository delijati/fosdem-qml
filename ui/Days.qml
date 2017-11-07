import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem


BasePage {
    id: days
    title: i18n.tr('Days')
    visible: false

    property string xmlsource: ""

    anchors {
        fill: parent
        margins: units.gu(2)
    }

    ListView {
        id: daylist
        clip: true
        anchors.fill: parent
        model: XmlListModel {
            id: daymodel
            source: days.xmlsource
            onSourceChanged: {
                console.log("Source changed")
                reload()
            }
            query: "/schedule/day"
            XmlRole {
                name: "date"
                query: "@date/string()"
                //query: '*[name()="pentabarf:title"]/string()'
            }                
        }
        delegate: ListItem.Standard {

            progression: true
            Row {
                id: rowItem
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                spacing: units.gu(2)

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: date
                }
            }
            onClicked: {
                // XXX reset path and model
                //console.log("Path: " + path)
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


