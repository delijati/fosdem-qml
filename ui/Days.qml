import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0


Page {
    id: days

    header: CommonHeader {
        title: i18n.tr('Days')
        flickable: daylist
    }

    property string xmlsource: ""
    property var trackModel: ListModel {}

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
        delegate: daysDelegate
        header: storiesMainIcon
    }
    
    Component {
        id: daysDelegate

        ListItem {
            divider.visible: false

            ListItemLayout {
                id: layout
                title.text: model.date

                ProgressionSlot {}
            }

            onClicked: {
                // XXX reset path and model
                //console.log("Path: " + path)
                trackModel.clear();
                path = [daymodel.get(index).date]
                py.call("backend.find_tracks_by_day", path, function(tracks) {                        
                    for (var i=0; i < tracks.length; i++) {
                        trackModel.append(tracks[i]);
                    }
                    pageStack.push(Qt.resolvedUrl("Track.qml"), {"model": trackModel})
                })
            }
        }
    }
    
    Component {
        id: storiesMainIcon
        
        UbuntuShape {
            anchors.horizontalCenter: parent.horizontalCenter
            aspect: UbuntuShape.Flat
            width: units.gu(17)
            height: width

            image: Image {
                source: "../images/icon.svg"
                sourceSize.width: units.gu(17)
            }
        }
    }
}


