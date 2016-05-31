import QtQuick 2.0
import Sailfish.Silica 1.0

import "../dbaccess.js" as DBA

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Button that changes icon by state, for the shopping list app
 */
IconButton {
    id: statButton

    anchors.leftMargin: 12
    anchors.rightMargin: 12
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width / 6
    //x: 50
    //state:

    states: [
        State {
            name: "BUY"
            PropertyChanges {
                target: statButton;
                explicit: true;
                //icon.source: "../images/graphic-led-yellow.png"
                icon.source: "../images/graphic-toggle-on.png"
            }
        },
        State {
            name: "GOT"
            PropertyChanges {
                target: statButton;
                explicit: true;
                //icon.source: "../images/graphic-led-green.png"
                icon.source: "../images/graphic-toggle-off.png"
            }
        },
        State {
            name: "FIND"
            PropertyChanges {
                target: statButton;
                explicit: true;
                icon.source: "image://theme/icon-s-task";
//                icon.source: "../images/graphic-led-red.png"
            }
        }

    ] // states end bracket

    onClicked: {
        firstPageView.currentIndex = index;
        ci = index;
    }
    onExited: {
       cycle2(); // Does not seem to be redundant. Can't click icon without this?
    }

    // This is necessary to set the initial state
    Component.onCompleted: {
        //console.log("Statbutton Completed istat:"+istat);        
        statButton.setState(istat)

    }

    function setState(state) {
        switch (state) {
        case "BUY":
        case "GOT":
        case "FIND":
        case "HIDE":
            break
        default:
            state="HIDE"
            return
        }

        statButton.state = state
    }

/* tri-state cycle */
    function cycle() {
        switch (statButton.state) {
        case "GOT":
            statButton.state = "FIND";
            break;
        case "FIND":
            statButton.state = "BUY";
            break;
        case "BUY": //too
            statButton.state = "GOT";
            break;            
        }
        DBA.updateItemState(parseInt(shoppingListModel.get(firstPageView.currentIndex).rowid),statButton.state);
        shoppingListModel.setProperty(firstPageView.currentIndex,"istat",statButton.state);
        requestRefresh(true,"StatButton.cycle")
    }    
/* bi-state cycle */
    function cycle2() {
        switch (statButton.state) {
        case "GOT":
            setState("BUY")
            break
        case "BUY": //too
            setState("GOT")
            break
        case "FIND":
            setState("GOT")
            break
        }
        DBA.updateItemState(parseInt(shoppingListModel.get(firstPageView.currentIndex).rowid),statButton.state);
        shoppingListModel.setProperty(firstPageView.currentIndex,"istat",statButton.state);
        requestRefresh(true,"StatButton.cycle")
    }

}
