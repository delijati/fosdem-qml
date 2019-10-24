import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

BaseHeader {

    trailingActionBar {
        numberOfSlots: 4

        actions: [
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
                    // TODO refactor dialog; concentrate code somewhere
                    download_dialog.current = PopupUtils.open(download_dialog);
                }
            }
        ]
    }
}
