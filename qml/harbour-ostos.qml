
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

    //    function setItemState(rowid,curri,state) {
    //        // shopListModel.get(listView.currentIndex).rowid),statButton.state
    //        DBA.updateItemState(parseInt(rowid,state));
    //        //listView.currentIndex,"istat",state
    //        shoppingListModel.setProperty(curri,"istat",state);
    //    }

    function refreshShoppingListByShop() {
        console.log("shopname:"+currentShop)
        if ((currentShop==wildcard) || (!currentShop) ) {
            shoppingListModel.clear();
            DBA.readAllShoppingList(shoppingListModel);
        } else {
            shoppingListModel.clear();
            DBA.readShoppingListByShop(shoppingListModel, currentShop);
        }
    }


}


