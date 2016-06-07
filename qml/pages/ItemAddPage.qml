import QtQuick 2.0
import Sailfish.Silica 1.0


import "../dbaccess.js" as DBA
import "../itemadd.js" as ITEMADD
Dialog {
    id: addDialog

    property string searchString
    //property alias searchFld: addDialog.searchField //searchView.headerItem // needed the particular reference!
    property bool cherryPicked

    canAccept: ((searchListModel.count <= 1) || addDialog.cherryPicked == true)
    acceptDestination: Qt.resolvedUrl("ItemEditPage.qml")
    //    acceptDestinationAction: PageStackAction.Push
    backNavigation: true
    forwardNavigation: true

    ListModel {
        id: acceptlm
    }

    onAccepted: {
        ITEMADD.accept()
        console.debug("ItemAddPage.qml onAccepted, about to push ItemEditPage.qml")
    }

    onStatusChanged: {
        if(addDialog.status == PageStatus.Active) {
//            console.log("****ItemAddPage.qml Dialog.onStatusChanged, status="+status)
            cherryPicked = false
            templistmodel.clear()
//            console.log("**** loading templistmodel")
            DBA.readShoppingListExState(templistmodel,"BUY")
            searchListModel.update()
        }
    }    

    ListModel {
        id: searchListModel

        function update() {
            var s
            var stat
            clear()
            for (var i=0; i<templistmodel.count; i++) {
                s = templistmodel.get(i).iname
                stat= templistmodel.get(i).istat
                //                console.log("ItemAddPage.searchListModel.update.s:"+s)
                if (s.toLowerCase().indexOf(searchField.text.toLowerCase()) >= 0 ) {
                    append({"name":s})
                }
            }
            //            console.log("ItemAddPage: searchListModel.count="+searchListModel.count)
        }
    } //end searchListModel


    SilicaFlickable {
        id: theFlickable
        anchors.fill: parent
        contentHeight: theColumn.height

        Column {
            id: theColumn
            anchors.fill: parent

            DialogHeader {

                id: dialogHeader

                anchors.left: parent.left   // The Must-Have anchors
                anchors.right: parent.right
            }

            Item {
                id: searchItem
                anchors.left: parent.left // The Must-Have anchors
                anchors.right: parent.right
                height: Theme.itemSizeSmall // The Must-Have height

                SearchField {
                    id: searchField
                    anchors.fill: parent
                    placeholderText: qsTr("Search")

                    onTextChanged: {
                        searchListModel.update()
                        cherryPicked = false
                    }
                }
            }

            VerticalScrollDecorator { flickable: theFlickable }

            SilicaListView {
                id: searchView
                width: parent.width
                // The height must be calculated sor SilicaListView and
                // Scrolldecorator to work in Flickable!
                height: addDialog.height - dialogHeader.height - searchItem.height
                clip: true
                model: searchListModel

                // prevent newly added list delegates from stealing focus away from the search field
                currentIndex: -1

                delegate: ListItem {
                    id: slItem

                    Button { // words decorated as buttons
                        id: btn
                        width: sLabel.width + 2 * Theme.paddingLarge
                        anchors.margins: Theme.paddingLarge
                        x: searchField.textLeftMargin
                        height: sLabel.height + 2 * Theme.paddingSmall
                        Label{
                            id: sLabel
                            text: model.name
                            x: Theme.paddingLarge
                            y: Theme.paddingSmall
                        }

                        onClicked: {
                            searchField.text=sLabel.text
                            addDialog.cherryPicked=true
                        }
                    }
                }
            }
        }
    }
}





