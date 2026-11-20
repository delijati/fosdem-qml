import QtQuick 2.9
import Lomiri.Components 1.3


Page {
    id: lecture

    header: CommonHeader {
        title: i18n.tr('Lecture')
        flickable: lectureFlickable
    }

    property int event_id: 0
    property var model: ListModel {}
    property real itemName: units.gu(7)
    property real itemTime: units.gu(8)
    property var links: ListModel {}
    property alias abstractLabel: lecture_abstract

    function openLink(link) {
        mainView.openUrl(link);
    }

    function linkTitle(link) {
        if (link.kind === "event")
            return i18n.tr("Event page");
        if (link.kind === "feedback")
            return i18n.tr("Feedback");
        return link.title;
    }

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

        py.call("backend.get_links", [item.id], function(found) {
            links.clear();
            for (var i = 0; i < found.length; i++) {
                links.append(found[i]);
            }
        });
    }

    Component.onCompleted: set_lecture(lecture.model);

    Flickable {
        id: lectureFlickable
        contentHeight: contentItem.childrenRect.height

        anchors {
            fill: parent
            leftMargin: gnalMargins
            rightMargin: gnalMargins
            bottomMargin: gnalMargins
        }

        Column {
            id: mainCol
            width: parent.width
            spacing: gnalSpacing

            anchors {
                top: parent.top
                topMargin: gnalMargins
            }

            Row {
                width: parent.width
                spacing: gnalSpacing

                LabelBase {
                    id: lecture_title
                    font.bold: true
                    width: parent.width - lecture_checked.width - gnalSpacing
                    verticalAlignment: Text.AlignVCenter
                }

                Favorite {
                    id: lecture_checked
                    width: units.gu(3)
                    height: width

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            py.call('backend.toggle', [lecture.model], function (data) {
                                lecture.model.lecture_checked = data;
                                lecture_checked.checked = data;
                            });
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: gnalSpacing

                LabelBase {
                    text: i18n.tr('Time')
                    width: itemName
                    font.bold: true
                }

                LabelBase {
                    id: lecture_start
                    width: itemTime
                }

                LabelBase {
                    id: lecture_end
                    width: itemTime
                }
            }

            Row {
                width: parent.width
                spacing: gnalSpacing

                LabelBase {
                    text: i18n.tr('Room')
                    width: itemName
                    font.bold: true
                }

                LabelBase {
                    id: lecture_room
                    width: parent.width - itemName - gnalSpacing
                    horizontalAlignment: Text.AlignLeft
                }
            }

            Row {
                width: parent.width
                spacing: gnalSpacing

                LabelBase {
                    text: i18n.tr('Speaker')
                    width: itemName
                    font.bold: true
                }

                LabelBase {
                    id: lecture_persons
                    width: parent.width - itemName - gnalSpacing
                    horizontalAlignment: Text.AlignLeft
                }
            }

            LabelBase {
                id: lecture_subtitle
                visible: text !== ""
            }

            LabelBase {
                id: lecture_abstract
                visible: text !== ""
                onLinkActivated: lecture.openLink(link)
            }

            LabelBase {
                id: lecture_description
                visible: text !== ""
                onLinkActivated: lecture.openLink(link)
            }

            LabelBase {
                text: i18n.tr("Links")
                font.bold: true
                visible: lecture.links.count > 0
            }

            Repeater {
                model: lecture.links

                LabelBase {
                    text: "<a href='" + model.href + "'>" + lecture.linkTitle(model) + "</a>"
                    textFormat: Text.StyledText
                    linkColor: accentColor
                    horizontalAlignment: Text.AlignLeft
                    onLinkActivated: lecture.openLink(link)
                }
            }
        }
    }
}
