import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Item {
    property bool checked
    width: units.gu(2)
    height: units.gu(2)

    Icon {
        anchors{
            verticalCenter: parent.verticalCenter
            fill: parent
        }       

        name: checked ? "favorite-selected" :"favorite-unselected"
        color: accentColor
    }
}
