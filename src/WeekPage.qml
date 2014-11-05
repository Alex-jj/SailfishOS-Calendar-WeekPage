import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.calendar 1.0
import "Util.js" as Util

Page {
    id: root
    property date date
    function addEvent() {
        var now = new Date
        var d = root.date

        if (now.getHours() < 23 && now.getMinutes() > 0) {
            d.setHours(now.getHours() + 1)
        }

        d.setMinutes(0)
        d.setSeconds(0)

        pageStack.push("EventEditPage.qml", { defaultDate: d })
    }

    SilicaGridView {
        id: weekGrid
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                //% "Go to today"
                text: qsTrId("calendar-me-go_to_today")
                onClicked: pageStack.push("WeekPage.qml", {date: new Date()})
            }

            MenuItem {
                //% "New event"
                text: qsTrId("calendar-me-new_event")
                onClicked: root.addEvent()
//                onClicked: pageStack.push("EventEditPage.qml", { defaultDate: root.date })
            }
        }

        header: Item {
            height: pageHeader.height + Theme.paddingLarge
            width: parent.width

            property int daynr: {
                //3 Jan 2000 was a Monday
                if (Qt.formatDateTime(new Date(2000, 0, 3, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 0
                } else if (Qt.formatDateTime(new Date(2000, 0, 4, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 1
                }else if (Qt.formatDateTime(new Date(2000, 0, 5, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 2
                } else if (Qt.formatDateTime(new Date(2000, 0, 6, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 3
                }else if (Qt.formatDateTime(new Date(2000, 0, 7, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 4
                } else if (Qt.formatDateTime(new Date(2000, 0, 8, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 5
                } else {
                return 6
                }
            }

            PageHeader {
                id: pageHeader
                title: (Qt.formatDate(QtDate.addDays(root.date, 0-daynr), "dd.MMM.yy") + " - " + Qt.formatDate(QtDate.addDays(root.date, 0-daynr+6), "dd.MMM.yy"))
            }
            Text {
                y: Theme.itemSizeSmall
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                opacity: 0.8
                text: ("week "+ Util._weekNumberForDate(root.date))
//                text: (Format.formatDate(QtDate.addDays(root.date, 0-daynr),Formatter.DateLong) + " - " + Format.formatDate(QtDate.addDays(root.date, 0-daynr+7), "dd"))
            }
        }
        cellHeight: parent.height/5
        cellWidth: parent.width/2

        model: ListModel {
            ListElement { day: "Monday" }
            ListElement { day: "Tuesday" }
            ListElement { day: "Wednesday" }
            ListElement { day: "Thursday" }
            ListElement { day: "Friday" }
            ListElement { day: "Saturday" }
            ListElement { day: "Sunday" }

        }
        delegate: Item {
            width: weekGrid.cellWidth
            height: weekGrid.cellHeight

            id: delDay

            signal clicked

//            Rectangle {
//                width: weekGrid.cellWidth+2
//                height: weekGrid.cellHeight+2
//                color: "transparent"
//                border.color: Theme.primaryColor
//                border.width: 2

//            }

            BackgroundItem {
                id: backgroundItem
                anchors.horizontalCenter: label.Center
                width: weekGrid.cellWidth - 2 * Theme.paddingMedium
                height: label.height + Theme.paddingSmall
                onClicked: pageStack.push("DayPage.qml", QtDate.addDays(root.date, 0-daynr+index))
            }

            Label {
                id: label
                text: "  " + day
            }

//            Label {
//                id: label
//                anchors.right: parent.right
//                anchors.rightMargin: Theme.paddingLarge
//                text: day
//                color: backgroundItem.highlighted ? Theme.highlightColor : Theme.primaryColor
//                font.pixelSize: Theme.fontSizeLarge
//            }

            property int daynr: {
                //3 Jan 2000 was a Monday
                if (Qt.formatDateTime(new Date(2000, 0, 3, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 0
                } else if (Qt.formatDateTime(new Date(2000, 0, 4, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 1
                }else if (Qt.formatDateTime(new Date(2000, 0, 5, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 2
                } else if (Qt.formatDateTime(new Date(2000, 0, 6, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 3
                }else if (Qt.formatDateTime(new Date(2000, 0, 7, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 4
                } else if (Qt.formatDateTime(new Date(2000, 0, 8, 12), "ddd") === Qt.formatDateTime(root.date, "ddd")) {
                    return 5
                } else {
                return 6
                }
            }

            ListView {
                anchors.top: backgroundItem.bottom
                height: weekGrid.cellHeight-backgroundItem.height
                width: weekGrid.cellWidth
                clip: true
                model: AgendaModel {
                    startDate: QtDate.addDays(root.date, index-daynr)
                    endDate: QtDate.addDays(root.date, index-daynr)
                }

                delegate: DeletableListDelegateSmall {}
            }

        }

        VerticalScrollDecorator {}
    }
}


