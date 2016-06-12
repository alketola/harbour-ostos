import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Dialog page for editing shops' details, in the shopping list app
 */
Dialog {
    id: shopDialog

    allowedOrientations: Orientation.All
    property int changeCount: 0
    property string wildcard: "*"
    property string unassigned: "unassigned"
    canAccept: changeCount > shopListView.count

    SilicaListView {
        id: shopListView
        anchors.fill: parent
        contentHeight: parent.height
        highlightFollowsCurrentItem: true

        VerticalScrollDecorator { }

        //        anchors {
        //            left: parent.left
        //            right: parent.right
        //            margins: Theme.paddingLarge
        //        }

        //        ListView.onRemove: animateRemoval()

        model: shopModel
        delegate: shopDelegate
        header: DialogHeader {
            width: shopDialog.width
            acceptText: {
                title: qsTr("Accept")
            }
            cancelText: {
                title: qsTr("Back")
            }
        }

        ViewPlaceholder {
            enabled: shopModel.count == 0
            text: qsTr("No items")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr ("Add new shop")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("NewShopDialog.qml"));
                }
            }
        }

        Component.onCompleted: {
            shopModel.clear();
            DBA.repopulateShopList(shopModel);
            changeCount=0
        }
    } //end silicalistview


    onExited: {
        console.log("ShopPage: onExited");
        pageStack.replace(Qt.resolvedUrl("FirstPage.qml"))
    }
    onAccepted: {
        console.log("ShopPage: onAccepted");
        // Store changed fields to database
        var oldtext
        var newtext
        for (var i=0; i<shopModel.count;i++) {
            //            console.log(":->"+shopModel.get(i).edittext)
            oldtext = shopModel.get(i).name
            newtext = shopModel.get(i).edittext
            if(newtext != oldtext) {
                // Check if the new shopname <edittext> exist. Disallow making second or replace?
                // UPDATE Shopping list: change shop name from <name> to <edittext>
                // UPDATE Shop list: replace "name" with "edittext"
                DBA.updateShopNameDB(oldtext, newtext)
                DBA.updateShopNameInShoppinglistDB(oldtext,newtext)
                shopModel.get(i).name=newtext
            }
        }
        currentShop=wildcard
    }
    onCanceled: {
        console.log("ShopPage: onCanceled");
        changeCount=0
        shopModel.clear()
        DBA.repopulateShopList()
        currentShop=wildcard
    }


    function updateShopNameInLM(lm, oldname, newname) {
        for (var i=0; i<lm.count; i++ ) {
            if (lm.get(i).ishop==oldname) {
                lm.get(i).ishop=newname
            }
        }
    }

    Component {
        id: shopDelegate

        ListItem {
            id:shopitem
            //            width: parent.width
            TextField {
                id: shopField
                //                anchors { left: parent.left; right: parent.right }
                text: (model.name == "unassigned") ? qsTr("unassigned") : model.name
                EnterKey.enabled: true //text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    console.log("ShopPage.qml EnterKey.onClicked")
                    readOnly = true
                }

                property int mychanges: 0

                onTextChanged: {
                    changeCount++
                    mychanges++
                    shopModel.set(index,{"edittext":text}) // store changed value in model
                    //                    console.log("ShopPage.qml: Text Changed! changeCount:"+ changeCount+" my changes="+mychanges+" currenttext="+text)
                }
                Component.onCompleted: {
                    readOnly = true
                }
            }

            Rectangle {
                anchors {
                    top: parent.top;
                    bottom: parent.bottom;
                    left: parent.left;
                    right: parent.right;
                    margins: 2
                }
                color: Theme.highlightBackgroundColor
                opacity: Theme.highlightBackgroundOpacity /3
            }

            menu: ContextMenu {
                id: scxmenu

                MenuItem {
                    text: qsTr("Edit")
                    height: Theme.itemSizeSmall
                    enabled: ((model.name != unassigned) &&
                              (model.name != qsTr("unassigned")) &&
                              (model.name != wildcard))
                             ? true : false
                    onClicked: {
                        console.log("ShopPage.shopitem.ContextMenu.Edit index:"+index)
                        shopField.readOnly = false
                        shopField.forceActiveFocus()
                    }
                }
                MenuItem {
                    text: qsTr("Delete")
                    height: Theme.itemSizeSmall
                    enabled: ((model.name != unassigned) &&
                              (model.name != qsTr("unassigned")) &&
                              (model.name != wildcard))
                             ? true : false
                    onClicked: {
                        console.log("ShopPage.shopitem.ContextMenu.Delete index:"+index)
                        //                        deleteshop(index)
                        var shopitem = shopModel.get(index)
                        var shopname = shopitem.name
                        var refcount = DBA.shopRefCount(shopname)
                        if( refcount>0) {
                            remorseShopDelete.execute(scxmenu.parent,"Deleting", function() {
                                console.log("ShopPage.qml: Deleting "+shopname+" the hard way, there are "+refcount+" references")
                                console.log("ShopPage.qml: ...reassign to unassigned in DB")
                                DBA.updateShopNameInShoppinglistDB(shopname,unassigned)
                                console.log("ShopPage.qml: ...reassign to unassigned in shoppingListModel")
                                updateShopNameInLM(shoppingListModel,shopname,unassigned)
                                console.log("ShopPage.qml: ...reassign to unassigned in DB")
                                DBA.deleteShop(shopname)
                                shopModel.clear()
                                DBA.repopulateShopList(shopModel)
                                currentShop=qsTr("unassigned")
                                console.log("ShopPage.qml: deleteshop finished")
                            },5000)

                        } else {
                            console.log("deleting: " + shopname)
                            remorseShopDelete.execute(scxmenu.parent,"Deleting", function() {
                                DBA.deleteShop(shopname)
                                shopModel.clear()
                                DBA.repopulateShopList(shopModel)
                                currentShop=qsTr("unassigned")
                            },5000)
                        }
                        console.log("ShopPage.qml: deleteshop finished")
                    }
                }
                RemorseItem {id: remorseShopDelete}
            }

        }
    }
    /* function to delete shop occurrenses in
     * shoppingList DB, shoppingListModel and shoplist
     */
    function deleteshop(i) {
        var shopitem = shopModel.get(i)
        var shopname = shopitem.name
        var refcount = DBA.shopRefCount(shopname)
        if( refcount>0) {
            console.log("ShopPage.qml: Deleting "+shopname+" the hard way, there are "+refcount+" references")
            console.log("ShopPage.qml: ...reassign to unassigned in DB")
            DBA.updateShopNameInShoppinglistDB(shopname,unassigned)
            console.log("ShopPage.qml: ...reassign to unassigned in shoppingListModel")
            updateShopNameInLM(shoppingListModel,shopname,unassigned)
            console.log("ShopPage.qml: ...reassign to unassigned in DB")
            DBA.deleteShop(shopname)
            console.log("ShopPage.qml: deleteshop finished")

        } else {
            console.log("deleting: " + shopModel.get(i).name)
            remorseShopDelete.execute(scxmenu.parent,"Deleting", function() {
                DBA.deleteShop(shopModel.get(i).name)
                shopModel.clear()
                DBA.repopulateShopList(shopModel)
                currentShop=qsTr("unassigned")
            },4000)
        }
        console.log("ShopPage.qml: deleteshop finished")
    }
}
