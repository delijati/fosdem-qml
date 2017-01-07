import QtQuick 2.4
import Ubuntu.Components 1.3 // XXX 1.1 has back buttons oO
import QtQuick.Layouts 1.1


Page {
   title: i18n.tr("About")
   id: about
   visible: false

   Flickable {
      id: flickable
      anchors  {
          fill: parent
          margins: units.gu(2)
      }
      contentHeight: contentItem.childrenRect.height

      Column {
         id: col
         anchors.top: parent.top
         anchors.left: parent.left
         anchors.right: parent.right
         anchors.margins: units.gu(2)
         spacing: units.gu(1)

         Label {
            width: parent.width
            horizontalAlignment: Text.Center
            text: i18n.tr("Fosdem QML")
            fontSize: "x-large"
         }

         RowLayout {
            width: parent.width
            UbuntuShape {
               Layout.alignment: Qt.AlignHCenter
               width: units.dp(64)
               height: units.dp(64)
               image: Image {
                  source: "../images/fosdem-logo-big.png"
               }
            }
         }

         Label {
            width: parent.width
            horizontalAlignment: Text.Center
            visible: false
            text: i18n.tr("Version %1")
            Component.onCompleted: {
               py.importModule("backend", function() {
                   text = text.arg(py.evaluate("backend.__version__"));
                   visible = true;
               })
            }
         }

         Item { height: units.gu(2); width: parent.width } // Spacer

         Label {
            text: i18n.tr("Author: Josip Delic")
            horizontalAlignment: Text.Center
            width: parent.width
         }

         Label {
            text: i18n.tr("Source code available on <a href='https://github.com/delijati/fosdem-qml'>GitHub</a>")
            onLinkActivated: Qt.openUrlExternally(link)
            horizontalAlignment: Text.Center
            width: parent.width
         }           

         Label {
            text: i18n.tr("Powered by <b>PyOtherSide</b>")
            horizontalAlignment: Text.Center
            width: parent.width
         }

      }

   }

}
