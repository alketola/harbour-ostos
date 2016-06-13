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
    property string webHelpPathURL: "http://mobilitio.com/app-support/ostos/help/"
    property string helpfilename: "ostoshelp"

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
        // Formula for help file name:
        // <path><filename>-<locale>.html
        var helpfile = helppath+helpfilename+"-"+mylocale+".html"
        if (!appWindow.webHelpEnabled) {
            switch(mylocale) {
            case "fi":
                console.debug("suomi")
                break
            case "es":
                console.debug("español")
                break
            case "de":
                console.debug("Deutsch")
                break
            case "en":
                console.debug("English")
                break
            default:
                console.debug("Default case for unknown locale:"+mylocale+"=> \"en\"")
                mylocale="en"
            }
            helpURL = helppath+helpfilename+"-"+mylocale+".html"

        } else {
            helpURL=webHelpPathURL+helpfilename+".html"
        }
        console.log("helpURL="+helpURL)
        helpView.url = helpURL
    }

}

