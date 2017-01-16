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
    id: settingsPage

    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted

    SilicaFlickable {
        id: settingsFlickable
        anchors.fill: parent
        contentHeight: settingsColumn.height

        VerticalScrollDecorator { }

        PullDownMenu {
            id: settingsPullDown
            //            MenuItem {
            //                text: qsTr("Import database data")
            //            }
            //            MenuItem {
            //                text: qsTr("Export database data")
            //            }

            MenuItem {
                text: qsTr("DELETE DATABASE TABLES")
                onClicked: {
                    databaseTableDropRemorse.execute(qsTr("DELETING ALL DATA"),
                                                     function(){
                                                         console.log("Deleting Database tables...");
                                                         DBA.deleteDatabase();
                                                         console.log("...deleted.");
                                                         Qt.quit(); // a must for proper initialization if using the app again
                                                     },10000)

                }
            }
        }
        RemorsePopup { id: databaseTableDropRemorse }

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
                minimumValue: appWindow.minRefreshInterval
                maximumValue: appWindow.maxRefreshInterval

                value: appWindow.setting_refreshInterval

                label: qsTr("List refresh interval")
                valueText: Math.ceil(value) + " ms"
                onValueChanged: {
                    appWindow.setRefreshInterval(value)
                }

            }
            TextSwitch {
                id: extHelpEna
                text: qsTr("Enable WWW help")
                description: qsTr("Enable Help file read from Web and use of Google translator for unknown languages")
                checked: appWindow.setting_webHelpEnabled

                onClicked: {
                    appWindow.setting_webHelpEnabled = !appWindow.setting_webHelpEnabled
                }
            }

            TextSwitch {
                id: shopFilterAutoResetEna
                text: qsTr("Enable Class Section Headings in the Shoppinglist")
                checked: appWindow.setting_sectionHeadersEnabled

                onClicked: {
                    appWindow.setting_sectionHeadersEnabled = !appWindow.setting_sectionHeadersEnabled
                }
            }

//            TextSwitch {
//                id: shopFilterAutoResetEna
//                text: qsTr("Enable That Shop Filter Returnss to *")
//                checked: appWindow.shopFilterAutoResetEnabled

//                onClicked: {
//                    appWindow.shopFilterAutoResetEnabled
//                }
//            }

            Label {
                width: parent.width
                height: Theme.itemSizeSmall
                horizontalAlignment: Text.AlignHCenter

                text: "Current locale = "+ (Qt.locale().name.substring(0,2))
            }

            Label {
                width: parent.width
                height: Theme.itemSizeSmall*2
                horizontalAlignment: Text.AlignHCenter

                text: "Original version written by\nAntti L S Ketola"
            }
            Label {
                width: parent.width
                height: Theme.itemSizeSmall
                horizontalAlignment: Text.AlignHCenter

                text: "Copyright Antti Ketola 2016"
            }
            Label {
                width: parent.width
                height: Theme.itemSizesmall * 4
                horizontalAlignment: Text.AlignHCenter

                text: "Translations:\n"+
                      "en: Antti Ketola\n"+
                      "fi: Antti Ketola\n"+
                      "sv: Åke Engelbrektson\n"+
                      "es: Antti Ketola (proofreading needed)\n"+
                      "de: ntp22"
            }
            Label {
                id: versionLabel
                width: parent.width
                height: Theme.itemSizeMedium
                //                truncationMode: TruncationMode.Fade
                horizontalAlignment: Text.AlignHCenter
                text: "Version "+"v1.07-alpha"

            }

            Component.onCompleted: {
                readSettings()
                // This was an unwrapped way to read in Settings from database.
//                try {
//                    var d=new String(DBA.getSetting("refresh-delay"))
//                    console.log("SettingsPage.qml: refresh-delay:"+d)
//                    if(DBA.NO_SETTING === d) {
//                        console.log("no refresh delay found in database")
//                        appWindow.setRefreshInterval(0)
//                    } else {
//                        appWindow.setRefreshInterval(d.valueOf())
//                        console.log("Refresh delay "+d+" found in database:"+d.valueOf());
//                    }
//                } catch (err) {
//                    console.log("refresh-delay read seting error="+err);
//                }
//                var h = new String(DBA.getSetting("section-headers-enable"))
//                if(DBA.NO_SETTING === h) {
//                    appWindow.setting_sectionHeadersEnabled = h.valueOf()
//                    console.log("setting section-headers-enable set to"+appWindow.setting_sectionHeadersEnabled)
//                }

            }
        }
    }
    onStatusChanged: {
        if (status==0){
            console.log("SettingsPage.qml Page.onStatusChanged to:"+status);
            writeSettings()
        }
    }    
}
