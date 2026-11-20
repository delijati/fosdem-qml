import QtQuick 2.9
import Lomiri.Components 1.3

// One talk in a list. Set "lecture" to the delegate's model.
ListItem {
    property var lecture
    // extra line, e.g. "ends in 5 min"; an overlap warning takes precedence
    property string hint: ""

    divider.visible: false
    highlightColor: hlColor

    height: layout.height

    ListItemLayout {
        id: layout
        title.text: lecture.title
        subtitle.text: (lecture.removed ? i18n.tr("Removed from schedule") + ": " : "")
            + "[" + lecture.day + "] " + lecture.start + " - " + lecture.end
            + " " + i18n.tr('in') + " " + lecture.room
        subtitle.color: lecture.removed ? theme.palette.normal.negative
                                        : theme.palette.normal.backgroundSecondaryText
        // only favorites (agenda) carry clash_titles
        summary.text: lecture.clash_titles ? i18n.tr("Overlaps with: %1").arg(lecture.clash_titles) : hint
        summary.color: lecture.clash_titles ? theme.palette.normal.negative : accentTextColor
        summary.visible: summary.text !== ""

        Favorite {
            width: units.gu(2)
            height: width
            SlotsLayout.position: SlotsLayout.Leading
            checked: lecture.lecture_checked
        }

        ProgressionSlot {}
    }
}
