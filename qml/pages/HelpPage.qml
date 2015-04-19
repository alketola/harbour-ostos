import QtQuick 2.0
import Sailfish.Silica 1.0

/*
 * Copyright Antti Ketola 2015
 * License: GPL V3
 *
 * Help page of the shopping list app
 */
Page {
    id: page
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: col
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                title: qsTr("Help")
            }

            TextArea {
                width: parent.width
                color: Theme.primaryColor
                id: name
                text: qsTr("Add new items by using the pulldown menu") +
                      qsTr("The items have different states. The state can be changed by clicking the state icon on the left.") +
                      qsTr("The context menu has options to delete, increase, decrease and edit list items.")
            }
        }
    }
}

