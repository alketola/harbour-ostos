import QtQuick 2.0
import Sailfish.Silica 1.0


import "../dbaccess.js" as DBA
import "../itemadd.js" as ITEMADD
Dialog {
    id: addDialog

    property string searchString
    //property alias searchField: //searchView.headerItem // needed the particular reference!
    property bool acceptClicked

    canAccept: ((searchListModel.count <= 1) || acceptClicked == true)

    onAccepted: ITEMADD.accept()

    ListModel {
        id: searchListModel

        function update() {
            var s
            var stat
            clear()
            console.log("templistmodel.count="+templistmodel.count)
            for (var i=0; i<templistmodel.count; i++) {
                s = templistmodel.get(i).iname
                stat= templistmodel.get(i).istat
                //console.log("ItemAddPage.searchListModel.update.s:"+s)
                if (s.toLowerCase().indexOf(searchField.text.toLowerCase()) >= 0 ) {
                    append({"name":s})
                }
            }
        }

        Component.onCompleted: {
            acceptClicked=false
            templistmodel.clear()
            DBA.readShoppingListExState(templistmodel,"BUY")
            update()
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
                        acceptClicked = false
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
                    //                    Label {
                    //                        height: 30
                    //                        anchors {
                    //                            left: parent.left
                    //
                    //                        }
                    // text: model.name


                    Button { // words decorated as buttons
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
                            searchField.text=parent.text
                            acceptClicked=true
                        }
                    }
                }
            }
        }
    }
}





