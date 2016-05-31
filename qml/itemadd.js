/*
  * This code was moved to separate file from qml/pages/ItemAddPage.qml
  * just because onAccepted function was pretty big.
  * HAS DEPENDENCIES TO THE PAGE qml/pages/ItemAddPage.qml and globals
  */
function accept() {
    console.log("itemadd.js:accept()")
    var count = searchListModel.count
    console.log("- searchListModel.count="+searchListModel.count)
    var db_index
    var found_1st_item_name

    if ((count == 1) || ((cherryPicked==true))) {
        // we have found the item already on the list as a unique match, the retrieve it from database and
        // store to global templistmodel variable

        if (cherryPicked==true) {
            found_1st_item_name = searchField.text
        } else {
            found_1st_item_name = searchListModel.get(0).name
        }

        console.log("- found_item_name:"+found_1st_item_name)

        templistmodel.clear()
        db_index = DBA.findItemByName(templistmodel,found_1st_item_name)
        if(db_index) {
            console.log("- ROW:"+templistmodel.get(0).rowid+" STAT:"+templistmodel.get(0).istat+" NAME:"+templistmodel.get(0).iname+" QTY:"+templistmodel.get(0).iqty+
                        "UNIT:"+ templistmodel.get(0).iunit+" CLASS:"+templistmodel.get(0).iclass+" SHOP:"+templistmodel.get(0).ishop)
            if(templistmodel.get(0).istat!="HIDE") { // If the row stat is other than HIDE, it should be found in shoppingList
                for (var i=0; i<shoppingListModel.count; i++){

                    if(shoppingListModel.get(i).iname.toLowerCase()
                            ==found_1st_item_name.toLowerCase()) {
                        ci = i
                        break
                    }
                }
            } else {
                // in case the item stat was HIDE, it must be added to shoppingListModel
                ci=0
                shoppingListModel.insert(ci,{ "istat":"BUY", "iname":templistmodel.get(0).iname, "iqty":templistmodel.get(0).iqty, "iunit":templistmodel.get(0).iunit, "iclass":templistmodel.get(0).iclass, "rowid":parseInt(db_index)});
                currentShop = wildcard
            }
        }
    } else if (count==0) { // Haven't found, will start adding a new item and its details
        ci = shoppingListModel.count
        shoppingListModel.append(
                    { "istat":"BUY",
                        "iname":searchField.text,
                        "iqty":"", "iunit":"", "iclass":"",
                        "ishop":"unassigned",
                        "rowid":parseInt(ci)}) // How come? rowid is the db row id!
        console.log("itemadd.js: added new to model: ci="+ci+": iname="+shoppingListModel.get(ci).iname)

    }

    console.log("* ItemAddPage accepted,\n- searchField.text:"+searchField.text+
                " found_item_name:"+found_1st_item_name+" ci:"+ci)

}

