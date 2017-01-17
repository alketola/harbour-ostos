.pragma library
.import QtQuick.LocalStorage 2.0 as LS
/* External variable references to be noted:
 * Qt Quick: ListModel shopListModel, declared in ApplicationWindow page
 */
/**
 * FYI:
 * On the device, the database is located in
 *
 * /home/nemo/.local/share/harbour-ostos/harbour-ostos/QML/OfflineStorage/Databases/<somelonghexnumber>.sqlite
 */

var unknownShop = "?"

/*
 * Opens Qt/QML Local Storage database
 */
function openDB() {
    return LS.LocalStorage.openDatabaseSync("ShopListDB", "1.1", "Shopping list database", 100000);
}

var NO_SETTING = new String("____NO_SETTING____");

/**
 * Escapes string so that special characters are preceded by backslash.
 *
 * The user may not introduce Special Characters as plain to SQLITE database
 * because it may cause database corruption or other problems
 */
function escapeForSqlite(s){
    if (!s) return ""
    if (s==unknownShop) return unknownShop
    var t=s.toString()
    var regex = /["'.*+?^${}()|[\]\\]/g
    var sub = '\\$&'
    t=t.replace(regex, sub)
    return t
}

/**
 * Unescapes string i.e. removes all backslashes - reverts the change made by
 * escapeForSqlite()
 */
function unescapeFromSqlite(s){
    if (!s) return ""
    var t=s.toString()
    var regex = /\\/g
    var k = t.replace(regex, "")
    return k
}

/*
  Creates our SQLite tables if they do not exists
  */
function initDatabase() {
    // console.log("harbour-ostos/dbaccess.js initDatabase().")
    var db = openDB()
    try {
        db.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS shoppinglist (istat TEXT, iname TEXT PRIMARY KEY NOT NULL, iqty TEXT, iunit TEXT, iclass TEXT, ishop TEXT, hits INTEGER, seq INTEGER, control INTEGER);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS shops (name TEXT PRIMARY KEY NOT NULL, hits INTEGER, seq INTEGER, control INTEGER);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings (setting TEXT(16) PRIMARY KEY, value TEXT(64));');
            tx.executeSql("INSERT OR IGNORE INTO shops (name, hits, seq) VALUES (?,?,?);", [unknownShop, 0, 0]);
        })
    } catch (sqlErr) {
        console.warn("ostos/dbaccess.js:"+sqlErr)
        // do nothing with it
    } finally {
        // console.log("harbour-ostos/dbaccess.js initDatabase() finally ended.")
    }
}

function deleteDatabase() {
    var db = openDB()
    try {
        db.transaction( function(tx) {
            tx.executeSql('DROP TABLE IF EXISTS shoppinglist;')
        })
    } catch (sqlErr) {
        console.warn("ostos/dbaccess.js: deletDatabase: drop shoppinglist "+sqlErr)
        // do nothing with it
    }

    try {
        db.transaction( function(tx) {
            tx.executeSql('DROP TABLE IF EXISTS shops;')
        })
    } catch (sqlErr) {
        console.warn("ostos/dbaccess.js: deletDatabase: drop shops:"+sqlErr)
        // do nothing with it
    }

    try {
        db.transaction( function(tx) {
            tx.executeSql('DROP TABLE IF EXISTS settings;')
        })
    } catch (sqlErr) {
        console.warn("ostos/dbaccess.js: deletDatabase drop settings:"+sqlErr)
        // do nothing with it
    }
    console.log("Ostos.dbaccess.js: deleted database tables")
}

/* by states */
/*
 * Reads all shopping list items and writes them to shopping list model
 * but only those which are not in excluded_state (e.g. "BUY")
 */
