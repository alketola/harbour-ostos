import QtQuick 2.2

import Sailfish.Silica 1.0

/*
 * Copyright Antti Ketola 2016
 * License: GPL V3
 *
 * Help page of the shopping list app
 */
Page {
    property string helpURL

    SilicaWebView {
        id: helpView
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom //urlField.top //
            margins: Theme.paddingLarge
        }
        url: "file:help/ostoshelp.html"
    }

    Component.onCompleted: {
        /*
          *  Loads different help page according to locale
          *  of the device few supported.
          *  It could made this more automatic by
          *  deriving the file names from locale string
          *  and then checking file for existence.
          *  Later.
          */
        var mylocale = (Qt.locale().name.substring(0,2))
        var helppath = "help/" // important

        console.debug("On HelpPage.qml, current locale is:"+mylocale)
        switch(mylocale) {
        case "fi":
            console.debug("suomi")
            helpURL=helppath+"ostoshelp-fi.html"
            break;
        case "es":
            console.debug("español")
            helpURL=helppath+"ostoshelp-es.html"
            break;
        case "de":
            console.debug("Deutsch")
            helpURL=helppath+"ostoshelp-de.html"
            break;
        case "ca":
            console.debug("català")
            helpURL=helppath+"ostoshelp-ca.html"
            break;
        case "en":
            console.debug("English")
            helpURL=helppath+"ostoshelp.html"
            break;
        default:
            console.debug("Default case for locale:"+mylocale)
            helpURL=helppath+"ostoshelp.html"
        }

        console.log("helpURL="+helpURL)
        helpView.url = helpURL
    }
}

