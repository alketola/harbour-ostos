.import QtQuick.LocalStorage 2.0 as LS

/* External variable references to be noted:
 * Qt Quick: ListModel shopListModel, declared in ApplicationWindow page
 */


/*
 * Opens Qt/QML Local Storage database
 * The database is in /home/nemo/.local/share/<AppName>/<AppName>/QML/OfflineStorage/Databases
 */
function openDB() {
    return LS.LocalStorage.openDatabaseSync("ShopListDB", "1.1", "Shopping list database", 100000);
}

/**
 * Escapes string so that special characters are preceded by backslash.
 *
 * The user may not introduce Special Characters as plain to SQLITE database
 * because it may cause database corruption or other problems
 */
function escapeForSqlite(s){
    if (!s) return ""
    var t=s.toString()
    var regex = /['".*+?^${}()|[\]\\]/g
    var sub = '\\$&'
    return t.replace(regex, sub)
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
    var db = openDB()
    db.transaction( function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS shoppinglist (istat TEXT, iname TEXT PRIMARY KEY, iqty TEXT, iunit TEXT, iclass TEXT, ishop TEXT, hits INTEGER, seq INTEGER, control INTEGER);')
    })

    db.transaction( function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS shops (name TEXT PRIMARY KEY, hits INTEGER, seq INTEGER, control INTEGER);')
    })

    db.transaction( function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings (setting TEXT(16) PRIMARY KEY, value TEXT(64));')
    })

    try {
        db.transaction( function(tx) {
            tx.executeSql('INSERT INTO shops (name, hits, seq) VALUES ("unassigned", 0, 0);')
        })
    } catch (sqlErr) {
        // do nothing with it
    }

}

/*
  Reads all shopping list items and writes them to shopping list model (which is rendered to the first page
  */
