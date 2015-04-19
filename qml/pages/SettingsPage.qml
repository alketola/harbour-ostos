import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Setting page for settings of the shopping list app
 */

Page {
    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted


    SilicaFlickable {
        anchors.fill: parent
        contentHeight: settingsColumn.height

        VerticalScrollDecorator { }

        Column {
            id: settingsColumn
            width: parent.width
            PageHeader {
                title: qsTr("Settings")
            }

            TextSwitch {
                id: splashDisable
                automaticCheck: false
                text: qsTr("Splash screen disabled")
                onClicked: {
                    checked=!checked;
                    console.log("splashDisableChanged checked="+checked);
                    DBA.setSetting("general-splash-disable",checked);

                }
            }

            Component.onCompleted: {
                try {
                    var d=DBA.getSetting("general-splash-disable");
                    console.log("SettingsPage.qml: d:"+d);
                    if(d!='true') {
                        console.log("false");
                        splashDisable.checked=false;
                    } else {
                        splashDisable.checked=true;
                    }
                } catch (err) {
                    console.log("splashDisable error="+err);
                }
            }
        }
    }
}