function readShoppingListExState(lm,excluded_state) {
    //    console.debug("ostos/dbaccess.js: readTheListExState:"+excluded_state);
    excluded_state=escapeForSqlite(excluded_state)
    var db = openDB()
    if(!db) { console.error("readTheListExState:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist WHERE NOT istat=? ORDER BY istat ASC, seq DESC, iname ASC;', excluded_state)
        })
    } catch (sqlErr) {
        return "SQL:"+sqlErr
    }
    var irid = 0
    var istat = ""
    var iname = ""
    var iqty = ""
    var iunit = ""
    var iclass = ""
    var ishop = ""
    for(var i = 0; i < rs.rows.length; i++) {
        irid = rs.rows.item(i).rowid
        istat = rs.rows.item(i).istat
        iname = unescapeFromSqlite(rs.rows.item(i).iname)
        iqty = unescapeFromSqlite(rs.rows.item(i).iqty)
        iclass = unescapeFromSqlite(rs.rows.item(i).iclass)
        iunit = unescapeFromSqlite(rs.rows.item(i).iunit)
        ishop = unescapeFromSqlite(rs.rows.item(i).ishop)
        //        console.debug("DBREAD-S:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
        lm.append({ //rs.rows.item(i).
                      "istat":istat,
                      "iname":iname,
                      "iqty":iqty,
                      "iunit":iunit,
                      "ishop":ishop,
                      "iclass":iclass,
                      "rowid":irid
                  });
    }

}

/** read shopping list as filtered by filter array */

function readShoppingListFiltered(lm,excluded_state,filterarray,classordering) {// shoppingListModel,"HIDE",shopFilter
    //    console.debug("ostos/dbaccess.js: readTheListExState:"+excluded_state);
    excluded_state=escapeForSqlite(excluded_state)
    var shopfilterstring = buildshopfilter(filterarray)
    var db = openDB()
    if(!db) { console.error("readTheListExState:db open failed"); return; }
    var querystring = 'SELECT rowid, * FROM shoppinglist WHERE NOT istat=\"'+excluded_state+'\" '+shopfilterstring+' ORDER BY istat ASC,'
    if (classordering) querystring += ' iclass ASC,'
    querystring += ' seq DESC, iname ASC  ;'
    //console.debug("querystring="+querystring)
    var rs
    try {
        db.transaction( function(tx) {
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql(querystring)
        })
    } catch (sqlErr) {
        console.log(sqlErr)
        return "SQL:"+sqlErr
    }
    var irid = 0
    var istat = ""
    var iname = ""
    var iqty = ""
    var iunit = ""
    var iclass = ""
    var ishop = ""
    console.log("readShoppingListFiltered, number of rows="+rs.rows.length)
    for(var i = 0; i < rs.rows.length; i++) {
        irid = rs.rows.item(i).rowid
        istat = rs.rows.item(i).istat
        iname = unescapeFromSqlite(rs.rows.item(i).iname)
        iqty = unescapeFromSqlite(rs.rows.item(i).iqty)
        iclass = unescapeFromSqlite(rs.rows.item(i).iclass)
        iunit = unescapeFromSqlite(rs.rows.item(i).iunit)
        ishop = unescapeFromSqlite(rs.rows.item(i).ishop)
        //console.debug("DBREAD-S:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
        lm.append({ //rs.rows.item(i).
                      "istat":istat,
                      "iname":iname,
                      "iqty":iqty,
                      "iunit":iunit,
                      "ishop":ishop,
                      "iclass":iclass,
                      "rowid":irid
                  });
    }

}

function buildshopfilter(filterarray) {
    if (filterarray.length<1 || filterarray[0]==="*") return ""
    var fieldname="ishop="
    var space=" "
    var oor =" OR "
    var fstr = " AND "
    var ss
    for (var i=0;i<filterarray.length;i++) {
        ss = filterarray[i]
        fstr += space + fieldname + dq(ss)
        if (i<(filterarray.length-1)) {
            fstr += oor
        }
    }
    fstr += space
    //console.log("<fstr=>"+fstr+"<")
    return fstr
}

/*
 * Reads all shopping list items and writes them to shopping list model
 * but only those which are in mystate (e.g. "BUY")
 */
function readShoppingListByState(lm, mystate) {
    //    console.debug("ostos/dbaccess.js: readShoppingListByState:"+mystate);
    mystate=escapeForSqlite(mystate)
    var db = openDB()
    if(!db) { console.error("readTheListExState:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist WHERE istat=? ORDER BY istat ASC, seq DESC, iname ASC;', mystate)
        })
    } catch (sqlErr) {
        return "SQL:"+sqlErr
    }
    var irid = 0
    var istat = ""
    var iname = ""
    var iqty = ""
    var iunit = ""
    var iclass = ""
    var ishop = ""
    for(var i = 0; i < rs.rows.length; i++) {
        irid = rs.rows.item(i).rowid
        istat = rs.rows.item(i).istat
        iname = unescapeFromSqlite(rs.rows.item(i).iname)
        iqty = unescapeFromSqlite(rs.rows.item(i).iqty)
        iclass = unescapeFromSqlite(rs.rows.item(i).iclass)
        iunit = unescapeFromSqlite(rs.rows.item(i).iunit)
        ishop = unescapeFromSqlite(rs.rows.item(i).ishop)
        //        console.debug("DBREAD-State:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
        lm.append({ //rs.rows.item(i).
                      "istat":istat,
                      "iname":iname,
                      "iqty":iqty,
                      "iunit":iunit,
                      "ishop":ishop,
                      "iclass":iclass,
                      "rowid":irid
                  });
    }
}

