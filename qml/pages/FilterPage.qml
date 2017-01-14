import QtQuick 2.2
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

Page {
    id: filterPage

    property int changeCount:0
    property string lastselected
    property int selectedcount: 0
    property bool wildcardset: false

    backNavigation: false
    forwardNavigation: false

    SilicaListView {
        id: filterView
        anchors.fill: parent
        contentHeight: parent.height
        highlightFollowsCurrentItem: true

        VerticalScrollDecorator { }

        ListView.onRemove: animateRemoval()

        model: shopModel

        header: PageHeader {
            id: optHdr
            anchors.topMargin: Theme.paddingLarge
            Button {  // The first button wildcard, or "any-star"
                id: anyMenuItem
                y: Theme.paddingMedium
                anchors.left: parent.left
                x: Theme.paddingMedium
                text: wildcard
                visible: true

                onClicked: {
                    down = !down
                    lastselected = wildcard
                    shopFilter = [wildcard]
                    setAllSwitches(shopModel,down)
                }
                Component.onCompleted: {
                    console.log("* button on complete")
                    down = true
                    //lastselected = wildcard
                    //updateListmodelSwitches(shopModel,shopFilter)
                }
            }

            Button {
                id: optAccept
                y: Theme.paddingMedium

                anchors.right: parent.right
                text: qsTr("Accept")
                onClicked: {
                    //*** THIS IS NOW TO ACCEPT ***
                    updateShopsToDB()
                    console.log("pageStack.depth="+pageStack.depth)
                    getCheckedSwitches(shopModel)

                    if (shopFilter.toString().length>0){
                        filterdesc = shopFilter.toString()
                    } else {
                        shopFilter[0]=wildcard
                        filterdesc = wildcard
                    }

                    if(lastselected=="") lastselected ="*"
                    currShop = lastselected
                    pageStack.pop()
                }
            }
        }

        ViewPlaceholder {
            enabled: shopModel.count == 0
            text: qsTr("No shops")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Undo edits")
                onClicked: {
                    doCancel()
                }
            }

            MenuItem {
                text: qsTr("Add new shop")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("NewShopDialog.qml"));
                }
            }
        }

        delegate: shopDelegate

        Component.onCompleted: {
            //console.log("silicalistview onCompleted")
            shopModel.clear();
            DBA.repopulateShopList(shopModel);
            if (shopFilter.length<1) shopFilter=[wildcard];
            updateListmodelSwitches(shopModel,shopFilter)
            lastselected = wildcard
            changeCount=0
        }

    } //end silicalistview


    Component {
        id: shopDelegate

        ListItem {
            id:shopitem
            Rectangle {
                width: parent.width
                opacity: 90
                height: parent.height-Theme.paddingSmall
                radius: Theme.paddingLarge
                color: "#111111FF"

                Switch {
                    y: -20
                    id: shopsw
                    automaticCheck: false
                    checked: index !=-1 ? shopModel.get(index).checked : false

                    onClicked: {
                        console.log("Switch clicked, index="+index)
                        console.log("clicked:"+model.name+"; switch:"+ shopsw.checked)
                        checked = !checked
                        lastselected = model.name
                        var c = shopModel.get(index).checked
                        console.log("model.checked:"+c)
                        shopModel.get(index).checked = shopsw.checked
                        c = shopModel.get(index).checked
                        console.log("model.checked:"+c)
                        //dumpShopModel(shopModel)

                    }

                }
                TextField {
                    anchors.left: shopsw.right
                    id: shopField
                    //anchors { left: shopsw.right; right: parent.right }
                    text: model.name
                    EnterKey.enabled: true //text || inputMethodComposing
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: {
                        // console.log("ShopPage.qml EnterKey.onClicked")
                        readOnly = true
                    }

                    property int mychanges: 0

                    onTextChanged: {
                        changeCount++
                        mychanges++
                        shopModel.set(index,{"edittext":text}) // store changed value in model
                        // console.log("ShopPage.qml: Text Changed! changeCount:"+ changeCount+" my changes="+mychanges+" currenttext="+text)

                    }
                }
            }
        }
    }

    /**** if there were any changes to the shop names, update them to Database
     *
     */
    function updateShopsToDB() {
        // console.debug("ShopPage: onAccepted");
        // Store changed fields to database
        var oldtext
        var newtext
        for (var i=0; i<shopModel.count;i++) {
            //            console.log(":->"+shopModel.get(i).edittext)
            oldtext = shopModel.get(i).name
            newtext = shopModel.get(i).edittext
            if(newtext != oldtext) {
                // Check if the new shopname <edittext> exist. Disallow making second or replace?
                // UPDATE Shopping list: change shop name from <name> to <edittext>
                // UPDATE Shop list: replace "name" with "edittext"
                DBA.updateShopNameDB(oldtext, newtext)
                DBA.updateShopNameInShoppinglistDB(oldtext,newtext)
                shopModel.get(i).name=newtext
            }
        }
    }

    function doCancel() {
        // console.log("ShopPage: onCanceled");
        changeCount=0
        shopModel.clear()
        DBA.repopulateShopList(shopModel)
        currShop=wildcard
    }


    /** This is meant for shoppingListModel even if lm is a parameter **/
    function updateShopNameInLM(lm, oldname, newname) {
        console.debug("ShopPage.qml to new name:"+newname)
        for (var i=0; i<lm.count; i++ ) {
            if (lm.get(i).ishop==oldname) {
                lm.get(i).ishop=newname
            }
        }
    }

    function setAllSwitches(lm,true_on) {
        console.log("setAllSwitches")
        for (var i = 0; i< lm.count; i++) {
            var r = lm.get(i)
            r.checked = true_on
        }
    }

    function getCheckedSwitches(lm) {
        //console.log("getCheckedSwitches>")
        var arr = []
        var checkedcount=0
        for (var i = 0; i< lm.count; i++) {
            var r = lm.get(i)
            //console.log("checked="+r.checked+" name="+r.name+" edittext="+r.edittext)
            if (r.checked){
                arr.push(r.name)
                checkedcount++
            }
        }
        if (checkedcount==lm.count) {
            shopFilter = [wildcard]
        } else {
            shopFilter = arr;
        }
    }

    function dumpShopFilter() {
        console.log("Current shopFilter>")
        for (var i = 0; i< shopFilter.length; i++) {
            console.log(shopFilter[i])
        }
        console.log("<Current shopFilter")
    }

    function updateListmodelSwitches(lm, names ) {
        // console.log("updateListmodelSwitches")
        // console.log("> names[0]="+names[0])
        if (names[0]==wildcard) {
            for (var i = 0; i< lm.count; i++) {
                var r = lm.get(i)
                r.checked=true
            }
        } else {
            for (var i = 0; i< lm.count; i++) {
                for(var j = 0; j<names.length;j++) {
                    var r = lm.get(i)
                    if (r.name==names[j]) {
                        r.checked=true
                        break
                    }
                }
            }
        }
    }

    function dumpShopModel(lm) {
        console.log("dumpShopModel>")
        for (var i = 0; i< lm.count; i++) {
            var r = lm.get(i)
            console.log("checked="+r.checked+" name="+r.name+" edittext="+r.edittext)

        }
    }

}

