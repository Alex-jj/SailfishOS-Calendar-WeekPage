import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.calendar 1.0
import Calendar.syncHelper 1.0

Item {
    id: root
    height: eld.height + ((_contextMenu && _contextMenu.parent == root) ? _contextMenu.height : 0)
    width: ListView.view.width

    property alias activeDay: eld.activeDay
    property QtObject _contextMenu

    Component {
        id: contextMenuComponent
        ContextMenu {
            id: contextMenu
            MenuItem {
                // "Edit"
                text: qsTrId("calendar-day-edit")
                onClicked: {
                    pageStack.push("EventEditPage.qml", { event: model.event })
                }
            }
            MenuItem {
                //% "Delete"
                text: qsTrId("calendar-day-delete")
                onClicked: {
                    if (model.event.recur != CalendarEvent.RecurOnce) {
                        pageStack.push("EventDeletePage.qml",
                                       { uniqueId: model.event.uniqueId, startTime: model.occurrence.startTime })
                    } else {
                        contextMenu.parent.deleteActivated()
                    }
                }
            }
        }
    }

    Connections {
        id: dayConnection
        ignoreUnknownSignals: true
        onStartDateChanged: {
            eld.remorse().cancel()
            target = null
            model.occurrence.remove()
        }
    }

    function deleteActivated() {
        // Assuming id/property. Need to trigger deletion before day change refreshes content.
        // RemorseItem itself would try to execute its command, but model target might be already deleted.
        dayConnection.target = view.model
        eld.remorse().execute(root, qsTrId("calendar-event-deleting"),
                              function() {
                                  model.occurrence.remove();
                                  // TODO: check calendarId and only sync if syncable
                                  app.syncTrigger.triggerSyncDelayed(200,
                                                                     SyncHelper.UpdateSync,
                                                                     SyncHelper.SyncIfAlwaysUpToDateSet,
                                                                     [0])
                              })
    }
    EventListDelegateSmall {
        id: eld
        width: parent.width
        menuOpen: _contextMenu && _contextMenu.active
        onPressAndHold: {
            if (event.readonly)
                return
            if (!_contextMenu) _contextMenu = contextMenuComponent.createObject(root)
            _contextMenu.show(root)
        }
    }
}