/*
 * Reads all shopping list items and writes them to shopping list model
 * but only for a certain shop
 */
function readShoppingListByShopExState(lm,shopname,excluded_state) {
    //    console.debug("ostos/dbaccess.js: readShoppingListByShop:"+shopname+", ex:"+excluded_state);
    shopname=dq(escapeForSqlite(shopname))
    excluded_state=dq(escapeForSqlite(excluded_state))
    var db = openDB()
    if(!db) { console.error("readAllByShop:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            var querystring = "SELECT rowid, * FROM shoppinglist WHERE ishop="+shopname+" AND NOT istat="+excluded_state+" ORDER BY istat ASC, seq DESC, iname ASC;"
            //print (querystring)
            rs = tx.executeSql(querystring)
        })
    } catch (sqlErr) {
        console.error("readShoppingListByShopExState SQL error:"+sqlErr)
        return false
    }
    var irid = 0
    var istat = ""
    var iname = ""
    var iqty = ""
    var iunit = ""
    var iclass = ""
    var ishop = ""
    //    console.debug("..read "+rs.rows.length+" lines from DB")
    for(var i = 0; i < rs.rows.length; i++) {
        irid = rs.rows.item(i).rowid
        istat = rs.rows.item(i).istat
        iname = unescapeFromSqlite(rs.rows.item(i).iname)
        iqty = unescapeFromSqlite(rs.rows.item(i).iqty)
        iclass = unescapeFromSqlite(rs.rows.item(i).iclass)
        iunit = unescapeFromSqlite(rs.rows.item(i).iunit)
        ishop = unescapeFromSqlite(rs.rows.item(i).ishop)
        //console.debug("...DBREAD-SX:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
        lm.append({ //rs.rows.item(i).
                      "istat":istat,
                      "iname":iname,
                      "iqty":iqty,
                      "iunit":iunit,
                      "ishop":ishop,
                      "iclass":iclass,
                      "rowid":irid
                  });
    }
    hitShop(ishop)

}


/*
 * Changes all items in database which are in 'oldstate' to 'newstate'
 * Purpose: to facilitate state change from GOT to HIDE (in first page pulldown menu)
 */

function bulkStateChange(listmodel,oldstate,newstate) {
    newstate=escapeForSqlite(newstate)
    oldstate=escapeForSqlite(oldstate)
    var db = openDB()
    if(!db) { /* console.error("writeItem:db open failed"); */ return; }

    var result
    var lastrow=0

    db.transaction(function(tx) {
        tx.executeSql("UPDATE OR REPLACE shoppinglist SET istat=? WHERE istat=?;",
                      [newstate, oldstate])
    })

    return
}

/**
 * Inserts a new item to shopping list, and returns database row id (TEXT)
 */
function insertItemToShoppingList(istat, iname, iqty, iunit, iclass, ishop) {
    iname=escapeForSqlite(iname)
    iqty=escapeForSqlite(iqty)
    iunit=escapeForSqlite(iunit)
    iclass=escapeForSqlite(iclass)
    ishop=escapeForSqlite(ishop)

    var db = openDB()
    if(!db) { console.error("writeItem:db open failed"); return; }

    var result
    var lastrow=0
    var rid

    db.transaction(function(tx) { // hits, seq, control, , ?, ?, ? , 1, -1, 0
        tx.executeSql("INSERT INTO shoppinglist (istat, iname, iqty, iunit, iclass, ishop, seq) VALUES (?, ?, ?, ?, ?, ?, ?);",
                      [istat, iname, iqty, iunit, iclass, ishop, 0])
        lastrow = tx.executeSql("SELECT last_insert_rowid();")
        rid = lastrow.insertId
    })
    updateShoppinListNextSeq(rid)
    hitShop(ishop) /* update shop reference statistic */
    // console.debug("ostos/dbaccess.js: insertItemToShoppingList inserted rowid:" + rid)
    return rid // rid seems to be a String?
}

