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

    property Component overlappedToHide         // if there is something that has to be hidden
                                                // when ComboBox menu opens put it to overlappedToHide
    property ListModel listmodel                // The listmodel where the item names are
    property bool hidewildcard: false           // flag to hide the wildcard option
    // next learn binding
    // property string outputstring: appWindow.currentShop // The string where the selected string is to be output

    property string wildcard: "*"
    property string unassigned: "unassigned"

    width: parent.width
    labelColor: Theme.secondaryColor

    Component.onCompleted: { // loads the list
        refresh()
    }

    function refresh() {
      listmodel.clear()
      DBA.repopulateShopList(listmodel)
    }

    function isWildcard(x) {
        return (x==wildcard)
    }

//    function findShopListIndex(shopname) {
//        for(var i=0;i<listmodel.count;i++) {
//            //            console.log("name="+listmodel.get(i).name+" shopname="+shopname+" i:"+i)
//            if(listmodel.get(i).name == shopname)
//            {
//                return i+1
//            }
//        }
//        return 0
//    }

    menu: ContextMenu {
        id: scx
        _closeOnOutsideClick: true

        MenuItem {  // The first item in the shop menu is wildcard, or "any-star"
            id: anyMenuItem
            text: wildcard
            visible: !hidewildcard
            onClicked: {
                value = wildcard
                appWindow.currentShop=wildcard
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
                }
            }
        }

         /* Event handlers get called intrestingly in order (as seen by console logs)
          * ComboBox.onEntered --> ComboBox.onStateChanged -->
          * ContextMenu.onClicked --> ContextMenu.onExited -->
          * ComboBox.onStateChanged --> ContextMenu.onClosed */

        onClosed: {
            //            console.log("***************ShopSelector contextmenu onClosed, value:"+value)
            if (overlappedToHide) firstPageView.delegate = overlappedToHide
            appWindow.requestRefresh(true,"ShopSelector ContexMenu Closed")
        }
    }
    onEntered: {
        forceActiveFocus()
        if(overlappedToHide) firstPageView.delegate = nilvue
    }

    Component {id: nilvue
        ListView { id: nillistview }
    }

    //    onStateChanged: {

    //        if(state) {
    //            console.log("ShopSelector.qml activated ("+state+")")
    //        } else {
    //            console.log("ShopSelector.qml deactivated.")
    //        }
    //    }
}
