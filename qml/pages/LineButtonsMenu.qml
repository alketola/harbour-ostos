import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * ContextMenu with buttons in the shopping list app
 */

ContextMenu {
    id: cxMenu
    property int modelindex; // listView.currentIndex
    property int lineitems: 6
    MenuItem {
        Row {
            width: parent.width

            IconButton {
                width: parent.width/lineitems
                icon.source: "image://theme/icon-m-dismiss"
                onClicked: {
                    console.log("Item HIDE, ROWID:"+ shoppingListModel.get(modelindex).rowid)
                    // remorse and hide
                    cxMenu.hide();
                    remorseHide.execute(cxMenu.parent,qsTr("Hiding Item"), function () {
                        DBA.updateItemState(shoppingListModel.get(modelindex).rowid,"HIDE")
                        shoppingListModel.remove(modelindex)
                    }, 2000);
                }
            }
            RemorseItem {id: remorseHide}

            IconButton {
                width: parent.width/lineitems
                icon.source: "image://theme/icon-s-task"
                onClicked: {
                    console.log("Item FIND, ROWID:"+ shoppingListModel.get(modelindex).rowid)
                    // remorse and hide
                    cxMenu.hide();
                    stateIndicator.setState("FIND")
                    DBA.updateItemState(shoppingListModel.get(modelindex).rowid,"FIND")
                    shoppingListModel.setProperty(modelindex,"istat","FIND")
                }
            }

            IconButton {
                width: parent.width/lineitems
                icon.source: "image://theme/icon-m-keyboard"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl('./ItemEditPage.qml'))
                }
            }

            IconButton {
                width: parent.width/lineitems
                icon.source: "image://theme/icon-l-up"
                onClicked: {
                    var q
                    q = parseInt(shoppingListModel.get(firstPageView.currentIndex).iqty)
                    q=q+1
                    var s= q.toString()
                    shoppingListModel.setProperty(firstPageView.currentIndex,"iqty",s)
                    DBA.updateItemQty(shoppingListModel.get(modelindex).rowid, s);
                }
            }

            IconButton { // Change to hide function
                width: parent.width/lineitems
                icon.source: "image://theme/icon-l-down"
                onClicked: {
                    var q
                    q = parseInt( shoppingListModel.get(firstPageView.currentIndex).iqty )
                    q=q-1
                    var s= q.toString()
                    shoppingListModel.setProperty(firstPageView.currentIndex,"iqty",s)
                    DBA.updateItemQty(shoppingListModel.get(modelindex).rowid, s);
                }
            }

            IconButton {
                width: parent.width/lineitems
                icon.source: "image://theme/icon-m-delete"
                onClicked: {
                    console.log("Item delete, ROWID:"+ shoppingListModel.get(modelindex).rowid)
                    // remorse and delete
                    cxMenu.hide();
                    remorseDelete.execute(cxMenu.parent,qsTr("Deleting Item"), function () {
                        DBA.deleteItemFromShoppingList(shoppingListModel.get(modelindex).rowid)
                        shoppingListModel.remove(modelindex)
                    }, 3000);
                }
            }

            RemorseItem {id: remorseDelete}


        }
    }

}