/**
 * Rewrites a shopping list row to database using UPDATE (after editing)
 */
function updateItemInShoppingList(rid /* rowid */,iname, iqty, iunit, iclass, ishop) {
    iname=escapeForSqlite(iname)
    iqty=escapeForSqlite(iqty)
    iunit=escapeForSqlite(iunit)
    iclass=escapeForSqlite(iclass)
    ishop=escapeForSqlite(ishop)

    // console.debug("updating rowid:" + rid + " iname:" + iname + " iqty:" + iqty + " iunit:" + iunit + " iclass:" + iclass + " ishop:" + ishop)

    var db = openDB()
    if(!db) { /* console.error("writeItem:db open failed"); */ return; }

    var result
    var lastrow=0

    db.transaction(function(tx) {
        tx.executeSql("UPDATE OR REPLACE shoppinglist SET iname=?, iqty=?, iunit=?, iclass=?, ishop =? WHERE rowid=?;",
                      [iname, iqty, iunit, iclass, ishop, rid])
    })
    hitShop(ishop)

    return rid
}

/**
 * Rewrites a shopping list row to database using UPDATE (after editing)
 */
function updateSeqShoppingList(rid /* rowid */,seq) {

    // console.debug("ostos/dbaccess.js: updating rowid:" + rid + " seq:" + seq )

    var db = openDB()
    if(!db) { console.error("harbour-ostos:db open failed"); return; }

    var result
    var lastrow=0
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE OR REPLACE shoppinglist SET seq=? WHERE rowid=?;",
                          [seq, rid])
        })

    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: SQL:"+sqlErr)
        return
    }

    return rid
}

/*
 * get seq (sequence) number from a row
 * 0 ext refrences
 * not tested
 */
function getSeq(rowid,seq) {
    // console.debug("ostos/dbaccess.js: getSeq"+rowid+":"+seq)

    var db = openDB()
    if(!db) { console.error("getSeq:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            rs = tx.executeSql('SELECT seq FROM shoppinglist WHERE rowid=? ;', rowid)
        })
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: SQL:"+sqlErr)
        return
    }
    var seq = 0

    seq = rs.rows.item(i).seq
    // console.debug("ostos/dbaccess.js: getSeq: seq="+seq)
    return seq
}


/**
 * Delete list item from the list
 */
function deleteItemFromShoppingList(rid) {
    rid=escapeForSqlite(rid)

    var db = openDB()
    if(!db) { /* console.error("deleteItem:db open failed");*/ return; }
    var result
    var lastrow=0

    console.debug("Deleting row:" + rid)

    try {
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM shoppinglist WHERE rowid=?;",[rid])
        })
        return rid
    } catch (sqlErr) {
        console.error("dbaccess.js: SQL could not delete rowid:"+rid)
        return
    }
}

/*
 * Debugging dump to console of DB contents
 */
function dumpShoppingList() {
    var db = openDB()
    console.log("********shoppinglist DATABASE DUMP BY ostos.dbaccess.js.dumpShoppingList()********")
    console.log("rowid\tistat\tiname\t\tiqty\tiunit\ticlass\tishop\tseq")
    if(!db) { console.error("ostos/dbaccess.js: dumpShoppingList:db open failed"); return; }
    var rs
    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist;');
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: dump: log squirrel"+sqlErr);
        return "ERROR";
    }
    for(var i = 0; i < rs.rows.length; i++) {
        console.log(rs.rows.item(i).rowid +"\t"+
                    rs.rows.item(i).istat+"\t'"+
                    rs.rows.item(i).iname+"'\t"+
                    rs.rows.item(i).iqty+"\t"+
                    rs.rows.item(i).iunit+"\t"+
                    rs.rows.item(i).iclass+"\t"+
                    rs.rows.item(i).ishop+"\t"+
                    rs.rows.item(i).seq)
    }
}

/*
 *  Delete all items from the list, debug, uninstall...
 */
