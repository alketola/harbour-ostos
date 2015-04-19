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
    allowedOrientations: Orientation.All
    property int changeCount: 0
    canAccept: changeCount > shopListView.count

    Component {
        id: shopDelegate

        ListItem {
            id:shopitem
            width: parent.width

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Delete")
                    onClicked: {
                        console.log("index:"+index)

                        if( DBA.shopRefCount(shopModel.get(index).name)>0) {
                            console.log("NOT deleting: " + shopModel.get(index).name)
                            /* The user should be warned why it's not deleting */
                            infoPanel.show()

                        } else {
                            console.log("deleting: " + shopModel.get(index).name)
                            remorseShop.execute(shopitem,"Deleting", function() {
                                DBA.deleteShop(shopModel.get(index).name)
                                shopModel.clear()
                                DBA.repopulateShopList(shopModel)
                                currentShop="unassigned"
//                                firstPage.value="unassigned"
                            },5000)
                        }
                    }
                }
            }
            Row {
                width: parent.width


                TextField {
                    id: shopname
                    text: model.name
                    readOnly: false
                    property int mychanges: 0

                    onTextChanged: {
                        changeCount++
                        mychanges++
                        shopModel.set(index,{"edittext":text}) // store changed value in model
//                        console.log("Text Changed! changeCount:"+ changeCount+" my changes="+mychanges+" currenttext="+text)
                    }

                }
                //                Label {
                //                    text: "refs."+DBA.shopRefCount(model.name)
                //                }
            }
        }
    }

    RemorseItem {id: remorseShop}

    SilicaListView {
        id: shopListView
        anchors.fill: parent
        contentHeight: parent.height + Theme.paddingLarge
        highlightFollowsCurrentItem: true

        VerticalScrollDecorator { }

        anchors {
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }
        header: PageHeader {
            title: qsTr("Shops")
        }

        DialogHeader {
            acceptText: {
                title: qsTr("Save")
            }
            cancelText: {
                title: qsTr("Don't save")
            }
        }

        ListView.onRemove: animateRemoval()

        model: shopModel
        delegate: shopDelegate

        VerticalScrollDecorator { }
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
            infoPanel.hide()
        }
    }


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
        shopModel.sync()
        currentShop=wildcard
//        pageStack.replace(Qt.resolvedUrl("FirstPage.qml"));
    }
    onCanceled: {
        console.log("ShopPage: onCanceled");
        changeCount=0
        shopModel.clear()
        DBA.repopulateShopList()
        currentShop="unassigned"
    }

    DockedPanel {
        id: infoPanel
        width: page.isPortrait ? parent.width : Theme.itemSizeExtraLarge + Theme.paddingLarge
        height: page.isPortrait ? Theme.itemSizeExtraLarge + Theme.paddingLarge : parent.height

        dock: page.isPortrait ? Dock.Bottom : Dock.Right
//        Button {
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.centerIn: parent.Center
//            text: qsTr("Cannot delete the shop.\n There are items to buy there.")
//            onClicked: infoPanel.hide()
//        }


    }

}