function readAllShoppingList(lm) {
    console.log("readAllShoppingList");
    var db = openDB()
    if(!db) { console.log("readAll:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            print('readAllShoppingList('+lm+')')
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist ORDER BY istat, rowid DESC;')
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
    var ishop
    for(var i = 0; i < rs.rows.length; i++) {
        irid = rs.rows.item(i).rowid
        istat = rs.rows.item(i).istat
        iname = unescapeFromSqlite(rs.rows.item(i).iname)
        iqty = unescapeFromSqlite(rs.rows.item(i).iqty)
        iclass = unescapeFromSqlite(rs.rows.item(i).iclass)
        iunit = unescapeFromSqlite(rs.rows.item(i).iunit)
        ishop = unescapeFromSqlite(rs.rows.item(i).ishop)
        //console.log("DBREAD:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
        lm.append({ //rs.rows.item(i).
                      "istat":istat,
                      "iname":iname,
                      "iqty":iqty,
                      "iunit":iunit,
                      "ishop":ishop,
                      "iclass":iclass,
                      "rowid":irid
                  })
    }
}


/*
 * Reads all shopping list items and writes them to shopping list model
 * but only for a certain shop
 */
function readShoppingListByShop(lm,shopname) {
    console.log("readShoppingListByShop:"+shopname);
    shopname=escapeForSqlite(shopname)
    var db = openDB()
    if(!db) { console.log("readAllByShop:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            print('... read in list items')
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist WHERE ishop=? ORDER BY istat, rowid DESC;', shopname)
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
        //        console.log("DBREAD-S:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
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
/* by states */
/*
 * Reads all shopping list items and writes them to shopping list model
 * but only those which are not in excluded_state (e.g. "BUY")
 */
function readShoppingListExState(lm,excluded_state) {
    console.log("readTheListExState:"+excluded_state);
    excluded_state=escapeForSqlite(excluded_state)
    var db = openDB()
    if(!db) { console.log("readTheListExState:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            print('... read in list items')
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist WHERE NOT istat=? ORDER BY istat, iname, rowid DESC;', excluded_state)
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
        //        console.log("DBREAD-S:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
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
    console.log("readShoppingListByShop:"+shopname+", ex:"+excluded_state);
    shopname=escapeForSqlite(shopname)
    excluded_state=escapeForSqlite(excluded_state)
    var db = openDB()
    if(!db) { console.log("readAllByShop:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            print('... read in list items')
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist WHERE ishop=? AND NOT istat=? ORDER BY istat, rowid DESC;', shopname, excluded_state)
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
        //        console.log("DBREAD-S:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
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
    if(!db) { console.log("writeItem:db open failed"); return; }

    var result
    var lastrow=0
    var rid

    db.transaction(function(tx) { // hits, seq, control, , ?, ?, ? , 1, -1, 0
        tx.executeSql("INSERT INTO shoppinglist (istat, iname, iqty, iunit, iclass, ishop, seq) VALUES (?, ?, ?, ?, ?, ?, ?);",
                      [istat, iname, iqty, iunit, iclass, ishop, 0])
        lastrow = tx.executeSql("SELECT last_insert_rowid();")
        rid = lastrow.insertId
    })
    hitShop(ishop) /* update shop reference statistic */
    console.log("insertItemToShoppingList inserted rowid:" + rid)
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

    console.log("updating rowid:" + rid + " iname:" + iname + " iqty:" + iqty + " iunit:" + iunit + " iclass:" + iclass + " ishop:" + ishop)

    var db = openDB()
    if(!db) { console.log("writeItem:db open failed"); return; }

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

    console.log("updating rowid:" + rid + " seq:" + seq )

    var db = openDB()
    if(!db) { console.log("writeItem:db open failed"); return; }

    var result
    var lastrow=0

    db.transaction(function(tx) {
        tx.executeSql("UPDATE OR REPLACE shoppinglist SET seq=? WHERE rowid=?;",
                      [seq, rid])
    })

    return rid
}

function getSeq(rowid,seq) {
    console.log("getSeq"+rowid+":"+seq)

    var db = openDB()
    if(!db) { console.log("getSeq:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            rs = tx.executeSql('SELECT seq FROM shoppinglist WHERE rowid=? ;', rowid)
        })
    } catch (sqlErr) {
        return "SQL:"+sqlErr
    }
    var seq = 0

    seq = rs.rows.item(i).seq
    console.log("getSeq: seq="+seq)
    return seq
}


/**
 * Delete list item from the list
 */
function deleteItemFromShoppingList(rid) {
    rid=escapeForSqlite(rid)

    var db = openDB()
    if(!db) { console.log("deleteItem:db open failed"); return; }
    var result
    var lastrow=0

    console.log("Deleting row:" + rid)

    try {
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM shoppinglist WHERE rowid=?;",[rid])
        })
        return rid
    } catch (sqlErr) {
        return "SQL could not delete rowid:"+rid
    }
}

/*
 * Debugging dump to console of DB contents
 */
function dumpShoppingList() {
    var db = openDB()

    if(!db) { console.log("dumpShopList:db open failed"); return; }
    var rs
    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist;');
        });
    } catch (sqlErr) {
        console.log("dump: log squirrel"+sqlErr);
        return "ERROR";
    }
    for(var i = 0; i < rs.rows.length; i++) {
        console.log(rs.rows.item(i).rowid +":"+
                    rs.rows.item(i).istat+":"+
                    rs.rows.item(i).iname+":"+
                    rs.rows.item(i).iqty+":"+
                    rs.rows.item(i).iunit+":"+
                    rs.rows.item(i).iclass+":"+
                    rs.rows.item(i).ishop+":");
    }
}

/*
 *  Delete all items from the list, debug, uninstall...
 */
function deleteAllShoppingList() {
    var db = openDB();
    if(!db) { console.log("dumpShopList:db open failed"); return; }
    var rs;

    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('DELETE FROM shoppinglist;');
        });
    } catch (sqlErr) {
        console.log("deleteAll: log squirrel");
        return "ERROR";
    }
}

