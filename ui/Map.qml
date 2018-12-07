import QtQuick 2.4
import Ubuntu.Components 1.3


Page {
    id: map

    header: MapHeader {
        title: i18n.tr('Map')
    }

    Image {
        anchors.fill: parent
        source: "../images/campus.png"
        fillMode: Image.PreserveAspectFit
        transformOrigin: Item.Center
        rotation: isLandscape ? 270 : 0  
    }
}
