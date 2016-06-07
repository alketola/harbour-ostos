/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../dbaccess.js" as DBA

CoverBackground {
    id: coverback
    property int cover_index: 0
    property string itemname
    property int myLineHeight: Theme.fontSizeSmall + Theme.paddingSmall

    Label {
        id: coverlabel
        y: 8
        x: parent.width / 3
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
        text: qsTr("Ostos")
    }
    ListModel {
        id: coverlistmodel

    }

    ListView {
        model: coverlistmodel
        anchors.top: coverlabel.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        delegate: ListItem {
            id: coverdelegate
            height: myLineHeight

            Row {
                height: myLineHeight
                width: parent.width
                spacing: 2

                Rectangle {
                    id: rowspacer1
                    width: parent.width *0.05
                    height: myLineHeight
                    opacity: 0
                }

                Label {
                    id: coverDname
                    height: myLineHeight
                    width: parent.width * 0.5

                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade

                    text: iname
                }
                Label {
                    id: coverDqty
                    height: myLineHeight
                    width: parent.width * 0.22
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignRight

                    truncationMode: TruncationMode.Fade

                    text: iqty
                }
                Rectangle {
                    id: rowspacer2
                    height: myLineHeight
                    width: 5

                    opacity: 0
                }
                Label {
                    id: coverDunit
                    height: myLineHeight
                    width: parent.width * 0.2
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Fade

                    text: iunit
                }
                Rectangle {
                    id: rowspacer3
                    height: myLineHeight
                    width: parent.width *0.05

                    opacity: 0
                }
            }
        }
    }

    //    CoverActionList {
    //        id: coverAction

    //        CoverAction {
    //            iconSource: "image://theme/icon-cover-sync"
    //            onTriggered: {
    //                coverlistmodel.clear()
    //                DBA.readShoppingListByState(coverlistmodel,"BUY")
    //            }
    //        }
    //        CoverAction {
    //            iconSource: "image://theme/icon-cover-previous"
    //            onTriggered: {

    //                if(cover_index>1) {
    //                    cover_index--;
    //                } else {
    //                    cover_index=shoppingListModel.count-1;
    //                }

    //            }
    //        }
    //        CoverAction {
    //            iconSource: "image://theme/icon-cover-next"
    //            onTriggered: {
    ////                setAsGot()
    ////                refreshShoppingListByShop()
    //                if(cover_index<shoppingListModel.count-1) {
    //                    cover_index++;
    //                } else {
    //                    cover_index=0;
    //                }
    //            }
    //        }
    //    }

    /* Cover action 'next' sets an item as got and goes for next one */
    function setAsGot() {
        DBA.updateItemState(parseInt(shoppingListModel.get(cover_index).rowid),"GOT");
        shoppingListModel.setProperty(cover_index,"istat","GOT");
    }


    onStatusChanged: {
        if(status==PageStatus.Active) {
            coverlistmodel.clear()
            DBA.readShoppingListByState(coverlistmodel,"BUY")
        }
    }
}


