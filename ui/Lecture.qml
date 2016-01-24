import QtQuick 2.4
import Ubuntu.Components 1.1
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 0.1


BasePage {
    id: lecture
    title: "Lecture"
    visible: false

    function set_lecture(item) {
        lecture_start.text = item.start
        lecture_end.text = item.end
        lecture_room.text = item.room
        lecture_title.text = item.title
        lecture_subtitle.text = item.subtitle
        lecture_abstract.text = item.abstract
        lecture_description.text = item.description
        lecture_persons.text = item.persons
    }

    Flickable {
        id: lectureFlickable
        anchors {
            fill: parent
            margins: units.gu(2)
        }
        contentHeight: contentItem.childrenRect.height

        Column {
            width: parent.width
            spacing: units.gu(1)

            Row {
                spacing: units.gu(1)
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: 'Time'
                    width: units.gu(5)
                }

                TextField {
                    id: lecture_start
                    width: units.gu(8)
                    readOnly: true

                    UbuntuShape {
                        z: -1
                        color: Theme.palette.normal.field
                        anchors.fill: parent
                    }
                }
                TextField {
                    id: lecture_end
                    width: units.gu(8)
                    readOnly: true

                    UbuntuShape {
                        z: -1
                        color: Theme.palette.normal.field
                        anchors.fill: parent
                    }
                }
            }
            Row {
                spacing: units.gu(1)
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: 'Room'
                    width: units.gu(5)
                }
                TextField {
                    id: lecture_room
                    width: units.gu(20)
                    readOnly: true

                    UbuntuShape {
                        z: -1
                        color: Theme.palette.normal.field
                        anchors.fill: parent
                    }
                }
            }
            TextArea {
                id: lecture_title
                width: parent.width
                autoSize: true
                maximumLineCount: 0
                readOnly: true

                UbuntuShape {
                    z: -1
                    color: Theme.palette.normal.field
                    anchors.fill: parent
                }
            }
            TextArea {
                id: lecture_subtitle
                width: parent.width
                autoSize: true
                maximumLineCount: 0
                readOnly: true

                UbuntuShape {
                    z: -1
                    color: Theme.palette.normal.field
                    anchors.fill: parent
                }
            }
            TextArea {
                id: lecture_abstract
                textFormat: TextEdit.RichText
                width: parent.width
                autoSize: true
                maximumLineCount: 0
                readOnly: true

                UbuntuShape {
                    z: -1
                    color: Theme.palette.normal.field
                    anchors.fill: parent
                }
            }
            TextArea {
                id: lecture_description
                textFormat: TextEdit.RichText
                width: parent.width
                autoSize: true
                maximumLineCount: 0
                readOnly: true

                UbuntuShape {
                    z: -1
                    color: Theme.palette.normal.field
                    anchors.fill: parent
                }
            }
            TextArea {
                id: lecture_persons
                width: parent.width
                autoSize: true
                maximumLineCount: 0
                readOnly: true

                UbuntuShape {
                    z: -1
                    color: Theme.palette.normal.field
                    anchors.fill: parent
                }
            }
        }
    }
    Scrollbar {
        flickableItem: lectureFlickable
        align: Qt.AlignTrailing
    }
}


