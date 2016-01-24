import QtQuick 2.4
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.3


Component {
    Dialog {
        id: dialog
        title: i18n.tr("Download")
        text: i18n.tr("Type url of Fosdem Pentabarf XML:")

        property real value: 0.0
        property bool progress_visible: false

        TextField {
            id: url
            text: "https://fosdem.org/2016/schedule/xml"
            width: parent.width
        }

        Button {
            text: i18n.tr("Download")
            onClicked: {
                console.log(url.text);
                py.call("backend.download_file", [url.text], download_end);
            }
        }

        ProgressBar {
            id: progress
            width: parent.width
            value: dialog.value
            visible: dialog.progress_visible
        }
    }
}
