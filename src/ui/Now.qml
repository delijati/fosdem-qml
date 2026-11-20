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
                    color: lightColor
                }

                Switch {
                    id: markedSwitch
                    checked: nowPage.showOnlyMarked
                    onCheckedChanged: {
                        nowPage.showOnlyMarked = checked
                        nowPage.load()
                    }
                }
            }
        }
    }

    property var model: ListModel {}
    property bool showOnlyMarked: false

    // Refresh only while the page is shown and the app is not suspended or
    // hidden (Ubuntu Touch also stops apps in the background); a covered
    // page costs nothing.
    readonly property bool refreshRunning: visible
        && Qt.application.state !== Qt.ApplicationSuspended
        && Qt.application.state !== Qt.ApplicationHidden

    Component.onCompleted: load()

    function load() {
        py.call("backend.get_now_and_next", [showOnlyMarked], function(lectures) {
            model.clear();
            for (var i = 0; i < lectures.length; i++) {
                model.append(lectures[i]);
            }
        });
    }

    function timeHint(lecture) {
        if (lecture.group === "now") {
            return lecture.minutes <= 0 ? i18n.tr("ends now")
                                        : i18n.tr("ends in %1 min").arg(lecture.minutes);
        }
        return i18n.tr("starts in %1 min").arg(lecture.minutes);
    }

    function msToNextMinute() {
        return 60000 - Date.now() % 60000 + 500;
    }

    // The countdowns change at full minutes, so wake up once per minute,
    // aligned to it; returning to the page reloads at once.
    Timer {
        id: refreshTimer
        running: nowPage.refreshRunning
        repeat: true
        interval: nowPage.msToNextMinute()
        onRunningChanged: {
            if (running) {
                interval = nowPage.msToNextMinute();
                nowPage.load();
            }
        }
        onTriggered: {
            interval = nowPage.msToNextMinute();
            nowPage.load();
        }
    }

    ListView {
        id: nowListView
        anchors.fill: parent
        model: nowPage.model
        delegate: nowDelegate

        section.property: "group"
        section.delegate: SectionHeader {
            text: section === "now" ? i18n.tr("Now") : i18n.tr("Next up")
        }
    }

    Component {
        id: nowDelegate

        LectureListItem {
            lecture: model
            hint: nowPage.timeHint(model)

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
            text: i18n.tr('No talks now or in the next hour')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
