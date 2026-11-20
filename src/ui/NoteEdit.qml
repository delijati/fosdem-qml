import QtQuick 2.9
import Lomiri.Components 1.3


// Write or edit a note. It is saved when the page is left; a note left
// empty is discarded.
Page {
    id: noteEdit
    objectName: "noteEditPage"

    property int noteId: 0
    // talk a new note is linked to (0: none) and its title for the header
    property int eventId: 0
    property string talkTitle: ""
    property alias text: noteText.text

    property bool deleted: false
    property string savedText: ""
    // outlives the page, so a save callback that arrives after the page was
    // closed can tell
    property var life: ({ alive: true })

    header: BaseHeader {
        title: noteEdit.talkTitle !== "" ? noteEdit.talkTitle : i18n.tr("Note")

        trailingActionBar.actions: [
            Action {
                iconName: "delete"
                text: i18n.tr("Delete")
                visible: noteEdit.noteId !== 0 || noteText.text !== ""
                onTriggered: noteEdit.deleteNote()
            }
        ]
    }

    function save() {
        if (deleted || text === savedText) {
            return;
        }
        savedText = text;
        var main = mainView;
        var life = noteEdit.life;
        var self = noteEdit;
        py.call("backend.save_note", [noteId, text, eventId], function(id) {
            if (life.alive) {
                self.noteId = id;
            }
            main.notesChanged();
        });
    }

    function deleteNote() {
        deleted = true;
        var main = mainView;
        if (noteId !== 0) {
            py.call("backend.delete_note", [noteId], function() {
                main.notesChanged();
            });
        }
        pageStack.pop();
    }

    Component.onCompleted: savedText = text
    Component.onDestruction: life.alive = false

    // leaving the page (back, or another page on top) saves
    onVisibleChanged: {
        if (!visible) {
            save();
        }
    }

    TextArea {
        id: noteText
        anchors {
            fill: parent
            topMargin: noteEdit.header.height + units.gu(1)
            margins: units.gu(1)
        }
        placeholderText: i18n.tr("Write your note")
        Component.onCompleted: {
            // continue writing at the end of an existing note
            cursorPosition = length;
            forceActiveFocus();
        }
    }
}
