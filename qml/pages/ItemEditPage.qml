import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA
import "../pages"

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Dialog page for item details input in the shopping list app
 */
Dialog {
    id: itemeditdialog
    allowedOrientations: Orientation.All

    property int rowid_in_db: -1
    property string name_in: "not set"

//    acceptDestination: pageStack.find(function(page) {return page.pagemark === "firstPage" })
//    acceptDestinationAction: PageStackAction.Pop
    backNavigation: true
    forwardNavigation: false

    SilicaFlickable {
        id: itemeditflick
        anchors.fill: parent
        contentHeight: detailsColumn.height

        VerticalScrollDecorator{}

        Column {
            id: detailsColumn
            anchors { left: parent.left; right: parent.right }
            spacing: Theme.paddingSmall

            PageHeader {
                id: itemEditPageHeader

                Button {
                    anchors.right: parent.right
                    text: qsTr("Accept")
                    y: Theme.paddingLarge

                    onClicked: {
                        // THIS IS NOW ACCEPT
                        var selectedShopToDB = editshopselector.getValue()

                        console.debug("ItemEditPage.onClicked-ItemEditPage. ci="+currIndex+" item name="+itemname.text)
                        var rowid = DBA.findItemByName(null,itemname.text)
                        //        console.debug("Found in DB rowid:"+rowid+" for name"+itemname.text)

                        // console.debug("editshopselector.value="+editshopselector.value
                        //              +" .getValueForDB()="+editshopselector.getValue())
                        // console.debug("Row to db: "+rowid_in_db+":"+itemname.text + ">" + itemqty.text  + ">" + itemunit.text + ">" + itemclass.text + ">" + selectedShopToDB)
                        if (rowid) {
                            // console.log("...updating existent ci="+currIndex+" itemshop="+selectedShopToDB)
                            DBA.updateItemState(rowid_in_db,"BUY")
                            DBA.updateItemInShoppingList(rowid,itemname.text, itemqty.text, itemunit.text, itemclass.text, selectedShopToDB); //shop.currentname?
                            DBA.updateItemState(rowid,"BUY")
                            DBA.updateShoppinListNextSeq(rowid)
                        } else { // adding new
                            //            console.log("...adding new ci="+ci)
                            DBA.insertItemToShoppingList("BUY",itemname.text,itemqty.text, itemunit.text, itemclass.text, selectedShopToDB)
                        }
                        currShop=wildcard
                        shopFilter=[wildcard]
                        filterdesc=wildcard
                        pageStack.clear()
                        pageStack.push(Qt.resolvedUrl("FirstPage.qml"),{})
                        console.log("pageStack.depth="+pageStack.depth)
                    }
                }

            }

            TextField {
                id: itemname
                anchors { left: parent.left; right: parent.right }
                focus: true; label: qsTr("Item Name"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: itemqty.focus = true
            }


            TextField {
                id: itemqty
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Quantity"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: itemunit.focus = true
            }

            TextField {
                id: itemunit
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Unit"); placeholderText: label
                font.capitalization: Font.MixedCase
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: itemclass.focus = true;
                inputMethodHints: Qt.ImhNoAutoUppercase
            }

            TextField {
                id: itemclass
                anchors { left: parent.left; right: parent.right }
                label: qsTr("Item Class"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: editshopselector.focus = true
            }

            ShopSelector {
                id: editshopselector
                hidewildcard: true
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
        console.log("ItemEditPage onOpened: index=" + currIndex);
        console.log("name_in:"+name_in)
        itemname.text=shoppingListModel.get(currIndex).iname;
        itemqty.text=shoppingListModel.get(currIndex).iqty;
        itemunit.text=shoppingListModel.get(currIndex).iunit;
        itemclass.text=shoppingListModel.get(currIndex).iclass;
        rowid_in_db=shoppingListModel.get(currIndex).rowid;
        var shopname= (shoppingListModel.get(currIndex).ishop) ? shoppingListModel.get(currIndex).ishop : DBA.unknownShop
        editshopselector.setValue(shopname)

    }

//    onDone: {
//        console.log("Dialog.onDone")
//        console.log("pageStack.depth="+pageStack.depth)
//    }

//    onAccepted: {
//        console.log("Dialog.onAccepted")

//        console.log("pageStack.depth="+pageStack.depth)
//                var selectedShopToDB = editshopselector.getValue()

//                console.debug("ItemEditPage.onAccepted-ItemEditPage. ci="+currIndex+" item name="+itemname.text)
//                var rowid = DBA.findItemByName(null,itemname.text)
//                //        console.debug("Found in DB rowid:"+rowid+" for name"+itemname.text)

//                // console.debug("editshopselector.value="+editshopselector.value
//                //              +" .getValueForDB()="+editshopselector.getValue())
//                // console.debug("Row to db: "+rowid_in_db+":"+itemname.text + ">" + itemqty.text  + ">" + itemunit.text + ">" + itemclass.text + ">" + selectedShopToDB)
//                if (rowid) {
//                    // console.log("...updating existent ci="+currIndex+" itemshop="+selectedShopToDB)
//                    DBA.updateItemState(rowid_in_db,"BUY")
//                    DBA.updateItemInShoppingList(rowid,itemname.text, itemqty.text, itemunit.text, itemclass.text, selectedShopToDB); //shop.currentname?
//                    DBA.updateItemState(rowid,"BUY")
//                    DBA.updateShoppinListNextSeq(rowid)
//                } else { // adding new
//                    //            console.log("...adding new ci="+ci)
//                    DBA.insertItemToShoppingList("BUY",itemname.text,itemqty.text, itemunit.text, itemclass.text, selectedShopToDB)
//                }
//                currShop=wildcard
//    }

}
