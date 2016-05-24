import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Dialog page for item details input in the shopping list app
 */

Dialog {
    property int rowid_in_db: -1

    SilicaFlickable {
        id: itemeditflick
        anchors.fill: parent
        contentHeight: detailsColumn.height

        VerticalScrollDecorator{}

        Column {
            id: detailsColumn
            anchors { left: parent.left; right: parent.right }
            spacing: Theme.paddingSmall

            PageHeader { title: "Accept edits" }

            TextField {
                id: itemname
                anchors { left: parent.left; right: parent.right }
                focus: true; label: "Item Name"; placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: itemname.focus = true
            }


            TextField {
                id: itemqty
                anchors { left: parent.left; right: parent.right }
                label: "Quantity"; placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: qty.focus = true
            }

            TextField {
                id: itemunit
                anchors { left: parent.left; right: parent.right }
                label: "Unit"; placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
            }

            TextField {
                id: itemclass
                anchors { left: parent.left; right: parent.right }
                label: "Item Class"; placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: itemclass.focus = true
            }

            ShopSelector {
                id: editshopselector
                label: qsTr("Shop")
                listmodel: shopModel
            }


        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Edit shops")
                onClicked: { pageStack.push(Qt.resolvedUrl("ShopPage.qml"));}
            }
        }

    }
    //"istat":"BUY", "iname":itemname.text, "iqty":itemqty.text, "iunit":itemunit.value, "iclass":itemclass.value, "rowid":rowid, "ishop":itemshop.value
    onOpened:{

        console.log("ItemEditPage onOpened: index=" + ci);
        itemname.text=shoppingListModel.get(ci).iname;
        itemqty.text=shoppingListModel.get(ci).iqty;
        itemunit.text=shoppingListModel.get(ci).iunit;
        itemclass.text=shoppingListModel.get(ci).iclass;
        rowid_in_db=shoppingListModel.get(ci).rowid;
        editshopselector.value=shoppingListModel.get(ci).ishop; //Sets the selector initial value correctly
    }

    onAccepted: {
        console.log("onAccepted-ItemEditPage. ci="+ci);

        console.log(itemname.text + ">" + itemqty.text  + ">" + itemunit.text + ">" + itemclass.text + ">" + editshopselector.value)
        DBA.updateItemInShoppingList(rowid_in_db,itemname.text, itemqty.text, itemunit.text, itemclass.text, editshopselector.value); //shop.currentname?
        refreshShoppingListByCurrentShop();
    }

}