function deleteAllShoppingList() {
    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: deleteShopList:db open failed"); return; }
    var rs;

    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('DELETE FROM shoppinglist;');
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: deleteAll: log squirrel:"+sqlErr);
        return "ERROR";
    }
}

/* Delete database
 * this function must delete files in:
 */
//function deleteShopListDatabase() {

//}

/*** Update shop list item fields one by one */
/*
 * Update state for list item selected by rowid
 */
function updateItemState(rid, state) {
    rid=escapeForSqlite(rid);
    state=escapeForSqlite(state);

    //    console.debug("updating Item state, rowid:" + rid + " state:" + state);

    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: update Item state:db open failed"); return; }

    db.transaction(function(tx) {
        tx.executeSql("UPDATE shoppinglist SET istat=? WHERE rowid=?;", [state, rid]);
    });
}

/* Update Quantity */
function updateItemQty(rid, qty) {
    rid=escapeForSqlite(rid);
    qty=escapeForSqlite(qty);
    // console.debug("ostos/dbaccess.js: updateItemQty:("+rid+","+qty)
    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: update Item qty:db open failed"); return; }

    db.transaction(function(tx) {
        tx.executeSql("UPDATE shoppinglist SET iqty=? WHERE rowid=?;", [qty, rid]);
    });
}

/* Find item by name, return row id */
function findItemByName(lm,itemname) {
    // console.debug("ostos/dbaccess.js: findItemByName:"+itemname);
    itemname=escapeForSqlite(itemname)
    var db = openDB()
    if(!db) { console.error("ostos/dbaccess.js: findItemByName:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            print('finding Item By Name ')
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist WHERE iname=? LIMIT 1;', itemname)
        })
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: findItemByName: SQL error")
        return "SQL:"+sqlErr
    }
    if (!rs) {
        console.warn("No result set for:"+itemname)
        return false;
    }
    var c =rs.rows.length
    // console.debug(".Query returned "+c+"rows")
    if (c==0) { return false }
    var istat = ""
    var iname = ""
    var iqty = ""
    var iunit = ""
    var iclass = ""
    var ishop = ""
    var i = 0
    var irid = rs.rows.item(i).rowid
    istat = rs.rows.item(i).istat
    iname = unescapeFromSqlite(rs.rows.item(i).iname)
    iqty = unescapeFromSqlite(rs.rows.item(i).iqty)
    iclass = unescapeFromSqlite(rs.rows.item(i).iclass)
    iunit = unescapeFromSqlite(rs.rows.item(i).iunit)
    ishop = unescapeFromSqlite(rs.rows.item(i).ishop)
    // console.debug("ostos/dbaccess.js: findItemByName DB read: "+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
    if (lm){
        lm.append({
                      "istat":istat,
                      "iname":iname,
                      "iqty":iqty,
                      "iunit":iunit,
                      "ishop":ishop,
                      "iclass":iclass,
                      "rowid":irid
                  })
    }
    return irid

}


/*
 * Shops table management
 */
/*
 * insert new item and return id
 */
function addShop(sname) {
    sname=escapeForSqlite(sname);

    console.debug("ostos/dbaccess.js: Adding shop to db:"+sname);
    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: addShop:db open failed"); return; }

    var lastrow=0;
    var rid;
    try {
        db.transaction(function(tx) {
            tx.executeSql("INSERT INTO shops (name,hits,seq,control) VALUES (?,?,?,?);",
                          [sname,0,0,0]);
            lastrow = tx.executeSql("SELECT last_insert_rowid();");
            rid = lastrow.insertId;
        });
    } catch (sqlErr) {
        // console.error("ostos/dbaccess.js: "+sqlErr);
        rid="-1";
    }

    // console.debug("ostos/dbaccess.js: inserted Shop rowid:" + rid);
    return rid; // rid seems to be a String?

}

/*
 * Find shop by an old name and replace the name with a new name
 */
function updateShopNameDB(oldname, newname) {
    var oN=escapeForSqlite(oldname)
    var nN=escapeForSqlite(newname)

    // console.debug("ostos/dbaccess.js: updateShopName\("+oN+","+nN+"\)")

    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: update Item state:db open failed"); return; }
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE shops SET name=? WHERE name=?;", [newname, oldname]);
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: updateShopName("+oN+","+nN+"): "+sqlErr)
    }
}