/* Delete database
 * this function must delete files in:
 * /home/nemo/.local/share/<AppName>/<AppName>/QML/OfflineStorage/Databases
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

    //    console.log("updating Item state, rowid:" + rid + " state:" + state);

    var db = openDB();
    if(!db) { console.log("update Item state:db open failed"); return; }

    db.transaction(function(tx) {
        tx.executeSql("UPDATE shoppinglist SET istat=? WHERE rowid=?;", [state, rid]);
    });
}

/* Update Quantity */
function updateItemQty(rid, qty) {
    rid=escapeForSqlite(rid);
    qty=escapeForSqlite(qty);
    console.log("updateItemQty:("+rid+","+qty)
    var db = openDB();
    if(!db) { console.log("update Item count:db open failed"); return; }

    db.transaction(function(tx) {
        tx.executeSql("UPDATE shoppinglist SET iqty=? WHERE rowid=?;", [qty, rid]);
    });
}

/* Find item by name, return row id */
function findItemByName(lm,itemname) {
    console.log("findItemByName:"+itemname);
    itemname=escapeForSqlite(itemname)
    var db = openDB()
    if(!db) { console.log("findItemByName:db open failed"); return; }
    var rs
    try {
        db.transaction( function(tx) {
            print('finding Item By Name ')
            // Now ordering initial list so that (BUY before FIND before GOT) and the newest (biggest rowid) first
            rs = tx.executeSql('SELECT rowid, * FROM shoppinglist WHERE iname=? LIMIT 1;', itemname)
        })
    } catch (sqlErr) {
        return "SQL:"+sqlErr
    }
    if (!rs) {
        console.log("No result set")
        return false;
    }

    var istat = ""
    var iname = ""
    var iqty = ""
    var iunit = ""
    var iclass = ""
    var ishop = ""
    var i = 0;
    var irid = rs.rows.item(i).rowid // Uuden lisäyksessä tässä TypeError: Cannot read property 'rowid' of undefined
    istat = rs.rows.item(i).istat
    iname = unescapeFromSqlite(rs.rows.item(i).iname)
    iqty = unescapeFromSqlite(rs.rows.item(i).iqty)
    iclass = unescapeFromSqlite(rs.rows.item(i).iclass)
    iunit = unescapeFromSqlite(rs.rows.item(i).iunit)
    ishop = unescapeFromSqlite(rs.rows.item(i).ishop)
    console.log("DBREAD-find:"+irid+"/"+istat+"/"+iname+"/"+iqty+"/"+iclass+"/"+iunit+"/"+ishop)
    if (lm){
        lm.append({ /// ERROR! DOES NOT RETURN row ID!
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

    console.log("adding shop:"+sname);
    var db = openDB();
    if(!db) { console.log("addShops:db open failed"); return; }

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
        console.log(sqlErr);
        rid="-1";
    }

    console.log("inserted Shop rowid:" + rid);
    return rid; // rid seems to be a String?

}

/*
 * Find shop by an old name and replace the name with a new name
 */
function updateShopNameDB(oldname, newname) {
    var oN=escapeForSqlite(oldname)
    var nN=escapeForSqlite(newname)

    console.log("Entering updateShopName\("+oN+","+nN+"\)")

    var db = openDB();
    if(!db) { console.log("update Item state:db open failed"); return; }
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE shops SET name=? WHERE name=?;", [newname, oldname]);
        });
    } catch (sqlErr) {
        console.log("updateShopName\("+oN+","+nN+"\)\;"+sqlErr)
    }
}

function updateShopNameInShoppinglistDB(oldname, newname) {
    var oN=escapeForSqlite(oldname);
    var nN=escapeForSqlite(newname);

    var db = openDB();
    if(!db) { console.log("update Item state:db open failed"); return; }
    db.transaction(function(tx) {
        tx.executeSql("UPDATE OR REPLACE shoppinglist SET ishop=? WHERE ishop=?;",
                      [nN,oN])
    })
}
/*
 *
 */
function shopRefCount(shopname) {
    var sN=escapeForSqlite(shopname);

    var db = openDB();
    if(!db) { console.log("update Item state:db open failed"); return; }

    var rs
    db.transaction(function(tx) {
        rs=tx.executeSql("select ishop from shoppinglist where ishop=?;",[sN])
    })
    var count = 0
    // I couldn't get count() value out to count variable.
    // The pragmatic way to do it. :-(
    for (var i=0;i<rs.rows.length;i++) {
        if (rs.rows.item(i).ishop==sN) count++
    }

    //    console.log("shop "+sN+" ref count "+count)
    return count
}

