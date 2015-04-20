import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Splash page for splashing the users of the shopping list app
 */
Component {
    Page {
        id:splashpage

        Column {
            id:splashcolumn
            visible: false
            spacing: Theme.paddingLarge

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Ostos")+qsTr("Shopping list")
            }
            Button {
                text: qsTr("Continue")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("FirstPage.qml"));
                }
            }
        }

        Component.onCompleted: {

        }
    }
}
