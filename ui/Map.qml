import QtQuick 2.4
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1


Page {
    title: "Map"
    id: map
    visible: false

    Image {
        anchors.fill: parent
        source: "../images/campus.png"
        fillMode: Image.PreserveAspectFit
    }
}
