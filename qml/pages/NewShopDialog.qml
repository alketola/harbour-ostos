import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Dialog page for shop details input in the shopping list app
 */
Dialog {
    id: newShopDialog
    canAccept: shopnameIsGood()
    onAccepted:  {
        DBA.addShop(newShopName.text);
        DBA.repopulateShopList(shopModel);
        pageStack.pop()
        pageStack.push(Qt.resolvedUrl("FirstPage.qml"));
    }
    Column {
        DialogHeader {
            title: qsTr("Add new shop")
            width: newShopDialog.width
        }

        TextField {
            id: newShopName
            width: 480
            placeholderText: qsTr("Shop name")
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
        }
    }

    function shopnameIsGood() {
        return (newShopName.text.length >1) ? true : false
    }
}
