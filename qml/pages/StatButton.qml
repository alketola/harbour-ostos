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
    //x: 50
    //state:

    states: [
        State {
            name: "BUY"
            PropertyChanges {
                target: statButton;
                explicit: true;
                //                icon.source: "image://theme/icon-m-day";
                icon.source: "../images/graphic-led-yellow.png"
            }
        },
        State {
            name: "GOT"
            PropertyChanges {
                target: statButton;
                explicit: true;
                //                icon.source: "image://theme/icon-m-certificates";
                icon.source: "../images/graphic-led-green.png"
            }
        },
        State {
            name: "FIND"
            PropertyChanges {
                target: statButton;
                explicit: true;
                //                icon.source: "image://theme/icon-m-search";
                icon.source: "../images/graphic-led-red.png"
            }
        }

    ] // states end bracket

    onClicked: {
        firstPageView.currentIndex = index;
        ci = index;
    }
    onExited: {
       cycle(); // Not seems to be redundant. Can't click icon without this?
    }

    // This is necessary to set the initial state
    Component.onCompleted: {
        //console.log("Statbutton Completed istat:"+istat);
        statButton.state=istat;
    }

    function cycle() {
        switch (statButton.state) {
        case "GOT":
            statButton.state = "FIND";
            break;
        case "FIND":
            statButton.state = "BUY";
            break;
        default: // BUY too
            statButton.state = "GOT";
            break;
        }
        DBA.updateItemState(parseInt(shoppingListModel.get(firstPageView.currentIndex).rowid),statButton.state);
        shoppingListModel.setProperty(firstPageView.currentIndex,"istat",statButton.state);
    }
}
