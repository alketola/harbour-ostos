import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * This is a ComboBox for selecting a shop in the shopping list app. It has
 * one fixed element and a Repeater that is filled from local storage database.
 *
 * The listmodel is defined as a global outside of this, because defining it
 * inside this, it yielded 'QML ContextMenu: Cannot anchor to a null item.'
 * at times.
 *
 */
ComboBox {

    width: parent.width
    y: Theme.paddingLarge

    property bool menuOpen
    _backgroundColor: "black"
    opacity: Theme.highlightBackgroundOpacity
    labelColor: Theme.secondaryColor
    Component.onCompleted: { // loads the list
        refresh()
        //        console.log("ShopSelector: onCompleted")
    }
    property ListModel listmodel
    property bool noRefillListmodel: false
    //    property string wildcard: "*"
    property string unassigned: "unassigned"
    property bool hidewildcard: false

    function refresh() {
        //        console.log("ShopSelector: refresh()")
        listmodel.clear()
        DBA.repopulateShopList(listmodel)
    }

    function isWildcard(x) {
        return (x==wildcard)
    }

    function findShopListIndex(shopname) {
        for(var i=0;i<listmodel.count;i++) {
            //            console.log("name="+listmodel.get(i).name+" shopname="+shopname+" i:"+i)
            if(listmodel.get(i).name == shopname)
            {
                return i+1
            }
        }
        return 0
    }

    menu: ContextMenu {
        id: scx
        _closeOnOutsideClick: true

        MenuItem {                         // The first item in the shop menu is wildcard, or "any-star"
            id: anyMenuItem
            text: wildcard
            visible: !hidewildcard
            onClicked: {
                value = wildcard
                appWindow.currentShop=wildcard
                requestRefresh(true,"ShopSelector ContexMenu closed")
            }
        }
        Repeater {
            id: shopRepe
            model: listmodel

            MenuItem {
                text: model.name
                onClicked: {
                    value=model.name
                    appWindow.currentShop=model.name
                    requestRefresh(true,"ShopSelector ContexMenu closed")
                }
            }
        }
//        ViewPlaceholder {
//            enabled: listmodel.count == 0
//            text: qsTr("-No items-")
//        }

        onClosed: {
            appWindow.requestRefresh(true,"ShopSelector ContexMenu Closed")
        }
        onExited: {
            appWindow.requestRefresh(true,"ShopSelector ContexMenu Exited")
        }


    }
    onEntered: {
        menuOpen=true
        console.log("Entered Shop Selector menuOpen:"+menuOpen)
//        shoppingListModel.//clear();


    }


    onClicked: {
        console.log("ShopSelector contextmenu onClicked, value:"+value)
    }




}
