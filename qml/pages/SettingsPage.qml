import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA
import "../pages"

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
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Settings")
            }
            // This was an attempt to read in Settings from database. There aren't any, currently
            //            TextSwitch {
            //                id: splashDisable
            //                automaticCheck: false
            //                text: qsTr("Splash screen disabled")
            //                onClicked: {
            //                    checked=!checked;
            //                    console.log("splashDisableChanged checked="+checked);
            //                    DBA.setSetting("general-splash-disable",checked);

            //                }
            //            }

            Slider {
                id: refreshslider
                width: parent.width
                minimumValue: 100
                maximumValue: 5000

                value: ((appWindow.refreshInterval >= minimumValue) && (appWindow.refreshInterval<=maximumValue))? appWindow.refreshInterval : 1250

                label: qsTr("List refresh interval")
                valueText: Math.ceil(value) + " ms"
                onValueChanged: {
                    appWindow.setRefreshInterval(value)
                }

            }
            Label {
                width: parent.width
                height: Theme.itemSizeSmall
                horizontalAlignment: Text.AlignHCenter
                truncationMode: TruncationMode.Fade
                text: "Current locale = "+ (Qt.locale().name.substring(0,2))
            }

            Label {
                width: parent.width
                height: Theme.itemSizeSmall*2
                truncationMode: TruncationMode.Fade
                horizontalAlignment: Text.AlignHCenter
                text: "Original version written by\nAntti L S Ketola"
            }
            Label {
                width: parent.width
                height: Theme.itemSizeSmall
                truncationMode: TruncationMode.Fade
                horizontalAlignment: Text.AlignHCenter
                text: "Copyright Antti Ketola 2016"
            }
            Label {
                width: parent.width
                height: Theme.itemSizesmall * 4
                horizontalAlignment: Text.AlignHCenter
                truncationMode: TruncationMode.Fade
                text: "Translations:\n"+
                      "en: Antti Ketola\n"+
                      "fi: Antti Ketola\n"+
                      "es: Antti Ketola (proofreading needed)\n"+
                      "de: Antti Ketola (proofreading needed)"
            }
            Label {
                id: versionLabel
                width: parent.width
                height: Theme.itemSizeMedium
                truncationMode: TruncationMode.Fade
                horizontalAlignment: Text.AlignHCenter
                text: "Version "+"v0.98"
            }

            Component.onCompleted: {
                // This was an attempt to read in Settings from database. There aren't any, currently
                //                try {
                //                    var d=DBA.getSetting("general-splash-disable");
                //                    console.log("SettingsPage.qml: d:"+d);
                //                    if(d!='true') {
                //                        console.log("false");
                //                        splashDisable.checked=false;
                //                    } else {
                //                        splashDisable.checked=true;
                //                    }
                //                } catch (err) {
                //                    console.log("splashDisable error="+err);
                //                }
            }
        }
    }
}
