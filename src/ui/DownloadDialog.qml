import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Component {
    Dialog {
        id: dialog
        title: i18n.tr("Download")
        text: i18n.tr("Url of Fosdem Pentabarf XML:")

        property real value: 0.0
        property bool progress_visible: false

        LabelBase {
            text: i18n.tr("All 'Checked' entries will be deleted!")
        }

        TextField {
            id: url
            text: {
                var year = new Date().getFullYear();
                return "https://fosdem.org/" + year + "/schedule/xml"
            }
            width: parent.width
            onAccepted: downloadButton.clicked();
        }

        ProgressBar {
            id: progress
            width: parent.width
            value: dialog.value
            visible: dialog.progress_visible
        }

        Button {
            id: downloadButton
            text: i18n.tr("Download")
            color: LomiriColors.blue
            visible: !dialog.progress_visible

            onClicked: {
                //console.log(url.text);
                url.focus = false;
                Qt.inputMethod.hide();
                py.call("backend.download_file", [url.text], download_end);
            }
        }

        Button {
            //anchors.right: parent.right
            //visible: true

            text: i18n.tr("Cancel")
            onClicked: {
                PopupUtils.close(download_dialog.current);
                //console.log("Cancel");
            }
        }
    }
}
