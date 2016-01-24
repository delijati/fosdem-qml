import QtQuick 2.4
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1


Page {
    id: basepage

    Map {
        id: map
    }
    
    About {
        id: about
    }

    head.actions: [
        Action {
            iconName: "import"
            text: i18n.tr("Import")
            onTriggered: {
                // TODO refactor dialog; concentrate code somewhere
                download_dialog.current = PopupUtils.open(download_dialog);
            }
        },
        Action {
            iconName: "stock_image"
            text: i18n.tr("Map")
            onTriggered: {
                pageStack.push(map);
            }
        },
        Action {
            iconName: "info"
            text: i18n.tr("About")
            onTriggered: {
                pageStack.push(about);
            }
        }
    ]
}
