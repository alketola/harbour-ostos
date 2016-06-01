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
        // store to global acceptlm variable

        if (cherryPicked==true) {
            found_1st_item_name = searchField.text
        } else {
            found_1st_item_name = searchListModel.get(0).name
        }

        console.log("- found_item_name:"+found_1st_item_name)

        acceptlm.clear()
        db_index = DBA.findItemByName(acceptlm,found_1st_item_name)
        if(db_index) {
            console.log("- ROW:"+acceptlm.get(0).rowid+" STAT:"+acceptlm.get(0).istat+" NAME:"+acceptlm.get(0).iname+" QTY:"+acceptlm.get(0).iqty+
                        "UNIT:"+ acceptlm.get(0).iunit+" CLASS:"+acceptlm.get(0).iclass+" SHOP:"+acceptlm.get(0).ishop)
            if(acceptlm.get(0).istat!="HIDE") { // If the row stat is other than HIDE, it should be found in shoppingList
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
                shoppingListModel.insert(ci,{ "istat":"BUY", "iname":acceptlm.get(0).iname, "iqty":acceptlm.get(0).iqty, "iunit":acceptlm.get(0).iunit, "iclass":acceptlm.get(0).iclass, "rowid":parseInt(db_index)});
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

