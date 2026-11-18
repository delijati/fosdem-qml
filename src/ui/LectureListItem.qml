import QtQuick 2.9
import Lomiri.Components 1.3

// One talk in a list. Set "lecture" to the delegate's model.
ListItem {
    property var lecture

    divider.visible: false
    highlightColor: hlColor

    ListItemLayout {
        title.text: lecture.title
        subtitle.text: (lecture.removed ? i18n.tr("Removed from schedule") + ": " : "")
            + "[" + lecture.day + "] " + lecture.start + " - " + lecture.end
            + " " + i18n.tr('in') + " " + lecture.room
        subtitle.color: lecture.removed ? theme.palette.normal.negative
                                        : theme.palette.normal.backgroundSecondaryText

        Favorite {
            width: units.gu(2)
            height: width
            SlotsLayout.position: SlotsLayout.Leading
            checked: lecture.lecture_checked
        }

        ProgressionSlot {}
    }
}
