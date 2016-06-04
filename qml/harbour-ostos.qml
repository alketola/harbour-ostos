
//Copyright (C) Antti L S Ketola 2015 (antti.ketola at iki.fi)
//
//This file is part of ShopIt.

//ShopIt is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.

//ShopIt is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with ShopIt.  If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "pages"
import "dbaccess.js" as DBA

ApplicationWindow
{
    id: appWindow
    property int ci // a global for current shoppingListModel index, passed around
    property string currentShop // a global to set context for default shop
    property string wildcard: "*"
    property int refreshInterval: 1250

    ListModel {
        id: shoppingListModel
    }

    ListModel {
        id: templistmodel
    }

    ListModel {
        id: shopModel
    }

    SilicaListView {
        id: listView
    }

    SilicaFlickable {
        id: itemeditflick
    }


    initialPage: FirstPage { }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    FirstPage {
        id: firstPage
    }

    ItemDetailsPage {
        id: itemDetailsPage
    }

    ItemEditPage {
        id: itemEditPage
    }

    ItemAddPage {
        id: itemAddPage
    }

    ShopPage {
        id: shopPage
    }

    SettingsPage {
        id: settingsPage
    }

    Component.onCompleted: {
        DBA.initDatabase();
        currentShop = wildcard
    }

    function setRefreshInterval(millisec) {
        if ((millisec >99) && (millisec<5000)){
            refreshInterval = millisec
        } else {
          refreshInterval = 1250
        }
    }

    function  refreshShoppingListByCurrentShop(){
        // console.log("refresh; shopname="+currentShop)
        if ((currentShop==wildcard) || (!currentShop) ) {
            shoppingListModel.clear()
            DBA.readShoppingListExState(shoppingListModel,"HIDE");
        } else {
            shoppingListModel.clear()
            DBA.readShoppingListByShopExState(shoppingListModel, currentShop,"HIDE");
        }
    }

    //     This timer is used to refresh the shopping list in a separate thread.
    Timer {
        id: menurefreshtimer
        interval: refreshInterval
        repeat: false

        property bool _enabler
        property string _current

        function turn_on(enabler,current) {
            //            console.debug("menurefreshtimer turn_on: enabler:"+enabler+" current:"+current)
            _enabler=enabler
            _current=current
            start()
        }

        onTriggered: {

            stop()
            if(_enabler){
                //                console.debug("menurefresh timer triggered.");
                refreshShoppingListByCurrentShop()

            } else {
                //                console.debug("menurefresh timer triggered and skipped; trace:"+ _current);
            }
        }
    }
    /*
     * Function to request refresh - without timer
     */
    function requestRefresh(enabler,tracetext) {
        console.debug("harbour-ostos.requestRefresh : enabler: "+enabler+" trace:'"+tracetext+"' firstPage.status:"+firstPage.status)
        refreshShoppingListByCurrentShop()
        console.debug("\tPage status="+firstPage.status)

        console.debug("Legend:\n\tPageStatus.Active="+PageStatus.Active+" PageStatus.Inactive="+PageStatus.Inactive+"\n\tPageStatus.Activating="+PageStatus.Activating+" PageStatus.Deactivating="+PageStatus.Deactivating)
    }
    /*
 * Function to request refresh asynchronously - the timer version spawning a new thread
 */
    function requestRefreshAsync(enabler,tracetext) {
        console.debug("harbour-ostos.requestRefresh : enabler: "+enabler+" trace:'"+tracetext+"' firstPage.status:"+firstPage.status)

        if (!menurefreshtimer.running) {
            menurefreshtimer.turn_on(enabler,tracetext)
        } else {
            menurefreshtimer.restart()
            console.debug("harbour-ostos.requestRefresh - restarted timer.")
        }
    }
}


