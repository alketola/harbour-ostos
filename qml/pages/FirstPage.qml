import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 * Main list page of the shopping list app
 */

Page {
    id: firstPage
    allowedOrientations: Orientation.All

    onStatusChanged: {
        //        console.log("first page status changed:"+status+" PageStatus.Active="+PageStatus.Active+" PageStatus.Inactive="+PageStatus.Inactive)
        if((firstPage.status==PageStatus.Active)) {
            firstPageView.delegate = listLine // to make sure that it is present, even if exited shop selector badly
            requestRefresh("firstPage status changed to Active")
            // Refactor? Why to always clear and repopulate shop list
            shopModel.clear()
            DBA.repopulateShopList(shopModel) // ShopModel
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
        contentHeight: parent.height - Theme.paddingLarge
        anchors.margins: 2


        header: PageHeader {
            id: phdr
            height: Theme.itemSizeMedium
            Row {
                id: headerRow
                spacing: Theme.paddingSmall
                anchors.fill: parent

                ShopSelector {
                    id: mainListShopSelector
                    label: qsTr("Shop")
                    width: firstPage.width - firstPageSearchImage.width - Theme.paddingLarge
                    anchors.top: parent.top
                    listmodel: shopModel
                    overlappedToHide: listLine
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
            enabled: shoppingListModel.count == 0 | shoppingListModel.updating == true
            text: qsTr("-")
        }

        VerticalScrollDecorator { flickable: firstPageView }

        model: shoppingListModel
        delegate: listLine

        PullDownMenu {
            id: pulldownmenu
            property string optionSelected: ""
            //            MenuItem {
            //                text: qsTr("Debug dump DB to log");
            //                onClicked: {
            //                    DBA.dumpShoppingList();
            //                    console.log("...dumped.");
            //                }
            //            }
            //            MenuItem {
            //                text: qsTr("DELETE DB ");
            //                onClicked: {
            //                    DBA.deleteAllShoppingList()
            //                    console.log("...deleted database.");
            //                }
            //            }

            MenuItem {
                text: qsTr("Help")
                onClicked: {
                    pulldownmenu.optionSelected=text
                    pageStack.push(Qt.resolvedUrl("HelpPage.qml"))
                }
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pulldownmenu.optionSelected=text
                    pageStack.push("SettingsPage.qml")
                }
            }

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
                onClicked: {
                    pulldownmenu.optionSelected=text
                    pageStack.push(Qt.resolvedUrl("ShopPage.qml"));
                }
            }

            MenuItem {
                text: qsTr("Hide bought")
                onClicked: {
                    pulldownmenu.optionSelected=text
                    DBA.bulkStateChange(shoppingListModel,"GOT","HIDE")
                    requestRefresh("Hid bought")
                }
            }

            MenuItem {
                text: qsTr("Search to buy")
                onClicked: {
                    pulldownmenu.optionSelected=text
                    pageStack.push(Qt.resolvedUrl("ItemAddPage.qml"))
                }
            }

//            onStateChanged: {
//                console.log("FirstPage PullDownMenu StateChanged, option selected="+pdm.optionSelected+" state="+state)
//                if ((state != "expanded") && (pdm.optionSelected == "")) requestRefreshAsync(true,"FirstPagePulldown")
//            }
        }
    }

    /*
     * This is the ListItem of the shopping list row
     */
    Component {
        id: listLine
        ListItem {
            id: itemi
            //            height: Theme.itemSizeSmall
//            onClicked: { //ListItem
//                //                firstPageView.currentIndex = index;
//                //                ci = index;
//                //                stateIndicator.cycle();
//                //                console.log("Clicked ListItem, index=" + index + " listView.currentIndex = " + listView.currentIndex)
//                //                console.debug("shoppinglistitem height is:"+itemi.height)
//            }
            onPressed: {
                firstPageView.currentIndex = index
                currIndex = index;
                // pageStack.push(Qt.resolvedUrl("QuickEditPage.qml"))
                //                console.log("Pressed ListItem, index=" + index + " listView.currentIndex = " + listView.currentIndex)
                var menucomponent = Qt.createComponent("LineButtonsMenu.qml");
                //Would listLine more appropriate as parent of created menu object?
                //No, gives error "QQmlComponent: Created graphical object was not placed in the graphics scene."
                var menuo = menucomponent.createObject(firstPageView,{"modelindex":currIndex});
                itemi.menu = menuo;
                //menuo.show();
            }

            Row {
                id: llr
                spacing: 6
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StatButton { id: stateIndicator }

                Label {
                    width: (orientation == Orientation.Portrait) ? firstPage.width * 0.5 : firstPage.width * 0.7
                    anchors.verticalCenter: parent.verticalCenter
                    truncationMode: TruncationMode.Fade
                    text: iname
                }
                Label {
                    width: firstPage.width * 0.1
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    text: iqty
                }
                Label {
                    truncationMode: TruncationMode.Fade
                    horizontalAlignment: Text.AlignLeft
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor
                    text: iunit
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
        }
    } // END Component listLine


    RemorsePopup { id: remorse }

    function purgeShoppingList() {
        remorse.execute(qsTr("Clearing"), function() { DBA.deleteAllShoppingList(); shoppingListModel.clear() }, 10000 )
    }
}



