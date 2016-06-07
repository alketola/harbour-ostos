# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-ostos

CONFIG += sailfishapp

SOURCES += src/harbour-ostos.cpp \
    src/Filester.cpp

OTHER_FILES += qml/harbour-ostos.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-ostos.changes.in \
    rpm/harbour-ostos.spec \
    rpm/harbour-ostos.yaml \
    translations/*.ts \
    harbour-ostos.desktop \
    qml/pages/HelpPage.qml \
    qml/pages/ItemEditPage.qml \
    qml/pages/ItemAddPage.qml \
    qml/pages/FirstPage.qml \
    qml/dbaccess.js \
    qml/pages/LineButtonsMenu.qml \
    qml/pages/StatButton.qml \
    images/graphic-led-red.png \
    images/graphic-led-yellow.png \
    qml/images/graphic-led-green.png \
    qml/images/graphic-led-red.png \
    qml/images/graphic-led-yellow.png \
    qml/pages/SettingsPage.qml \
    qml/pages/Splash.qml \
    qml/pages/ShopSelector.qml \
    qml/pages/ShopPage.qml \
    qml/pages/NewShopDialog.qml \
    qml/pages/FirstPage.qml \
    translations/harbour-ostos-fi.ts \
    translations/harbour-ostos-ca.ts

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-ostos-de.ts \
    translations/harbour-ostos-fi.ts \
    translations/harbour-ostos-es.ts \
    translations/harbour-ostos-ca.ts

RESOURCES += \
    resources.qrc

DISTFILES += \
    to-do-notes.txt \
    qml/pages/qmlfile \
    qml/itemadd.js \
    qml/images/graphic-toggle-off.png \
    qml/images/graphic-toggle-on.png \
    README.md \
    qml/pages/ostoshelp.html \
    qml/pages/helphtml.css \
    qml/images/icon-m-delete.png \
    qml/images/icon-m-dismiss.png \
    qml/images/icon-m-down.png \
    qml/images/icon-m-keyboard.png \
    qml/images/icon-m-search.png \
    qml/images/icon-m-up.png \
    qml/images/icon-s-task.png
