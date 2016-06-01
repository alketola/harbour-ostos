import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Dialog page for item details input into the shopping list app
 */

Dialog {

    property int editIndex

    id: detailsDialog
    allowedOrientations: Orientation.All
    onAccepted: {
        var rowid;
        if(itemshop.isWildcard()) {}
        console.log("onAccepted-Dialog of ItemDetailsPage")
        console.log(itemname.text + ">" + itemqty.text  + ">" + itemunit.value + ">" + itemclass.value + ">" + itemshop.value)
        rowid = DBA.insertItemToShoppingList("BUY", itemname.text, itemqty.text, itemunit.value, itemclass.value, itemshop.value);
        // Inserts the new item to row 0 of model
        shoppingListModel.insert(0,{ "istat":"BUY", "iname":itemname.text, "iqty":itemqty.text, "iunit":itemunit.value, "iclass":itemclass.value, "rowid":parseInt(rowid)});
        currentShop = wildcard
//        requestRefresh(true,"ItemDetailsPage Accepted")
        //currentShop = wildcard
    }
    onOpened: {
        console.log("ItemDetailsPage Dialog onOpened");
        shopModel.clear();
        DBA.repopulateShopList(shopModel);
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: detailsColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}


        Column {
            id: detailsColumn
            width: parent.width
            anchors { left: parent.left; right: parent.right }
            spacing: Theme.paddingSmall

            VerticalScrollDecorator {}

            PageHeader { title: qsTr("Add") }

            TextField {
                id: itemname
                anchors { left: parent.left; right: parent.right }
                focus: true;
                label: qsTr("Item Name")
                placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: nextField.focus = true
//                validator: RegExpValidator { regExp: }
            }


            TextField {
                id: itemqty
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Quantity")
                placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
//                EnterKey.onClicked: qty.focus = true
                EnterKey.onClicked: { itemunit.focus = true; }

            }

            ComboBox {
                id: itemunit
                //width: page.width
                label: qsTr("Unit")

                menu: ContextMenu {
                    MenuItem { text: qsTr("pcs") }
                    MenuItem { text: qsTr("g") }
                    MenuItem { text: qsTr("kg") }
                    MenuItem { text: qsTr("litres") }
                    MenuItem { text: qsTr("packs") }
                }
                onClicked: { itemshop.focus = true; }

            }

            ShopSelector {
                id: itemshop
                listmodel: shopModel
                label: qsTr("Shop")
                onEntered: {
                    hidewildcard=true
                    // When entering to item creation the item is new
                    // and shop should be unassigned.
                    // However, a shop must have been selected
                    // as the viewing shopping list by shop name
                    // requires a shop name
                    // engineering decision: assing a name that indicates
                    // unselected

                }

                onExited: {
                    console.log("Details/ShopSelector exited. Value:"+itemshop.value);
                }
                onPressed: { // Here could be context menu for modification and delete
                    //But this is not priority
                }
                Component.onCompleted: value=itemshop.unassigned
            }

            ComboBox {
                id: itemclass
                //width: page.width
                label: qsTr("Classification")

                menu: ContextMenu {
                    MenuItem { text: qsTr("vegetables") }
                    MenuItem { text: qsTr("fruit") }
                    MenuItem { text: qsTr("meat") }
                    MenuItem { text: qsTr("fish") }
                    MenuItem { text: qsTr("dairy") }
                    MenuItem { text: qsTr("other") }
                }

            }
         }
        PullDownMenu {
            id: detailsEditMenu
            //            MenuItem {
            //                text: qsTr("Edit classes")
            //            }
            //            MenuItem {
            //                text: qsTr("Edit units")
            //            }

            MenuItem {
                text: qsTr("Edit shops")
                onClicked: { pageStack.push(Qt.resolvedUrl("ShopPage.qml"));}
            }
        }

    }
}
