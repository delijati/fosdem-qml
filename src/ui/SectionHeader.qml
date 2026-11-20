import QtQuick 2.9
import Lomiri.Components 1.3

// Heading above a group of list items (ListView section.delegate).
Item {
    property alias text: label.text

    width: parent ? parent.width : 0
    height: units.gu(5)

    Label {
        id: label
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(1)
        }
        font.bold: true
        color: accentTextColor
    }
}
