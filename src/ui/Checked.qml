import QtQuick 2.9
import Lomiri.Components 1.3


Page {
    id: checked

    header: CommonHeader {
        title: i18n.tr('Checked')
        flickable: checkedlistView
    }

    property var model: ListModel {}

    anchors.fill: parent

    function load() {
        py.call("backend.select_all", [], function (events) {
            checked.model.clear();
            for (var i=0; i < events.length; i++) {
                checked.model.append(events[i]);
            }
        });
    }

    Component.onCompleted: load()

    // Reload when coming back, e.g. after unmarking a talk on its page.
    onVisibleChanged: {
        if (visible) {
            load();
        }
    }

    ListView {
        id: checkedlistView
        anchors.fill: parent
        model: checked.model
        delegate: checkedDelegate

        section.property: "day"
        section.delegate: SectionHeader {
            text: mainView.dayLabel(section)
        }
    }

    Component {
        id: checkedDelegate

        LectureListItem {
            lecture: model

            onClicked: {
                pageStack.push(Qt.resolvedUrl("Lecture.qml"), {"model": checked.model.get(index)})
            }
        }
    }

    Loader {
        id: emptyStateLoader
        width: parent.width
        anchors.centerIn: parent
        active: checked.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No favorites yet')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
