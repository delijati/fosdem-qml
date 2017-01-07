import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import io.thp.pyotherside 1.4
import "ui"


MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView" 

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "fosdemqml.delijati"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    //useDeprecatedToolbar: false

    width: units.gu(50)
    height: units.gu(75)

    property real spacing: units.gu(1)
    property real margins: units.gu(2)
    property real buttonWidth: units.gu(9)
    property var path: []


    Schedule {
        id: schedule
    }

    Days {
        id: days
    }

    Lecture {
        id: lecture
    }

    Track {
        id: track
    }

    DownloadDialog {
        id: download_dialog

        property var current: null
    }

    function download_end(data) {
        // XXX should we rather send signals?        
        PopupUtils.close(download_dialog.current)
        py.call("backend.get_schedule_file_path",  [true], function(path) {
            days.xmlsource = path
            pageStack.push(days)
        })
    }

    function load_schedule(exists) {
        // this is called when app starts!
        // XXX should we rather send signals?
        if (!exists) {
            download_dialog.current = PopupUtils.open(download_dialog);
        }
        else {
            py.call("backend.get_schedule_file_path",  [], function(path) {
                days.xmlsource = path
                pageStack.push(days)
            })
        }
    }

    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            py.call("backend.file_exists", [], load_schedule)
        }
    }

    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.'));
            addImportPath(Qt.resolvedUrl('./lib/py'));

            importModule('backend', function(){
                console.log("python loaded");
            });

            setHandler('on-progress', function(value) {
                if (download_dialog.current !== null) {
                    if (!download_dialog.current.progress_visible) {
                        console.log(download_dialog.current.progress_visible);
                        download_dialog.current.progress_visible = true;
                    }
                    download_dialog.current.value = ((value * 2) / 100);
                    console.log(download_dialog.current.value);
                }
            });

        }
        onError: {
            console.log('Error: ' + traceback);
            var dialog = PopupUtils.open(errorDialog);
            dialog.traceback = traceback;
        }
    }

    Component {
         id: errorDialog
         Dialog {
             id: dialog
             title: i18n.tr("Error")

             property string traceback: ""

             text: i18n.tr("An error has occured: %1").arg(traceback)

             property string id_

             Button {
                 id: cancelButton
                 text: i18n.tr("Close")
                 onClicked: PopupUtils.close(dialog)
             }
         }
    }
}
