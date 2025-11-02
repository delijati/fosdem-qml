import QtQuick 2.9
import Lomiri.Components 1.3


Page {
    id: nowPage

    header: CommonHeader {
        title: i18n.tr('Now')
        flickable: nowListView
        
        extension: Rectangle {
            height: units.gu(8)
            color: theme.palette.normal.background
            
            Column {
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                spacing: units.gu(0.5)
                
                Label {
                    text: i18n.tr("Show only marked:")
                    fontSize: "small"
                }
                
                Switch {
                    id: markedSwitch
                    checked: nowPage.showOnlyMarked
                    onCheckedChanged: {
                        nowPage.showOnlyMarked = checked
                        nowPage.loadCurrentLectures()
                    }
                }
            }
        }
    }

    property var model: ListModel {}
    property bool showOnlyMarked: false

    Component.onCompleted: {
        loadCurrentLectures()
    }

    function loadCurrentLectures() {
        model.clear()
        py.call("backend.get_current_lectures", [showOnlyMarked], function(lectures) {
            for (var i=0; i < lectures.length; i++) {
                model.append(lectures[i]);
            }
        })
    }

    ListView {
        id: nowListView
        anchors.fill: parent
        model: nowPage.model
        delegate: nowDelegate
    }

    Component {
        id: nowDelegate

        ListItem {
            divider.visible: false
            highlightColor: hlColor

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
                pageStack.push(Qt.resolvedUrl("Lecture.qml"), {"model": nowPage.model.get(index)})
            }
        }
    }

    Loader {
        id: emptyStateLoader
        width: parent.width
        anchors.centerIn: parent
        active: nowPage.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No lectures happening now')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
