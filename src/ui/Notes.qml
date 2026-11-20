import QtQuick 2.9
import Lomiri.Components 1.3


// All notes, newest first, grouped by the day they were written.
Page {
    id: notesPage
    objectName: "notesPage"

    header: CommonHeader {
        title: i18n.tr('Notes')
        flickable: notesList
        thisPage: "notesPage"
    }

    property var model: ListModel {}

    anchors.fill: parent

    function load() {
        py.call("backend.list_notes", [], function(notes) {
            model.clear();
            for (var i = 0; i < notes.length; i++) {
                model.append(notes[i]);
            }
        });
    }

    function newNote() {
        pageStack.push(Qt.resolvedUrl("NoteEdit.qml"));
    }

    function openNote(index) {
        var note = model.get(index);
        pageStack.push(Qt.resolvedUrl("NoteEdit.qml"), {
            "noteId": note.id,
            "text": note.text,
            "talkTitle": note.talk_title
        });
    }

    Component.onCompleted: {
        load();
        mainView.notesChanged.connect(load);
    }

    Component.onDestruction: mainView.notesChanged.disconnect(load)

    ListView {
        id: notesList
        anchors.fill: parent
        model: notesPage.model

        header: Item {
            width: parent.width
            height: units.gu(7)

            Button {
                anchors.centerIn: parent
                text: i18n.tr("New note")
                color: LomiriColors.green
                onClicked: notesPage.newNote()
            }
        }

        section.property: "day"
        section.delegate: SectionHeader {
            text: mainView.dayLabel(section)
        }

        delegate: ListItem {
            divider.visible: false
            highlightColor: hlColor
            height: noteLayout.height

            ListItemLayout {
                id: noteLayout
                title.text: model.text
                title.maximumLineCount: 3
                title.wrapMode: Text.WordWrap
                subtitle.text: model.time + (model.talk_title !== ""
                    ? "  " + model.talk_title + " (" + model.talk_start + ", " + model.talk_room + ")"
                    : "")

                ProgressionSlot {}
            }

            onClicked: notesPage.openNote(index)
        }
    }

    Loader {
        width: parent.width
        anchors.centerIn: parent
        active: notesPage.model.count === 0
        sourceComponent: Label {
            text: i18n.tr('No notes yet')
            horizontalAlignment: Text.AlignHCenter
            textSize: Label.Medium
        }
    }
}
