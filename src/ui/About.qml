import QtQuick 2.9
import Lomiri.Components 1.3
import QtQuick.Layouts 1.1

Page {
    id: about
    anchors.fill: parent

    header: CommonHeader {
        title: i18n.tr('About')
        flickable: flickable
        thisPage: "aboutPage"
    }

    Flickable {
        id: flickable
        anchors  {
            fill: parent
            margins: gnalMargins
        }

        contentHeight: contentItem.childrenRect.height + gnalMargins

        Column {
            id: col

            width: parent.width

            anchors {
                top: parent.top
                leftMargin: gnalMargins
                rightMargin: gnalMargins
                topMargin: gnalMargins
            }

            spacing: gnalSpacing

            Label {
                width: parent.width
                horizontalAlignment: Text.Center
                text: i18n.tr("Fosdem QML")
                fontSize: "x-large"
            }

            RowLayout {
                width: parent.width

                LomiriShape {
                    aspect: LomiriShape.Flat
                    Layout.alignment: Qt.AlignHCenter
                    Layout.minimumHeight: units.gu(17)
                    Layout.minimumWidth: units.gu(17)

                    image: Image {
                        source: "../images/icon.svg"
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
                text: i18n.tr("Redesign: Joan CiberSheep")
                horizontalAlignment: Text.Center
                width: parent.width
            }

            Label {
                //TRANSLATORS: Here %1 is FOSDEM name (Should read as 'Official FOSDEM website')
                text: i18n.tr("Official %1 website").arg("<a href='https://fosdem.org/'>FOSDEM</a>")
                onLinkActivated: Qt.openUrlExternally(link)
                horizontalAlignment: Text.Center
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: i18n.tr("Source code available on <a href='https://github.com/delijati/fosdem-qml'>GitHub</a>")
                onLinkActivated: Qt.openUrlExternally(link)
                horizontalAlignment: Text.Center
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: i18n.tr("Powered by <b>PyOtherSide</b>")
                horizontalAlignment: Text.Center
                width: parent.width
            }
        }
    }
}