function updateShopNameInShoppinglistDB(oldname, newname) {
    var oN=escapeForSqlite(oldname);
    var nN=escapeForSqlite(newname);

    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: update Item state:db open failed"); return; }
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE OR REPLACE shoppinglist SET ishop=? WHERE ishop=?;",
                          [nN,oN])
        })
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: updateShopName...DB("+oN+","+nN+"): "+sqlErr)
    }
}
/*
 *
 */
function shopRefCount(shopname) {
    var sN=escapeForSqlite(shopname);

    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js:update Item state:db open failed"); return; }

    var rs
    try {
        db.transaction(function(tx) {
            rs=tx.executeSql("select ishop from shoppinglist where ishop=?;",[sN])
        })
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: updateShopName("+oN+","+nN+"): "+sqlErr)
    }

    var count = 0
    // I couldn't get count() value out to count variable.
    // The pragmatic way to do it. :-(
    for (var i=0;i<rs.rows.length;i++) {
        if (rs.rows.item(i).ishop==sN) count++
    }

    //    console.debug("ostos/dbaccess.js: shop "+sN+" ref count "+count)
    return count
}

// dq for Double Quote

function dq(str) {
    return '"' + str + '"';
}

/*
 * Returns shop list ordered by [usage] hits as array
 * Reads shops as array, and apprends to given listmodel
 */
function repopulateShopList(lm /* ListModel */) {
    //    console.debug("ostos/dbaccess.js: repopulateShopList")
    var shops = getAllShopsByHits()
    var shoparr
    try {
        shoparr=JSON.parse(shops)
    } catch (err) {
        console.error("Tried to parse \'"+shops+"\' err:"+err)
        return;
    }

    lm.clear();
    for(var i=0; i<shoparr.length; i++) {
        //        console.debug("ostos/dbaccess.js: shoparr ["+i+"] ="+shoparr[i]+" length="+shoparr.length);
        lm.append({"checked":false,"name":shoparr[i],"edittext":shoparr[i]});
    }
}

/********************************************************
 * Gets all shop names ordered by usag statistics of shops
 * any usage increments reference count
 *
 * Returns array like ["shop1","shop2","shop3"]
 */

function getAllShopsByHits() {
    var db = openDB();

    if(!db) { console.error("ostos/dbaccess.js: getAllShopssByHits:db open failed"); return; }
    var rs;
    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT name FROM shops ORDER BY hits DESC;');
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: getAllShopsByHits log squirrel:"+sqlErr);
        return "ERROR";
    }
    var arr = "";
    //    console.debug("ostos/dbaccess.js: rs.rows.length:"+rs.rows.length)
    if(rs.rows.length<1) {
        return "[NULL]";
    }
    arr = "[";
    var str = rs.rows.item(0).name
    str = unescapeFromSqlite(str)
    arr += dq(str);
    for(var i = 1; i < rs.rows.length; i++) {
        arr += ",";
        str = rs.rows.item(i).name;
        str = unescapeFromSqlite(str);
        arr += dq(str);
    }
    arr += "]"
    //    console.debug(arr);
    return arr;
}

/**
 * fills a ListModel
 */
function getAllShopData(lm) {
    var db = openDB();

    if(!db) { console.error("ostos/dbaccess.js: getAllShopssByHits:db open failed"); return; }
    var rs;
    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT * FROM shops ORDER BY hits DESC;');
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: getAllShopsByHits log squirrel:"+sqlErr);
        return "ERROR";
    }
    var obj = "";
    //    console.debug("ostos/dbaccess.js: rs.rows.length:"+rs.rows.length)
    if(rs.rows.length<1) {
        return "[NULL]";
    }
    arr = "[";
    arr += dq(rs.rows.item(0).name);
    for(var i = 1; i < rs.rows.length; i++) {
        arr += ",";
        arr += dq(rs.rows.item(i).name);
    }
    arr += "]"
    //    console.debug(arr);
    return arr;
}


var HIT_UP_LIMIT = 16393;
var HIT_LOW_LIMIT = 10;
var HIT_DIV = 100;