//function updateShopNameInShoppinglistModel(lm, oldname, newname) {
//    var oN=escapeForSqlite(oldname)
//    ContextMenu {
//        id:scx
//    }
//    var nN=escapeForSqlite(newname)
//    for (var i=0; i<lm.count; i++ ) {
//        if (lm.get(i).ishop==oN) {
//            lm.get(i).ishop=nN
//        }
//    }
//}

function dq(str) {
    return '"' + str + '"';
}

/*
 * Returns shop list ordered by [usage] hits as array
 */
function repopulateShopList(lm /* ListModel */) {
    console.log("repopulateShopList")
    var shops = getAllShopsByHits();
    try {
        var shoparr=JSON.parse(shops);
    } catch (err) {
        //console.log("Problem parsing '"+shoparr+" err:"+err);
        return;
    }

    lm.clear();
    for(var i=0; i<shoparr.length; i++) {
        //console.log(shoparr[i]+"["+i+"] length="+shoparr.length);
        lm.append({"name":shoparr[i],"edittext":shoparr[i]});
    }
}

/****************************************
  Functions for usage statistics of shops
  */

function getAllShopsByHits() {
    var db = openDB();

    if(!db) { console.log("getAllShopssByHits:db open failed"); return; }
    var rs;
    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT name FROM shops ORDER BY hits DESC;');
        });
    } catch (sqlErr) {
        console.log("! log squirrel:"+sqlErr);
        return "ERROR";
    }
    var arr = "";
    //    console.log("rs.rows.length:"+rs.rows.length)
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
    //    console.log(arr);
    return arr;
}


var HIT_UP_LIMIT = 16393;
var HIT_LOW_LIMIT = 10;
var HIT_DIV = 100;

function hitShop(sname) {
    if (!sname) { return }
    console.log("hitShop:"+sname)
    sname=escapeForSqlite(sname);

    var db = openDB();
    if(!db) { console.log(":db open failed"); return; }
    var rs;
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE shops SET hits=(hits+1) WHERE name=?;", sname);
        });
    } catch (sqlErr) {
        console.log("hitShop: err: " + sqlErr);
        return;
    }
    // Read hits back and scale all hits down if a limit is exceeded.
    // Maybe excessive precaution to prevent wraparound, but I'm an EMBEDDED systems engineer...

    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT name,hits FROM shops WHERE name=?;', sname);
        });
    } catch (sqlErr) {
        console.log("hitShop: squirrel: " + sqlErr);
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
    if(!db) { console.log(":db open failed"); return; }
    try {
        db.transaction(function(tx) {
            tx.executeSql("UPDATE shops SET hits = (CASE WHEN ((hits/HIT_DIV) > HIT_LOW_LIMIT) THEN (hits/HIT_DIV) ELSE (hits) END);");
        });
    } catch (sqlErr) {
        console.log("scaleShopsHits: squirrel: " + sqlErr);
        return;
    }
}

function deleteShop(sname) {
    sname=escapeForSqlite(sname);
    var db = openDB();
    if(!db) { console.log("delete Shop:db open failed"); return; }
    console.log("deleteShop:" + sname);
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
    console.log("setSetting: setting,value: " + setting + ","+value);


    var db = openDB();
    var rs;
    if(!db) { console.log("setSetting:db open failed"); return; }

    try {
        db.transaction(function(tx) {
            tx.executeSql("INSERT OR REPLACE INTO settings (setting,value) VALUES (?,?);",[setting,value]);
        });
    } catch (sqlErr) {
        console.log("setSetting: log squirrel: " + sqlErr);
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
    if(!db) { console.log("getSetting:db open failed"); return; }

    try {
        db.transaction(function(tx) {
            rs = tx.executeSql('SELECT setting, value FROM settings WHERE setting=?;',[setting]);
        });
    } catch (sqlErr) {
        console.log("getSetting: log squirrel: " + sqlErr);
        return ""; // "ERROR"
    }

    if(rs.rows.length>0) {
        var v=rs.rows.item(0).value;
        console.log("getSetting: setting,value: " + setting + ","+v);
        return v;
    } else {
        return "";
    }
}

function deleteSetting(setting) {
    console.log("Not implemented yet");
}
