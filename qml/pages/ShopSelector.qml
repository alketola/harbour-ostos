import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2016
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

/** SIDE EFFECTS
 * Do not love using globals
 * - appWindow.currShop = model.name
 * - firstPageView.delegate = nilvue ; This is to disable shoppinglist touches
 * - appWindow.requestRefresh() causing the firstPage contents to refresh
 */
/** DBA the database is only read for shop names */

ComboBox {

    property Component overlappedToHide         // if there is something that has to be hidden
    // when ComboBox menu opens put it to overlappedToHide
    property ListModel listmodel                // The listmodel where the shop names are
    property bool hidewildcard: false           // flag to hide the wildcard option
    property string dbvalue
    /* value aka. ComboBox.value is the selected / highlighted item */

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

    /*
     * getting ShopSelector's value so that it is not intenationalized
     */
    function getValue() {
        // console.log("ShopSelector.qml; value="+value)
        var value_out
        if (value == wildcard) {
            value_out = DBA.unknownShop // dissallowing * in database
            debug.warn("Decoded wildcard to unknownShop, no * to DB!")
        } else {
            value_out = value  // Otherwise, let it be.
        }
        // console.log("ShopSelector.qml; value_out="+value_out)
        return value_out
    }

    /*
      * Setting ShopSelector's value with a database value
      */

    function setValue(dbvalue) {
            value = dbvalue  // let it be.
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
                appWindow.currShop=wildcard
                shopFilter = [wildcard]
            }
        }

        Repeater {
            id: shopRepe
            model: listmodel

            MenuItem {
                text: model.name
                onClicked: {
                    value= model.name
                    appWindow.currShop = model.name
                    // console.debug("Shop Selector.qml: set appWindow.currShop="+appWindow.currShop)
                }
            }
        }

        /* Event handlers get called intrestingly in order (as seen by console logs)
          * ComboBox.onEntered --> ComboBox.onStateChanged -->
          * ContextMenu.onClicked --> ContextMenu.onExited -->
          * ComboBox.onStateChanged --> ContextMenu.onClosed */

        onClosed: {
            //            console.log("ShopSelector contextmenu onClosed, value:"+value)
            if (overlappedToHide) firstPageView.delegate = overlappedToHide
            appWindow.requestRefresh("ShopSelector ContexMenu Closed")
        }
    }
    onEntered: {
        forceActiveFocus()
        if(overlappedToHide) firstPageView.delegate = nilvue
    }


    //    onStateChanged: {

    //        if(state) {
    //            console.log("ShopSelector.qml activated ("+state+")")
    //        } else {
    //            console.log("ShopSelector.qml deactivated (no state).")
    //        }
    //    }
}

