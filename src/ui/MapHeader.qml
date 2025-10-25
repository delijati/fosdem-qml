import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

BaseHeader {
    property string thisPage: "mapPage"

    trailingActionBar {
        actions: [
            Action {
                iconSource: "../images/unav-symbolic.svg"
                text: i18n.tr("Coordenates")

                onTriggered: {
                    //Qt.openUrlExternally("https://map.unav.me/?50.8124,4.3807")
                    Qt.openUrlExternally("https://www.openstreetmap.org/?mlat=50.813236&mlon=4.382333#map=18/50.813236/4.382333")
                }
            },
            Action {
                iconName: "home"
                text: i18n.tr("Home")
                visible: thisPage != "daysPage"
                onTriggered: {
                    pageStack.clear()
                    pageStack.push(Qt.resolvedUrl("Days.qml"))
                }
            }
        ]
    }
}
