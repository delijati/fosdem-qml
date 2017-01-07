import QtQuick 2.4
import Ubuntu.Components 1.3


Page {
    title: i18n.tr("Map")
    id: map
    visible: false

    Image {
        anchors.fill: parent
        source: "../images/campus.png"
        fillMode: Image.PreserveAspectFit
    }
}
