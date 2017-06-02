import QtQuick 2.0
import Sailfish.Silica 1.0

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Dialog page for shop details input in the shopping list app
 */
Dialog {
    property string destPath: "/home/nemo/"
    property string destFile: "ostosShoppingList.csv"

    id: backupDialog
    canAccept: backupnameIsGood()
    onAccepted:  {
        pageStack.pop()
        pageStack.push(Qt.resolvedUrl("FirstPage.qml"));
    }
    SilicaFlickable {
        id: backupFlickable
        anchors.fill: parent
        contentHeight: backupColumn.height
        VerticalScrollDecorator {}

        Column {
            id: backupColumn
            anchors.fill: parent
            spacing: Theme.paddingMedium
            DialogHeader {
                id: dihrd
                title: qsTr("Select backup source and destination files")
                width: parent.width
            }
            Label {
                x: Theme.paddingMedium
                text: "Source database file .sqlite"
            }

            TextField {
                id: sourcedatabasefile
                width: parent.width
                textMargin: Theme.paddingMedium
                placeholderText: qsTr("Source database file path and name")
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            }

            Button {
                id: buttonGoSelectSource
                x: Theme.paddingMedium
                text: qsTr("Browse and change source")
                onClicked: {
                    var cacFileSelect = pageStack.push(Qt.resolvedUrl("CacFileSelect.qml"),
                                                       {
                                                           setRootFolder:"/home/nemo/.local/share/harbour-ostos/harbour-ostos/QML/OfflineStorage/",
                                                           setFolder:"/home/nemo/.local/share/harbour-ostos/harbour-ostos/QML/OfflineStorage/Databases/",
                                                           fileNameFilter:"*.sqlite"
                                                       })
                    cacFileSelect.accepted.connect(function() {
                        sourcedatabasefile.text = cacFileSelect.selectedFileName;
                    })

                }
            }

            TextField {
                id: backuppath
                width: parent.width
                textMargin: Theme.paddingMedium
                placeholderText: qsTr("Backup path")
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            }

            Button {
                id: buttonGoSelectDestination
                x: Theme.paddingMedium
                text: qsTr("Browse and select path to save to")
                onClicked: {
                    var cacFileSelect = pageStack.push(Qt.resolvedUrl("CacFileSelect.qml"),
                                                       {
                                                           setRootFolder:"/",
                                                           setFolder:destPath,
                                                           fileNameFilter:"*.*"
                                                       })
                    cacFileSelect.accepted.connect(function() {
                        backuppath.text = cacFileSelect.selectedFileName;
                    })

                }
            }
            TextField {
                id: backupfilename
                width: parent.width
                textMargin: Theme.paddingMedium
                placeholderText: qsTr("Backup file name .csv")
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            }

            Button {
                id: buttonSetSavePathSdCard
                x: Theme.paddingMedium
                text: qsTr("Set save path to SD card")
                onClicked: {
                    backuppath.text = "/media/sdcard/"
                }
            }
        }
    }
    Component.onCompleted: {
        var DEFAULT_FILENAME = "harbour-ostos-list-backup.txt"
        var DATABASEPATH = "/home/nemo/.local/share/harbour-ostos/harbour-ostos/QML/OfflineStorage/Databases/"
        backupfilename.text = theFilester.saveFileName;
        sourcedatabasefile.text = theFilester.findDataBaseFile(DATABASEPATH);
    }
    function backupnameIsGood() {
        return theFilester.checkIfDirectoryExists(backuppath.txt) &&
                (backupfilename.text.length >4) &&
                !(theFilester.checkIfFileExists(backuppath.text,backupfilename.text))
    }
}
