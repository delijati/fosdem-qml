import QtQuick 2.9
import Lomiri.Components 1.3

Page {
    id: map
    anchors.fill: parent

    header: CommonHeader {
        id: mapHeader
        title: i18n.tr('Map')
        thisPage: "mapPage"
    }

    Image {
        anchors.fill: parent
        anchors.topMargin: mapHeader.height
        source: "../images/campus.png"
        fillMode: Image.PreserveAspectFit
        transformOrigin: Item.Center
        rotation: isLandscape ? 270 : 0
    }
}
