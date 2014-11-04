import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property date activeDay
    property RemorseItem _remorse
    property bool menuOpen

    function remorse() {
        if (_remorse == null)
            _remorse = remorseComponent.createObject(root)
        return _remorse
    }

    highlighted: down || menuOpen
    highlightedColor: menuOpen ? "transparent" : Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    height: Theme.fontSizeMedium
    width: ListView.view.width

    Component {
        id: remorseComponent
        RemorseItem {}
    }

    Row {
        height: Theme.fontSizeSmall
        anchors.verticalCenter: parent.verticalCenter
        x: Theme.paddingSmall
        spacing: Theme.paddingSmall

        Rectangle {
            width: Theme.paddingSmall
            radius: Math.round(width/3)
            color: model.event.color
            height: parent.height
        }

        Row {
            height: parent.height
            EventTimeLabel {
                allDay: model.event.allDay
                startTime: model.occurrence.startTime
                endTime: model.occurrence.endTime
                activeDay: root.activeDay
                height: parent.height
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            }
            Label {
                text: ": "
                height: parent.height
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor

            }
            Label {
                height: parent.height
                width: root.width - 3*Theme.paddingMedium - Theme.paddingSmall
                text: model.event.displayLabel
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }
    }

    onClicked: pageStack.push("EventViewPage.qml", { uniqueId: model.event.uniqueId,
                                                     startTime: model.occurrence.startTime,
                                                     remorse: function(title, action) { remorse().execute(root, title, action) } });
}
