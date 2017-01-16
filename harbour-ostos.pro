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
    qml/pages/FirstPage.qml


# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-ostos-fi.ts
TRANSLATIONS += translations/harbour-ostos-sv.ts
TRANSLATIONS += translations/harbour-ostos-de.ts
TRANSLATIONS += translations/harbour-ostos-es.ts

RESOURCES += \
    resources.qrc

DISTFILES += \
    to-do-notes.txt \
    qml/itemadd.js \
    qml/images/graphic-toggle-off.png \
    qml/images/graphic-toggle-on.png \
    README.md \
    qml/pages/helphtml.css \
    qml/images/icon-m-delete.png \
    qml/images/icon-m-dismiss.png \
    qml/images/icon-m-down.png \
    qml/images/icon-m-keyboard.png \
    qml/images/icon-m-search.png \
    qml/images/icon-m-up.png \
    qml/images/icon-s-task.png \
    harbour-ostos.png \
    qml/pages/help/helphtml.css \
    qml/pages/help/ostoshelp-de.html \
    qml/pages/help/ostoshelp-es.html \
    qml/pages/help/ostoshelp-fi.html \
    qml/pages/help/ostoshelp-en.html \
    testing.txt \
    LICENSE.txt \
    COPYING \
    icons/128x128/harbour-ostos.png \
    icons/256x256/harbour-ostos.png \
    translations/harbour-ostos-ca.ts \
    translations/harbour-ostos-de.ts \
    translations/harbour-ostos-es.ts \
    translations/harbour-ostos-fi.ts \
    translations/harbour-ostos-sv.ts \
    translations/harbour-ostos.ts \
    qml/pages/FilterPage.qml \
    qml/pages/SpecialButton.qml

SAILFISHAPP_ICONS += 86x86 108x108 128x128 256x256

DISTFILES += icons/86x86/harbour-ostos.png \
    icons/108x108/harbour-ostos.png \
    icons/128x108/harbour-ostos.png \
    icons/256x108/harbour-ostos.png

DEFINES += GIT_VERSION=\\\"$$GIT_VERSION\\\"
