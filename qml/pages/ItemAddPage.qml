import QtQuick 2.2
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA
Dialog {
    id: addDialog
    property alias searchField: searchView.headerItem // needed the particular reference!
    canAccept: (searchListModel.count <= 1)

    onAccepted: {
        var count = searchListModel.count
        var db_index
        if ( count == 1) {
            // we have found the item already on the list as unique, the retrieve it from database and
            // store to global templistmodel variable
            db_index = DBA.findItemByName(templistmodel,searchField.text)
            if(db_index) {
                console.log("ROW:"+templistmodel.get(0).rowid+" STAT:"+templistmodel.get(0).istat+" NAME:"+templistmodel.get(0).iname+" QTY:"+templistmodel.get(0).iqty+
                            "UNIT:"+ templistmodel.get(0).iunit+" CLASS:"+templistmodel.get(0).iclass+" SHOP:"+templistmodel.get(0).ishop)
                for (var i=0; i<shoppingListModel.count; i++){

                    if(shoppingListModel.get(i).iname.toLowerCase()
                            ==searchField.text.toLowerCase()) {
                        ci = i
                        break
                    }
                }
                pageStack.push(Qt.resolvedUrl("ItemEditPage.qml"))
            }
        } else if (count==0) { // Haven't found, will start adding a new item and its details
            ci = shoppingListModel.count
            shoppingListModel.append(
                        { "istat":"BUY",
                            "iname":searchField.text,
                            "iqty":"", "iunit":"", "iclass":"",
                            "ishop":"unassigned",
                            "rowid":parseInt(ci)})
            console.log("ci="+ci+": iname="+shoppingListModel.get(ci).iname)
            pageStack.push(Qt.resolvedUrl("ItemEditPage.qml"))
        }
    }


    ListModel {
        id: searchListModel

        function update() {
            var s
            var stat
            clear()
            templistmodel.clear()
            DBA.readShoppingListExState(templistmodel,"BUY")
            console.log("templistmodel.count="+templistmodel.count)
            for (var i=0; i<templistmodel.count; i++) {
                s = templistmodel.get(i).iname
                stat= templistmodel.get(i).istat
                //  console.log("ItemAddPage.searchListModel.update.s:"+s)
                if (s.toLowerCase().indexOf(searchField.text.toLowerCase()) >= 0 ) {
                    append({"name":s})
                }
            }
        }
        Component.onCompleted: {
            update()
        }
    } //end searchListModel



    SilicaListView {

        id: searchView
        anchors.fill: parent

        header: SearchField {
            id: searchField
            width: parent.width - 4 * Theme.paddingLarge
            placeholderText: qsTr("Search")

            onTextChanged: {
                searchListModel.update()
            }
        }


        // prevent newly added list delegates from stealing focus away from the search field
        currentIndex: -1

        model: searchListModel

        delegate: ListItem {

            Label {
                anchors {
                    left: parent.left
                    leftMargin: searchField.textLeftMargin
                    verticalCenter: parent.verticalCenter
                }
                text: name
                Button {
                    width: parent.width
                    height: parent.height
                    onClicked: {
                        searchField.text=parent.text
                    }
                }
            }
        }

    }
}
