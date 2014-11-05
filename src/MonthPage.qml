import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.calendar 1.0
import org.nemomobile.time 1.0
import "Util.js" as Util

Page {
    id: root

    function addEvent() {
        var now = new Date
        var d = datePicker.date

        if (now.getHours() < 23 && now.getMinutes() > 0) {
            d.setHours(now.getHours() + 1)
        }

        d.setMinutes(0)
        d.setSeconds(0)

        pageStack.push("EventEditPage.qml", { defaultDate: d })
    }

    states: State {
        name: "hidePageStackIndicator"
        when: root.status != PageStatus.Inactive
        PropertyChanges { target: app.indicatorParentItem; opacity: 0. }
    }
    transitions: Transition {
        NumberAnimation { properties: "opacity" }
    }

    WallClock {
        id: wallClock
        updateFrequency: WallClock.Day
    }

    SilicaListView {
        id: view
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                //% "Settings"
                text: qsTrId("calendar-me-settings")
                onClicked: pageStack.push("SettingsPage.qml")
            }
            MenuItem {
                //% "Go to today"
                text: qsTrId("calendar-me-go_to_today")
                onClicked: datePicker.date = new Date()
            }
            /* Disabled for now
            MenuItem {
                //% "Show agenda"
                text: qsTrId("calendar-me-show_agenda")
                onClicked: pageStack.push("AgendaPage.qml", {date: datePicker.date})
            }
            */
            MenuItem {
                //% "Show WeekPage"
                text: qsTrId("calendar-me-show_week")
                onClicked: pageStack.push("WeekPage.qml", {date: datePicker.date})
            }
            MenuItem {
                //% "New event"
                text: qsTrId("calendar-me-new_event")
                onClicked: root.addEvent()
            }
            Row {
                height: Theme.itemSizeExtraSmall - Theme.paddingLarge
                width: parent.width
                Repeater {
                    model: 7
                    delegate: Label {
                        y: 3
                        opacity: 0.6
                        // 3 Jan 2000 was a Monday
                        text: Qt.formatDateTime(new Date(2000, 0, 3 + index, 12), "ddd")
                        color: Theme.highlightColor
                        width: parent.width / 7
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        header: Item {
            width: view.width
            height: datePicker.height + menuLocation.height + dateHeader.height
        }

        model: AgendaModel { id: agendaModel }

        delegate: DeletableListDelegate {
            // Update activeDay after the contents of agendaModel changes (after the initial update)
            // to prevent delegates from recalculating time labels before agendaModel responds to
            // changes in datePicker.date

            Component.onCompleted: activeDay = agendaModel.startDate

            Connections {
                target: agendaModel
                onUpdated: activeDay = agendaModel.startDate
            }
        }

        Binding {
            target: agendaModel
            property: "startDate"
            value: datePicker.date
            when: !datePicker.viewMoving
        }

        VerticalScrollDecorator {}
        Column {
            width: view.width
            parent: view.contentItem
            y: view.headerItem.y

            Item {
                width: parent.width; height: datePicker.height
                Image {
                    anchors.fill: parent
                    source: "image://theme/graphic-gradient-edge"
                    rotation: 180
                }
                DatePicker {
                    id: datePicker

                    delegate: Component {
                        MouseArea {
                            property date modelDate: new Date(model.year, model.month-1, model.day)

                            width: datePicker.width / 7
                            height: width

                            AgendaModel { id: events }

                            Binding {
                                target: events
                                property: "startDate"
                                value: modelDate
                                when: !datePicker.viewMoving
                            }

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: model.day
                                font.pixelSize: Theme.fontSizeMedium
                                font.bold: model.day === wallClock.time.getDate()
                                            && model.month === wallClock.time.getMonth()+1
                                            && model.year === wallClock.time.getFullYear()
                                color: {
                                    if (model.day === datePicker.day &&
                                        model.month === datePicker.month &&
                                        model.year === datePicker.year) {
                                        return Theme.highlightColor
                                    } else if (label.font.bold) {
                                        return Theme.highlightColor
                                    } else if (model.month === model.primaryMonth) {
                                        return Theme.primaryColor
                                    }
                                    return Theme.secondaryColor
                                }
                            }

                            Rectangle {
                                anchors.top: label.baseline
                                anchors.topMargin: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width / 5
                                radius: 2
                                height: 4
                                visible: events.count > 0
                                color: label.color
                            }

                            // TODO: How are we meant to switch to day view?
                            onClicked: datePicker.date = modelDate
                            onPressAndHold: contextMenu.show(menuLocation)
                        }
                    }
                    ChangeMonthHint {}
                }
            }

            Item {
                id: menuLocation
                width: parent.width
                height: Math.max(contextMenu.height, 1)
                ContextMenu {
                    id: contextMenu
                    MenuItem {
                        //% "Change year"
                        text: qsTrId("calendar-me-change_year")
                        onClicked: {
                            var year = Math.max(1980, Math.min(2300, datePicker.date.getFullYear()))
                            var page = pageStack.push("CalendarYearPage.qml",
                                                      { startYear: 1980, endYear: 2300, defaultYear: year })
                            page.yearSelected.connect(function(year) {
                                var d = datePicker.date
                                d.setFullYear(year)
                                datePicker.date = d
                            })
                        }
                    }
                }
            }

            BackgroundItem {
                id: dateHeader
                anchors.right: parent.right
                width: dateLabel.width + Theme.paddingSmall + moreImage.width + Theme.paddingMedium + Theme.paddingLarge
                height: Math.min(dateLabel.height + Theme.paddingSmall, Theme.itemSizeExtraSmall)
                onClicked: {
                    var p = pageStack.push("DayPage.qml", { "width": root.width, "date": datePicker.date })
                    if (p !== null) {
                        p.statusChanged.connect(function() {
                            if (p.status === PageStatus.Deactivating)
                                datePicker.date = p.date
                        })
                    }
                }

                Label {
                    id: dateLabel
                    anchors.right: moreImage.left
                    anchors.rightMargin: Theme.paddingMedium
                    text: Util.formatDateWeekday(datePicker.date)
                    color: dateHeader.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge
                }

                Image {
                    id: moreImage
                    anchors {
                        right: parent.right
                        rightMargin: Theme.paddingSmall
                        verticalCenter: parent.verticalCenter
                    }
                    source: "image://theme/icon-m-right?" + (dateHeader.highlighted ? Theme.highlightColor
                                                                                    : Theme.primaryColor)
                }
            }

            Item {
                width: parent.width
                height: placeholderText.height + 2*Theme.paddingLarge
                visible: view.count === 0

                Label {
                    id: placeholderText
                    x: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 2*Theme.paddingLarge
                    //% "Your schedule is free"
                    text: qsTrId("calendar-me-schedule_is_free")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeHuge
                    color: Theme.secondaryHighlightColor
                }
            }
        }
    }
}

