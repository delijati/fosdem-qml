import QtQuick 2.9
import Lomiri.Components 1.3

Page {
    objectName: "daysPage"
    id: days
    anchors.fill: parent

    header: CommonHeader {
        id: dayHeader
        title: i18n.tr('Days')
        flickable: viewLoader.item
    }

    property var trackModel: ListModel {}

    // Conditional layout: use GridView for landscape/tablet, ListView for portrait
    Loader {
        id: viewLoader
        anchors.fill: parent
        sourceComponent: mainView.isLandscape || mainView.columns > 1 ? gridViewComponent : listViewComponent
    }

    Component {
        id: listViewComponent
        
        ListView {
            id: daylist
            clip: true

            model: dayModel
            delegate: daysDelegate
            header: fosdemIcon
        }
    }

    Component {
        id: gridViewComponent
        
        GridView {
            id: daygrid
            clip: true
            cellWidth: width / mainView.columns
            cellHeight: units.gu(15)

            model: dayModel
            delegate: daysDelegate
            header: fosdemIcon
        }
    }

    property var dayModel: ListModel {}

    function loadDays() {
        py.call("backend.get_days", [], function(dayList) {
            dayModel.clear();
            for (var i = 0; i < dayList.length; i++) {
                dayModel.append(dayList[i]);
            }
        });
    }

    Component.onCompleted: loadDays()

    Connections {
        target: mainView

        function onScheduleChanged() { loadDays(); }
    }

    Component {
        id: daysDelegate

        ListItem {
            divider.visible: false
            highlightColor: hlColor

            ListItemLayout {
                id: layout
                title.text: mainView.dayLabel(model.date)

                ProgressionSlot {}
            }

            onClicked: {
                trackModel.clear();
                path = [dayModel.get(index).date]
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

        LomiriShape {
            anchors.horizontalCenter: parent.horizontalCenter
            aspect: LomiriShape.Flat
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
        active: dayModel.count === 0
        sourceComponent: Label {
            text: i18n.tr('Empty database')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}


