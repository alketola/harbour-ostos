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
    property bool remorsing: false
    MenuItem {
        Row {
            width: parent.width

            IconButton {
                width: parent.width/lineitems
                icon.source: "image://theme/icon-m-dismiss"
                onClicked: {
                    console.log("Item HIDE,index:"+modelindex +" ROWID:"+ shoppingListModel.get(modelindex).rowid)
                    // remorse and hide
                    remorsing = true;
                    cxMenu.hide();
                    remorseHide.execute(cxMenu.parent,qsTr("Hiding Item"), function () {
                        DBA.updateItemState(shoppingListModel.get(modelindex).rowid,"HIDE");
                        shoppingListModel.remove(modelindex);
                        cxMenu.destroy();
                    }, 2000);
                }
            }
            RemorseItem {id: remorseHide}

            IconButton {
                width: parent.width/lineitems
                icon.source: "image://theme/icon-s-task"
                onClicked: {
                    // console.log("Item FIND, ROWID:"+ shoppingListModel.get(modelindex).rowid)
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
                icon.source: "../images/icon-m-plus.png"
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
                icon.source: "../images/icon-m-minus.png"
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
                    // console.log("Item delete, ROWID:"+ shoppingListModel.get(modelindex).rowid)
                    // remorse and delete
                    remorsing = true;
                    cxMenu.hide();
                    remorseDelete.execute(cxMenu.parent,qsTr("Deleting Item"), function () {
                        DBA.deleteItemFromShoppingList(shoppingListModel.get(modelindex).rowid);
                        shoppingListModel.remove(modelindex);
                        cxMenu.destroy();
                    }, 3000);
                }
            }

            RemorseItem {id: remorseDelete}


        }
    }

    onClosed: {
        console.log("LineButtonsMenu onClosed");

        // This remorsing check is because remores item replaces
        // context menu closing it, and thus coming here...
        // Cannot destroy ContextMenu while remorsing.
        // Can destroy in the end of remorse.
        if (!remorsing) {
            remorsing=false;
            console.log("-->destroying cxMenu");
            cxMenu.destroy();
        } else {
            // This should announce the menu for garbage collection
            // According to top, garbage collection is not doing its job well
            cxMenu.deleteLater;
        }

    }
}
