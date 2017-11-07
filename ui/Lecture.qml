import QtQuick 2.4
import Ubuntu.Components 1.3


BasePage {
    id: lecture
    title: i18n.tr("Lecture")
    visible: false

    property int event_id: 0
    property var model: ListModel {}

    function set_lecture(item) {
        lecture.model = item
        lecture.event_id = item.id

        lecture_start.text = item.start
        lecture_end.text = item.end
        lecture_room.text = item.room
        lecture_title.text = item.title
        lecture_subtitle.text = item.subtitle
        lecture_abstract.text = item.abstract
        lecture_description.text = item.description
        lecture_persons.text = item.persons
        lecture_checked.checked = item.lecture_checked
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
                Switch {
                    anchors.verticalCenter: parent.verticalCenter
                    id: lecture_checked
                    enabled: true
                    checked: false
                    
                    onClicked: {
                        py.call('backend.toggle', [lecture.model], function (data) {
                            lecture.model.lecture_checked = data;
                            lecture_checked.checked = data;
                        });
                    }
                }
            }
            Row {
                spacing: units.gu(1)
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr('Room')
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


