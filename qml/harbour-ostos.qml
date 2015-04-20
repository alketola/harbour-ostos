
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
    property int ci // a global for current index, passed from FirstPage to ItemEditPage
    property string currentShop // a global to set context for default shop
    property string wildcard: "*"

    ListModel {
        id: shopModel
    }

    ListModel {
        id: shoppingListModel
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

    //    ShopPage {
    //        id: shopPage
    //    }


    Component.onCompleted: {
        DBA.initDatabase();
    }


    function  refreshShoppingListByShop(){
        console.log("shopname:"+currentShop)
        if ((currentShop==wildcard) || (!currentShop) ) {
            shoppingListModel.clear();
            DBA.readAllShoppingList(shoppingListModel);
        } else {
            shoppingListModel.clear();
            DBA.readShoppingListByShop(shoppingListModel, currentShop);
        }
        menurefreshtimer.stop()
    }

    //     This timer is just to fix a the problem that comes from clearing
    //     the shopping list when entering to the FirstPage ShopSelector
    //     and then just closing the menu without selection. The shopping list is
    //     not refreshed and I could not find a ComboBox event to fix shopping
    //     list refresh in.
    //     A pragmatic solution.
    Timer {
        id: menurefreshtimer
        interval: 300; running: false; repeat: false

        property bool _enabler
        property string _current

        function turn_on(enabler,current) {
            console.log("turn_on:"+_enabler)
            _enabler=enabler
            _current=current
            start()
        }

        //enabler: !mainListShopSelector._menuOpen
        //current: currentShop

        onTriggered: {
            console.log("ostos/ShopSelector TIMER onTriggered, running:"+running);
            stop()
            if(_enabler){
                //                            shoppingListModel.clear();
                refreshShoppingListByShop()

            } else {
//                interval=1000
//                if (_enabler) {
//                    restart()
//                    console.log("ostos/ShopSelector TIMER restart, running:"+running);
//                }
                console.log("ostos/ShopSelector TIMER ceased, running:"+running);
            }
        }
    }

}


