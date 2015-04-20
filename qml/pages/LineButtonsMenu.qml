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

    MenuItem {
        Row {
            width: parent.width

            IconButton {
                width: parent.width/4
                icon.source: "image://theme/icon-l-clear"
                onClicked: {
                    console.log("Item delete, ROWID:"+ shoppingListModel.get(modelindex).rowid)
                    // remorse and delete
                    cxMenu.hide();
                    remorseIt.execute(cxMenu.parent,qsTr("Deleting Item"), function () {
                        DBA.deleteItemFromShoppingList(shoppingListModel.get(modelindex).rowid)
                        shoppingListModel.remove(modelindex)
                    }, 2000);
                }
            }

            RemorseItem {id: remorseIt}

            IconButton {
                width: parent.width/4
                icon.source: "image://theme/icon-m-keyboard"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl('./ItemEditPage.qml'))
                }
            }

            IconButton {
                width: parent.width/4
                icon.source: "image://theme/icon-l-up"

                onClicked: {
                    var q
                    q = parseInt(shoppingListModel.get(firstPageView.currentIndex).iqty)
                    shoppingListModel.setProperty(firstPageView.currentIndex,"iqty",(q+1).toString())
                }
            }

            IconButton {
                width: parent.width/4
                icon.source: "image://theme/icon-l-down"
                onClicked: {
                    var q
                    q = parseInt( shoppingListModel.get(firstPageView.currentIndex).iqty)
                    shoppingListModel.setProperty(firstPageView.currentIndex,"iqty",(q-1).toString())
                }
            }
        }
    }

}
