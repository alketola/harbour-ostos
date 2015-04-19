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

    Component.onCompleted: { // loads the list
        refresh()
//        console.log("ShopSelector: onCompleted")
    }
    property ListModel listmodel
    property bool noRefillListmodel: false
    property string wildcard: "*"
    property string unassigned: "unassigned"
    property bool hidewildcard: false

    function refresh() {
//        console.log("ShopSelector: refresh()")
        shopModel.clear()
        DBA.repopulateShopList(shopModel)
    }

    function isWildcard(x) {
        return (x==wildcard)
    }

    function findShopListIndex(shopname) {
        for(var i=0;i<shopModel.count;i++) {
//            console.log("name="+shopModel.get(i).name+" shopname="+shopname+" i:"+i)
            if(shopModel.get(i).name == shopname)
            {
                return i+1
            }
        }
        return 0
    }

    menu: ContextMenu {
        id: scx

        MenuItem {
            id: anyMenuItem
            text: wildcard
            visible: !hidewildcard
            onClicked: {
                value = wildcard
                appWindow.currentShop=wildcard
                refreshShoppingListByShop()
            }
        }
        Repeater {
            id: shopRepe
            model: shopModel

            MenuItem {
                text: model.name
                onClicked: {
                    value=model.name
                    appWindow.currentShop=model.name
                    refreshShoppingListByShop()
                }
            }
        }
        ViewPlaceholder {
            enabled: shopModel.count == 0
            text: qsTr("-No items-")
        }
        onEntered: {
            console.log("onENtered")
        }

        onActivated: {
            refresh()
            currentIndex=findShopListIndex(appWindow.currentShop)
            shoppingListModel.clear
            console.log("ShopSelector onActivated, value:"+value)
        }
        onClosed: {
            appWindow.currentShop = value
            refreshShoppingListByShop()
        }
    }
}
