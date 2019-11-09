import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

BaseHeader {

    trailingActionBar {
        actions: Action {
            iconSource: "../images/unav-symbolic.svg"
            text: i18n.tr("Coordenates")

            onTriggered: {
                Qt.openUrlExternally("https://map.unav.me/?50.8124,4.3807")
            }
        }
    }
}
