import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import io.thp.pyotherside 1.4
import "ui"


MainView {
    objectName: "mainView"
    id: mainView

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "fosdem-qml.delijati"

    width: units.gu(50)
    height: units.gu(75)

    // Adaptive layout properties
    property bool isLandscape: width > height
    property bool isTablet: Math.min(width, height) >= units.gu(60)
    property bool isDesktop: width >= units.gu(100)
    property int columns: {
        if (isDesktop) return 3
        if (isTablet && isLandscape) return 2
        return 1
    }
    
    property real gnalSpacing: units.gu(2)
    property real gnalMargins: units.gu(2)
    property real buttonWidth: units.gu(9)
    property var path: []
    property string thisPage

    property string lightColor: "#ffffff"
    property string accentColor: "#a91991"
    property string hlColor: "#66a91991"

    signal scheduleChanged
    signal notesChanged

    // a property, so tests can replace it instead of starting a browser
    property var openUrl: function(link) { Qt.openUrlExternally(link); }

    // "2025-02-01" -> "Saturday, 1 February 2025" in the phone's language
    function dayLabel(isoDate) {
        var parts = isoDate.split("-");
        var date = new Date(parts[0], parts[1] - 1, parts[2]);
        return date.toLocaleDateString(Qt.locale(), Locale.LongFormat);
    }

    DownloadDialog {
        id: download_dialog

        property var current: null
    }

    // The dialog may have been closed (Cancel) while the download ran; it is
    // then no longer download_dialog.current and must not be touched.
    function download_end(dialog, error) {
        if (!error) {
            scheduleChanged();
        }
        if (dialog !== download_dialog.current) {
            return;
        }
        dialog.busy = false;
        if (error) {
            dialog.progress_visible = false;
            dialog.error = error;
        } else {
            PopupUtils.close(dialog);
        }
    }

    function load_schedule(exists) {
        // this is called when app starts!
        if (!exists) {
            download_dialog.current = PopupUtils.open(download_dialog);
        }
    }

    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            py.call("backend.file_exists", [], load_schedule)
            pageStack.push(Qt.resolvedUrl("ui/Days.qml"))
        }

        onCurrentPageChanged: thisPage = currentPage ? currentPage.objectName : ""
    }

    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('./'));

            importModule('backend', function() {
                console.log("DEBUG: python loaded");
            });

            setHandler('on-progress', function(value) {
                if (download_dialog.current) {
                    if (!download_dialog.current.progress_visible) {
                        download_dialog.current.progress_visible = true;
                    }
                    download_dialog.current.value = value / 100;
                }
            });
        }

        onError: {
            console.error('Python error: ' + traceback);
            showError(traceback);
        }
    }

    function showError(traceback) {
        var dialog = PopupUtils.open(errorDialog);
        dialog.traceback = traceback;
        return dialog;
    }

    Component {
        id: errorDialog

        Dialog {
            id: dialog
            title: i18n.tr("Error")
            text: i18n.tr("Something went wrong: %1").arg(summary)

            property string traceback: ""
            property bool showDetails: false
            // Last line of a python traceback is "SomeError: message".
            property string summary: {
                var lines = traceback.trim().split("\n");
                return lines[lines.length - 1];
            }

            TextArea {
                visible: dialog.showDetails
                readOnly: true
                text: dialog.traceback
                width: parent.width
                height: units.gu(20)
                font.pixelSize: units.gu(1.25)
            }

            Button {
                text: dialog.showDetails ? i18n.tr("Hide details") : i18n.tr("Details")
                onClicked: dialog.showDetails = !dialog.showDetails
            }

            Button {
                id: cancelButton
                text: i18n.tr("Close")
                color: LomiriColors.blue
                onClicked: PopupUtils.close(dialog)
            }
        }
    }
}
