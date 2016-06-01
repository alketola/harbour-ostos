import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 * Main list page of the shopping list app
 */

Page {
    id: firstPage

    onStatusChanged: {
        if((firstPage.status==PageStatus.Activating)) {
            shopModel.clear()
            DBA.repopulateShopList(shopModel) // ShopModel
            requestRefresh(true,"firstPage status Activating")
        }
    }
    backNavigation: false

    _forwardDestination: Qt.resolvedUrl("ItemAddPage.qml")
    _forwardDestinationAction: PageStackAction.Push

    forwardNavigation: true


    SilicaListView {
        id: firstPageView
        clip: true
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: parent.height + Theme.paddingLarge

        //        Component.onCompleted: {
        //            console.log("FirstPage SilicaListView: Component.onCompleted")
        //            shopModel.clear()
        //            DBA.repopulateShopList(shopModel) // ShopModel
        //            console.log("*****firstPage.status:"+firstPage.status)
        //            //            requestRefresh((firstPage.status==PageStatus.Active),"FirstPage SilicaListview Completed")

        //        }


        header: PageHeader {
            id: phdr
            height:Theme.paddingLarge *3
            Row {
                id: headerRow
                spacing: Theme.paddingSmall
                anchors.fill: parent

                ShopSelector {
                    id: mainListShopSelector
                    label: qsTr("Shop")
                    width: firstPage.width - firstPageSearchImage.width - Theme.paddingLarge
                    listmodel: shopModel
                    onExited: {
                        requestRefresh(!mainListShopSelector._menuOpen,"mainListShopSelector exited, value:"+value)
                    }
                }
                Image {
                    id: firstPageSearchImage
                    source: "image://theme/icon-m-search"
                    y: Theme.paddingLarge
                }
            }
        }


        ViewPlaceholder {
            id: firstPagePlaceholder
            enabled: shoppingListModel.count == 0
            text: qsTr("No items")

            //            onEnabledChanged: {}

        }

        VerticalScrollDecorator { flickable: firstPageView }

        model: shoppingListModel
        delegate: listLine

        PullDownMenu {
            MenuItem {
                text: qsTr("Debug dump DB to log");
                onClicked: {
                    DBA.dumpShoppingList();
                    console.log("...dumped.");
                }
            }

            MenuItem {
                text: qsTr("Help")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
                }
            }

            //            MenuItem {
            //                text: qsTr("Settings")
            //                onClicked: {
            //                    pageStack.push("SettingsPage.qml")
            //                }
            //            }

            //            MenuItem {
            //                text: qsTr("Refresh (unnecessary)")
            //                onClicked: requestRefresh(true,"FirstPage menu selected");
            //            }


            //            MenuItem {
            //                text: qsTr("Set shop")
            //                onClicked: { console.log("currentShop:"+currentShop)}
            //            }

            MenuItem {
                text: qsTr("Edit shops")
                onClicked: { pageStack.push(Qt.resolvedUrl("ShopPage.qml"));}
            }

            MenuItem {
                text: qsTr("Enter to buy")
                onClicked: pageStack.push(Qt.resolvedUrl("ItemAddPage.qml"))
            }
        }

    }

    /*
     * This is the ListItem of the shopping list row
     */
    Component {
        id: listLine
        ListItem {
            id: lli
            onClicked: { //ListItem
                //                firstPageView.currentIndex = index;
                //                ci = index;
                //                stateIndicator.cycle();
                //                console.log("Clicked ListItem, index=" + index + " listView.currentIndex = " + listView.currentIndex)
            }
            onPressed: {
                firstPageView.currentIndex = index
                ci = index;
                //                console.log("Pressed ListItem, index=" + index + " listView.currentIndex = " + listView.currentIndex)
            }

            menu: LineButtonsMenu {
                id: lineButtonsMenu
                modelindex: index
            }

            Row {
                id: llr
                spacing: 5
                width: firstPage.width
                anchors.verticalCenter: parent.verticalCenter

                StatButton { id: stateIndicator }

                Label {
                    //                    x: 83
                    width: firstPage.width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    truncationMode: TruncationMode.Fade
                    text: iname //+ " " + iqty + " " + iunit
                }

                Label {

                    anchors.verticalCenter: parent.verticalCenter
                    text: iqty
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: iunit
                }
            }
        }
    } // END Component listLine


    RemorsePopup { id: remorse }

    function purgeShoppingList() {
        remorse.execute(qsTr("Clearing"), function() { DBA.deleteAllShoppingList(); shoppingListModel.clear() }, 10000 )
    }
}