function hitShop(sname) {
    if (!sname) { return }
    //    console.debug("ostos/dbaccess.js: hitShop:"+sname)
    sname=escapeForSqlite(sname)

    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: :db open failed"); return; }
    var rs;
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE shops SET hits=(hits+1) WHERE name=?;", sname);
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: hitShop: err: " + sqlErr);
        return;
    }
    // Read hits back and scale all hits down if a limit is exceeded.
    // Maybe excessive precaution to prevent wraparound, but I'm an EMBEDDED systems engineer...

    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT name,hits FROM shops WHERE name=?;', sname);
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: hitShop: squirrel: " + sqlErr);
        return;
    }
    if (rs.rows.length>0) {
        var f = rs.rows.item(0).hits;
        if( f > HIT_UP_LIMIT) {
            scaleShopsHits();
        }
    }
}

function scaleShopsHits() {
    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: db open failed"); return; }
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE shops SET hits = (CASE WHEN ((hits/HIT_DIV) > HIT_LOW_LIMIT) THEN (hits/HIT_DIV) ELSE (hits) END);");
        });
    } catch (sqlErr) {
        console.error("ostos/dbaccess.js: scaleShopsHits: squirrel: " + sqlErr);
        return;
    }
}

function deleteShop(sname) {
    sname=escapeForSqlite(sname);
    var db = openDB();
    if(!db) { console.error("ostos/dbaccess.js: delete Shop:db open failed"); return; }
    //    console.debug("ostos/dbaccess.js: deleteShop:" + sname);
    db.transaction(function(tx) {
        tx.executeSql("DELETE FROM shops WHERE name=?;", sname);
    });
}

/*
 * Settings table management
 * The idea is not to enumerate settings, but just put them into database as (setting, value) pairs.
 * In order to add a new setting [variable] there is no need to edit this code
 * In table creation I set 'setting' to TEXT of length 16 and 'value' to TEXT of length 64.
 * Wasting space? Yes. Flexible? Yes. You can put there a short sentence of text or any int or a real
 * - just remember to cast to TEXT when setting and parse when getting if necessary.
 */
// insert new item and return id
function setSetting(setting,value) {

    setting=escapeForSqlite(setting);
    value=escapeForSqlite(value);
    console.debug("ostos/dbaccess.js: setSetting: setting,value: " + setting + ","+value);


    var db = openDB();
    var rs;
    if(!db) { console.error("ostos/dbaccess.js: setSetting:db open failed"); return; }

    try {
        db.transaction(function(tx) {
            tx.executeSql("INSERT OR REPLACE INTO settings (setting,value) VALUES (?,?);",[setting,value]);
        });
    } catch (sqlErr) {
        console.debug("setSetting: log squirrel: " + sqlErr);
        return;
    }
    return;
}

/*
 * input setting TEXT string
 * output value TEXT string
 */
function getSetting(setting) {
    setting=escapeForSqlite(setting);

    var db = openDB();
    var rs;
    if(!db) { console.error("ostos/dbaccess.js: getSetting:db open failed"); return; }

    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT setting, value FROM settings WHERE setting=? LIMIT 1;',[setting]);
        });
    } catch (sqlErr) {
        console.debug("ostos/dbaccess.js: getSetting: log squirrel: " + sqlErr);
        return NO_SETTING; // "ERROR"
    }

    if(rs.rows.length>0) {
        var v=rs.rows.item(0).value;
        v = unescapeFromSqlite(v);
        //console.debug("ostos/dbaccess.js: getSetting: setting,value: " + setting + ","+v);
        return v;
    } else {
        return NO_SETTING;
    }
}

function deleteSetting(setting) {
    console.error("deleteSetting ("+setting+") -  Not implemented yet!");
}

/*
*Sequence number for order handling
*/

/* Get maximum seq number */
function getMaxSeq() {
    var maxseq
    var db = openDB();
    var rs;
    if(!db) { console.error("ostos/dbaccess.js: getMaxSeq:db open failed"); return; }

    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT MAX(seq) AS db_maxseq FROM shoppinglist;');
        });
    } catch (sqlErr) {
        console.debug("ostos/dbaccess.js: getMaxSeq: log squirrel: " + sqlErr);
        return ""; // "ERROR"
    }
    maxseq = rs.rows.item(0).db_maxseq
    // console.debug("ostos/dbaccess.js: getMaxSeq returns:"+maxseq)
    return maxseq
}

/*
 * update next seq number to row
 */

function updateShoppinListNextSeq(row) {
    var seq

    // get biggest seq value
    seq = getMaxSeq()
    seq++
    updateSeqShoppingList(row,seq)
}
