import QtQuick 2.0
import Sailfish.Silica 1.0


import "../dbaccess.js" as DBA
import "../itemadd.js" as ITEMADD
Dialog {
    id: addDialog

    property string searchString
    //property alias searchField: //searchView.headerItem // needed the particular reference!
    canAccept: (searchListModel.count <= 1)

    onAccepted: ITEMADD.accept()

    //    Loader {
    //        anchors.fill: parent
    //        sourceComponent: searchViewComponent
    //    }

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
            templistmodel.clear()
            DBA.readShoppingListExState(templistmodel,"BUY")
            update()
        }
    } //end searchListModel

    Column {
        id: headerContainer
        width: parent.width
        height: parent.height

        DialogHeader {
            id: dialogHeader

            height: 4 * Theme.paddingLarge
            //            width: parent.width
        }

        Rectangle {
            id: searchBox
            anchors.top: dialogHeader.bottom
            //                    height: 100
            width: parent.width
            anchors.left: parent.left

            SearchField {
                id: searchField
                anchors.top: dialogHeader.bottom
                width: parent.width

                placeholderText: qsTr("Search")

                onTextChanged: {
                    searchListModel.update()
                }
            }
        }
        Item {
            id: searchListBox
            anchors.top: searchBox.bottom
            anchors.bottom: parent.bottom

            SilicaListView {
                id: searchView
                anchors.top: searchBox.bottom
                y: 80
                width: parent.width
                height: parent.height


                model: searchListModel


                // prevent newly added list delegates from stealing focus away from the search field
                currentIndex: -1


                delegate: ListItem {
                    id: slItem
                    Label {
                        height: 30
                        anchors {
                            left: parent.left
                            leftMargin: searchField.textLeftMargin
                            verticalCenter: parent.verticalCenter
                        }
                        text: model.name
                        Button {
                            width: parent.width
                            height: parent.height
                            onClicked: {
                                searchField.text=parent.text
                            }
                        }
                    }
                }


                VerticalScrollDecorator {}
            }
        }
    }

}


