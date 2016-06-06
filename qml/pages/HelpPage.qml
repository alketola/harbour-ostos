import QtQuick 2.2
import Sailfish.Silica 1.0

/*
 * Copyright Antti Ketola 2016
 * License: GPL V3
 *
 * Help page of the shopping list app
 */
Page {
    SilicaWebView {
        id: webView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom //urlField.top //
            margins: Theme.paddingLarge
        }
        url: "file:./ostoshelp.html"

        onUrlChanged: {
            console.log("Help Page.qml: URL changed")
        }
    }

//    TextField {
//        id: urlField
//        anchors {
//            left: parent.left
//            right: parent.right
//            bottom: parent.bottom
//        }
//        inputMethodHints: Qt.ImhUrlCharactersOnly
//        text: "file:./ostoshelp.html"
//        label: webView.title
//        EnterKey.onClicked: {
//            webView.url = text
//            parent.focus = true
//        }
//    }
}
