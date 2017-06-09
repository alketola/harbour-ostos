import QtQuick 2.0
import Sailfish.Silica 1.0

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Dialog page for shop details input in the shopping list app
 */


Dialog {
    property string destPath: theFilester.getStdHomePath()
    property string destFile: "ostosShoppingList"
    property string destFileExtension: ".csv"

    id: backupDialog
    canAccept: backupnameIsGood()
    acceptDestination: pageStack.find(function(page) {
        return page.pagemark==="firstPage";
    });
    acceptDestinationAction: PageStackAction.Pop
    onAccepted:  {
        console.log("onAccepted")
        theFilester.setSaveFileName(backupfilename.text)
        console.log("Saving to "+theFilester.saveFileName)
        theFilester.saveDataBase()
        //pageStack.pop()
        //pageStack.push();
    }

    SilicaFlickable {
        id: backupFlickable
        contentHeight: backupColumn.height
        anchors.fill: parent
        VerticalScrollDecorator{}
        Column {
            id: backupColumn
            spacing: Theme.paddingMedium
            DialogHeader {
                id: dheader
                title: qsTr("Select backup source and destination")
                width: backupFlickable.width
            }
            Label {
                x: Theme.paddingMedium
                text: "Source database file .sqlite:"
            }

            TextField {
                id: sourcedatabasefile
                width: parent.width
                textMargin: Theme.paddingMedium
                autoScrollEnabled: true
                placeholderText: qsTr("Source database file path and name")
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: backuppath.focus = true
            }

            Button {
                id: buttonGoSelectSource
                x: Theme.paddingMedium
                text: qsTr("Browse and change source")
                onClicked: {
                    var cacFileSelect = pageStack.push(Qt.resolvedUrl("CacFileSelect.qml"),
                                                       {
                                                           setRootFolder: theFilester.getRootPath(),
                                                           setFolder:theFilester.getStdDataPath() + "QML"+"/"+"OfflineStorage"+"/"+"Databases"+"/",
                                                           fileNameFilter:"*.sqlite"
                                                       })
                    cacFileSelect.accepted.connect(function() {
                        sourcedatabasefile.text = cacFileSelect.selectedFileName;
                    })

                }
            }
            Label {
                x: Theme.paddingMedium
                text: qsTr("Destination path:")
            }

            TextField {
                id: backuppath
                width: parent.width
                textMargin: Theme.paddingMedium
                autoScrollEnabled: true
                placeholderText: qsTr("Save to path")
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
                                                           //setRootFolder:"/",
                                                           setFolder:destPath,
                                                           fileNameFilter:"*.*"
                                                       })
                    cacFileSelect.accepted.connect(function() {
                        backuppath.text = cacFileSelect.selectedFileName;
                    })

                }
            }
            Label {
                x: Theme.paddingMedium
                text: qsTr("Destination file:")
            }
            TextField {
                id: backupfilename
                width: parent.width
                textMargin: Theme.paddingMedium
                autoScrollEnabled: true
                placeholderText: qsTr("Save to file name .csv")
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            }

//            Button {
//                id: buttonSetSavePathSdCard
//                x: Theme.paddingMedium

//                text: qsTr("Set save path to SD card")
//                onClicked: {
//                    backuppath.text = "/"+"media"+"/"+"sdcard"+"/"
//                }
//            }
        }
    }

    Component.onCompleted: {
        var DEFAULT_FILENAME = "harbour-ostos-list-backup.txt"
        var DATABASEPATH = theFilester.getStdDataPath() + "QML"+"/"+"OfflineStorage"+"/"+"Databases"+"/"
        backupfilename.text = theFilester.saveFileName
        sourcedatabasefile.text = theFilester.findDataBaseFile(DATABASEPATH)
        backuppath.text = destPath
        makeBackupNameUnique()
    }

    function makeBackupNameUnique() {
        var uniquifier = ""
        var i = 0
        while(theFilester.checkIfFileExists(backuppath.text,destFile + uniquifier + destFileExtension)){
            i = i + 1
            uniquifier = "_"+i
        }
        backupfilename.text = destFile + uniquifier + destFileExtension

    }

    function backupnameIsGood() {
        return theFilester.checkIfDirectoryExists(backuppath.txt) &&
                (backupfilename.text.length >4) &&
                !(theFilester.checkIfFileExists(backuppath.text,backupfilename.text))
    }
}
