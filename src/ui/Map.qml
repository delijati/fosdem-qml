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

    Column {
        anchors.fill: parent
        anchors.topMargin: mapHeader.height
        spacing: units.gu(1)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Click map to open in browser")
            fontSize: "small"
        }

        Image {
            width: parent.width
            height: parent.height - parent.spacing - units.gu(3)
            source: "../images/campus.png"
            fillMode: Image.PreserveAspectFit
            transformOrigin: Item.Center
            rotation: isLandscape ? 270 : 0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Qt.openUrlExternally("https://www.openstreetmap.org/?mlat=50.813236&mlon=4.382333#map=18/50.813236/4.382333")
                }
            }
        }
    }
}
