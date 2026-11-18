import QtQuick 2.9
import Lomiri.Components 1.3


Page {
    id: schedule

    header: CommonHeader {
        title: i18n.tr('Schedule')
        flickable: viewLoader.item
    }

    property var model: ListModel {}

    // Conditional layout: use GridView for landscape/multi-column, ListView for portrait
    Loader {
        id: viewLoader
        anchors.fill: parent
        sourceComponent: mainView.isLandscape || mainView.columns > 1 ? gridViewComponent : listViewComponent
    }

    Component {
        id: listViewComponent
        
        ListView {
            id: scheduleListView
            model: schedule.model
            delegate: scheduleDelegate
        }
    }

    Component {
        id: gridViewComponent
        
        GridView {
            id: scheduleGridView
            cellWidth: width / mainView.columns
            cellHeight: units.gu(12)
            model: schedule.model
            delegate: scheduleDelegate
        }
    }

    Component {
        id: scheduleDelegate

        LectureListItem {
            lecture: model

            onClicked: {
                pageStack.push(Qt.resolvedUrl("Lecture.qml"), {"model": schedule.model.get(index)})
            }
        }
    }

    Loader {
        id: emptyStateLoader
        width: parent.width
        anchors.centerIn: parent
        active: schedule.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No schedule info')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
