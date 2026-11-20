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
        property string error: ""
        property bool busy: false

        Component.onDestruction: {
            if (download_dialog.current === dialog) {
                download_dialog.current = null;
            }
        }

        TextField {
            id: url
            objectName: "downloadUrl"
            text: {
                var year = new Date().getFullYear();
                return "https://fosdem.org/" + year + "/schedule/xml"
            }
            width: parent.width
            onAccepted: downloadButton.clicked();
        }

        LabelBase {
            visible: dialog.error !== ""
            text: i18n.tr("Download failed: %1").arg(dialog.error)
            color: theme.palette.normal.negative
        }

        ProgressBar {
            id: progress
            width: parent.width
            value: dialog.value
            visible: dialog.progress_visible
        }

        Button {
            id: downloadButton
            objectName: "downloadButton"
            text: i18n.tr("Download")
            color: LomiriColors.blue
            visible: !dialog.progress_visible
            enabled: !dialog.busy

            onClicked: {
                if (dialog.busy) {
                    return;
                }
                dialog.busy = true;
                url.focus = false;
                Qt.inputMethod.hide();
                dialog.error = "";
                dialog.value = 0;
                // the dialog's scope is gone once it is closed, so keep the
                // objects the callback needs in local variables
                var main = mainView;
                var self = dialog;
                py.call("backend.download_file", [url.text], function(error) {
                    main.download_end(self, error);
                });
            }
        }

        Button {
            objectName: "cancelButton"
            text: i18n.tr("Cancel")
            onClicked: {
                PopupUtils.close(download_dialog.current);
            }
        }
    }
}
