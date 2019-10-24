import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.XmlListModel 2.0

Page {
    objectName: "daysPage"
    id: days
    anchors.fill: parent

    header: CommonHeader {
        id: dayHeader
        title: i18n.tr('Days')
        flickable: daylist
    }

    property var trackModel: ListModel {}

    ListView {
        id: daylist
        clip: true

        anchors.fill: parent

        model: daymodel

        delegate: daysDelegate
        header: fosdemIcon
    }

    XmlListModel {
        id: daymodel
        source: xmlsource

        query: "/schedule/day"

        XmlRole {
            name: "date"
            query: "@date/string()"
            //query: '*[name()="pentabarf:title"]/string()'
        }
    }

    Connections {
        target: mainView

        onXmlChanged: {
            console.log("Source changed")
            daymodel.reload()
        }
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
        id: fosdemIcon

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

    Loader {
        id: emptyStateLoader
        width: parent.width
        anchors.centerIn: parent
        active: daymodel.count === 0
        sourceComponent: Label {
            text: i18n.tr('Empty database')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}


