import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

BaseHeader {
    property string thisPage: ""

    // Adjust header height for landscape mode
    height: (mainView.isLandscape && !mainView.isTablet ? units.gu(5) : units.gu(7))
            + (extension ? extension.height : 0)

    trailingActionBar {
        numberOfSlots: mainView.isLandscape || mainView.isTablet ? 6 : 4

        actions: [
            Action {
                iconName: "home"
                text: i18n.tr("Home")
                visible: thisPage != "daysPage"

                onTriggered: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("Days.qml"));
                }
            },
            Action {
                iconName: "find"
                text: i18n.tr("Search")
                visible: thisPage != "searchPage"

                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("Search.qml"));
                }
            },
            Action {
                iconName: "note"
                text: i18n.tr("Notes")
                visible: thisPage != "notesPage"

                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("Notes.qml"));
                }
            },
            Action {
                iconName: "info"
                text: i18n.tr("About")

                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("About.qml"))
                }
            },
            Action {
                iconName: "location-active"
                text: i18n.tr("Map")

                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("Map.qml"));
                }
            },
            Action {
                iconName: "clock"
                text: i18n.tr("Now")

                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("Now.qml"));
                }
            },
            Action {
                iconName: "favorite-selected"
                text: i18n.tr("Checked")

                onTriggered: {
                      pageStack.push(Qt.resolvedUrl("Checked.qml"));
                }
            },
            Action {
                iconName: "import"
                text: i18n.tr("Import")
                visible: thisPage == "daysPage"

                onTriggered: {
                    download_dialog.current = PopupUtils.open(download_dialog);
                }
            }
        ]
    }
}
