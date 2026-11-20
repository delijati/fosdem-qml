import QtQuick 2.9
import Lomiri.Components 1.3


Page {
    id: searchPage
    objectName: "searchPage"

    header: CommonHeader {
        title: i18n.tr('Search')
        flickable: resultList
        thisPage: "searchPage"

        extension: Item {
            width: parent.width
            height: units.gu(6)

            TextField {
                id: searchField
                objectName: "searchField"
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: units.gu(1)
                }
                placeholderText: i18n.tr("Title, speaker or topic")
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: searchDelay.restart()
                Component.onCompleted: forceActiveFocus()
            }
        }
    }

    property var model: ListModel {}
    property string query: ""

    anchors.fill: parent

    function load() {
        var text = searchField.text;
        py.call("backend.search", [text], function(events) {
            searchPage.model.clear();
            for (var i = 0; i < events.length; i++) {
                searchPage.model.append(events[i]);
            }
            searchPage.query = text;
        });
    }

    // wait until typing pauses instead of searching on every key
    Timer {
        id: searchDelay
        interval: 300
        onTriggered: load()
    }

    // Reload when coming back, e.g. after starring a talk on its page.
    onVisibleChanged: {
        if (visible && query !== "") {
            load();
        }
    }

    ListView {
        id: resultList
        anchors.fill: parent
        model: searchPage.model
        delegate: LectureListItem {
            lecture: model

            onClicked: {
                pageStack.push(Qt.resolvedUrl("Lecture.qml"), {"model": searchPage.model.get(index)})
            }
        }
    }

    Loader {
        width: parent.width
        anchors.centerIn: parent
        active: searchPage.query.trim() !== "" && searchPage.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No talks found')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
