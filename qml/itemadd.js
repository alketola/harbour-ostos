/*
  * This code was moved to separate file from qml/pages/ItemAddPage.qml
  * just because onAccepted function was pretty big.
  * HAS DEPENDENCIES TO THE PAGE qml/pages/ItemAddPage.qml and globals
  */
function doadd() {
    // // console.log("itemadd.js:accept()")
    var count = searchListModel.count
    var db_index
    // console.log("- searchListModel.count="+searchListModel.count)    
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

        addinglm.clear()
        db_index = DBA.findItemByName(addinglm,found_1st_item_name)
        if(db_index) {
            // console.log("- ROW:"+acceptlm.get(0).rowid+" STAT:"+acceptlm.get(0).istat+" NAME:"+acceptlm.get(0).iname+" QTY:"+acceptlm.get(0).iqty+
            //            "UNIT:"+ acceptlm.get(0).iunit+" CLASS:"+acceptlm.get(0).iclass+" SHOP:"+acceptlm.get(0).ishop)
            if(addinglm.get(0).istat!="HIDE") { // If the row stat is other than HIDE, it should be found in shoppingList
                var found_in_shoppinglistmodel = false
                var nm=""
                for (var i=0; i<shoppingListModel.count; i++){
                    nm = shoppingListModel.get(i).iname.toLowerCase()
                    if(nm===found_1st_item_name.toLowerCase()) {
                        currIndex = i
                        found_in_shoppinglistmodel = true
                        break
                    }
                }
                if (!found_in_shoppinglistmodel) {
                    console.log("Curious,"+found_1st_item_name+" not found in shoppingListModel")
                    insertttoslbeginning(db_index)
                }
            } else {
                // in case the item stat was HIDE, it must be added to shoppingListModel
                insertttoslbeginning(db_index)

            }
        } else {
            console.log("Curious,"+found_1st_item_name+" not found in DB even it has db_index")
        }
    } else if (count==0) { // Haven't found, will start adding a new item and its details
        currIndex = shoppingListModel.count
        shoppingListModel.append(
                    { "istat":"BUY",
                        "iname":searchField.text,
                        "iqty":"", "iunit":"", "iclass":"",
                        "ishop":unknownShopString,
                        "rowid":parseInt(currIndex)}) // How come? rowid is the db row id!
        // console.log("itemadd.js: added new to model: ci="+currIndex+": iname="+shoppingListModel.get(currIndex).iname)

    }

    // console.log("* ItemAddPage accepted,\n- searchField.text:"+searchField.text+
    //            " found_item_name:"+found_1st_item_name+" ci:"+currIndex)

}

function insertttoslbeginning(db_index) {
    var beginning = 0
    shoppingListModel.insert(beginning,{ "istat":"BUY", "iname":addinglm.get(0).iname, "iqty":addinglm.get(0).iqty, "iunit":addinglm.get(0).iunit, "iclass":addinglm.get(0).iclass, "rowid":parseInt(db_index)});
    currShop = wildcard
    shopFilter = [wildcard]
    currIndex=0
}

