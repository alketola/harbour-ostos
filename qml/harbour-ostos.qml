
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
import "./dbaccess.js" as DBA

ApplicationWindow
{
    id: appWindow

    allowedOrientations: Orientation.All

    property int ci // a global for current shoppingListModel index, passed around
    property string currentShop // a global to set context for default shop
    property string wildcard: "*"
    property int refreshInterval: 300

    onOrientationChanged: {
        console.log("Orientation changed:"+orientation)
    }

    ListModel {
        id: shoppingListModel
    }

    ListModel {
        id: templistmodel
    }

    ListModel {
        id: shopModel
    }
    Component {
        id: listView
        SilicaListView {}
    }
    Component {
        id: itemeditflick
        SilicaFlickable {}
    }
    initialPage: firstPage

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    Component {
        id: firstPage
        FirstPage {}
    }

    //    ItemDetailsPage {
    //        id: itemDetailsPage
    //    }
    Component {
        id: itemEditPage
        ItemEditPage {}
    }
    Component {
        id: itemAddPage
        ItemAddPage {}
    }
    Component {
        id: shopPage
        ShopPage {}
    }

    Component {
        id: settingsPage
        SettingsPage {}
    }

    Component.onCompleted: {
        DBA.initDatabase();
        currentShop = wildcard
    }

    function setRefreshInterval(millisec) {
        if ((millisec >=0) && (millisec<=2000)){
            refreshInterval = millisec
        } else {
            refreshInterval = 300
        }
    }

    function  refreshShoppingListByCurrentShop(){
         console.log(" Refresh; shopname="+currentShop)

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
            toast.show()
        }

        onTriggered: {

            stop()
            if(_enabler){
                //                console.debug("menurefresh timer triggered.");
                refreshShoppingListByCurrentShop()

            } else {
                //                console.debug("menurefresh timer triggered and skipped; trace:"+ _current);
            }
            toast.hide()
        }
    }
    /*
     * Function to request refresh - without timer
     */
    function requestRefresh(enabler,tracetext) {
        //        console.debug("harbour-ostos.requestRefresh : enabler: "+enabler+"; trace:'"+tracetext)
        refreshShoppingListByCurrentShop()
    }
    /*
 * Function to request refresh asynchronously - the timer version spawning a new thread
 */
    function requestRefreshAsync(enabler,tracetext) {
        console.debug("harbour-ostos.requestRefreshAsync : enabler: "+enabler+"; trace:'"+tracetext+"'")

        if (!menurefreshtimer.running) {
            menurefreshtimer.turn_on(enabler,tracetext)
        } else {
            menurefreshtimer.restart()
            //            console.debug("harbour-ostos.requestRefresh - restarted timer.")
        }
    }
    Rectangle {
        color: "#"+(~(valueOf(Theme.primaryColor)))
        opacity: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 3
        height: 0

        id: toast
        Label {
            id: toastLabel

            visible: parent.visible
            color: Theme.primaryColor
            opacity: 100
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width// - Theme.paddingLarge
            height: parent.height

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Updating")
        }
        states: State {
            name: "toasting"; when: visible
            PropertyChanges {
                target: toast; height: Theme.itemSizeMedium
            }
        }
        transitions: Transition {
            to: "toasting"
            ParallelAnimation {
                PropertyAnimation {
                    target: toast
                    properties: "height";
                    duration: 150
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: toastLabel
                    properties: "font.pixelSize"
                    duration: 300
                    from:0
                    to: Theme.fontSizeMedium
                }
            }
        }

        function show() {
            //            console.log("***show toast")
            visible=true
            state = "toasting"
        }
        function hide() {
            //            console.log("***hide toast")
            visible=false
            state=""

        }

        Component.onCompleted: {
            visible=false
            state=""
        }
    }
}


