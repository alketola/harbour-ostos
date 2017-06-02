/*
*
* MIT License
*
* Copyright (c) 2016 codeandcreate
*/
/*
    A simple file/folder selector dialog for sailfish os apps. (developer example)
    How to use:
    ...
    onClicked: {
        var cacFileSelect = pageStack.push(Qt.resolvedUrl("cacFileSelect.qml"), {
            //options (see below)
        })
        cacFileSelect.accepted.connect(function() {
            // just do something with "cacFileSelect.selectedFileName"
        })
    }
    ...
    pageStack.push options:
    setRootFolder, setFolder, setShowHidden
    Further documentation:
    Qt.labs.folderlistmodel => https://doc.qt.io/archives/qt-5.5/qt-labs-folderlistmodel-qmlmodule.html

    example of options (to save you from looking it up):
    { setRootFolder: "/home/nemo/", setShowHidden: true }
*/
/* Changelog:
 - 2.6.2017 added fileNameFilter as property
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import Qt.labs.folderlistmodel 2.1

Dialog {
    id: cac_fileSelect

    property string setRootFolder: '/home/nemo'
    property string setFolder: '/home/nemo'
    property bool setShowHidden: true
    property string selectedFileName: ""
    property string fileNameFilter: "*.*"
    property bool disallowFileSelection: false
    property bool disallowFileExists: false

    FolderListModel {
        id: folderModel
        folder: setFolder
        rootFolder: setRootFolder
        showHidden: setShowHidden
        showDotAndDotDot: true
        showOnlyReadable: true
        nameFilters: [fileNameFilter]
    }

    SilicaListView {
        id: listView
        model: folderModel
        anchors.fill: parent

        header: DialogHeader {
            acceptText: qsTr("Select...")
            cancelText: qsTr("Cancel")
        }

        delegate: ListItem {
            id: item

            Image {
                id: itemIcon
                source: folderModel.isFolder(index) ? "image://theme/icon-m-folder" : "image://theme/icon-m-other"
                height: parent.height -Theme.paddingMedium
                width: height
                anchors.left: parent.left
            }

            Label {
                id: itemName
                text: model.fileName
                color: Theme.primaryColor

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: itemIcon.right
                    right: parent.right
                    margins: Theme.paddingMedium
                }
            }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Select")
                    onClicked: {
                        if (!disallowFileSelection) {
                            selectedFileName = folderModel.folder + "/" + model.fileName
                            cac_fileSelect.accept();
                        } else {
                            console.log("disallowed file selection")
                        }

                    }
                }
            }

            onClicked: {
                if (folderModel.isFolder(index)) {
                    if (fileName == "..") {
                        folderModel.folder = folderModel.parentFolder
                    } else if (fileName != ".") {
                        folderModel.folder += "/" + fileName
                    }
                } else {
                    selectedFileName = folderModel.folder + "/" + model.fileName
                    cac_fileSelect.accept();
                }
            }
        }

        VerticalScrollDecorator {}
    }

    onDone: {
        if (selectedFileName == "") {
            selectedFileName = folderModel.folder;
        }
    }
}
