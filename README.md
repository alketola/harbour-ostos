# harbour-ostos
A shopping list app for Jolla, Sailfish OS native, simply QML &amp; Javascript. It should be a good,
preferred one. My motivation to develop this came from the long years I have had to take care of
children, cook, and go shopping, and the available shopping lists have been uncomfortable for me.
I have used Jolla's 'Muistio' ('Notes') for the purpose, and it serves for the purpose in a
minimali way. I wanted something else, and no shopping chain dependencies. This is not about
building an ecosystem, just an app to make and use shopping list. ;-)

There are a couple of ideas that I wanted :
- The first page shows the shopping list, and lets show all the items ( * ) or by shop
  - The shop filter is on top
- The items are easy to add, and have voluntary quantity, unit, classification and destination shop attributes
- The items have more than just (on/off) state. In practise, I have found usable to be able to mark itemas as
  'not found' - it's a real situation. Now there are three visible states:
  "BUY" (active button), "GOT" (inactive button), "FIND" (flagged). "HIDE" state is not visible, but the items in the state will
  show up in search
- Item edit is left unvalidated string edit in purpose. You can edit the unit and class to any text if you wish.
- State changing is easy. - Just click the item line to toggle between yellow and green
- Long press to get a context menu, that shows:
  - [X the dismiss icon] = HIDE the item
  - [flag icon]          = Flag for FIND
  - [keyboard icon]      = Edit the item
  - [up arrow icon]      = Increase quantity
  - [down arrow icon]    = Decrease quantity
  - [trashcan icon]      = delete item permanently (from database too)
- The line context menu has buttons at this first version, which might be considered intentional violation of UI 
  design recommendations. I might change it to text... but I still like 6 buttons there instead of 6 lines of text.
- The lists are self-arranging and the user can't re-arrange by hand.
  At the moment they are arranged by state, yellow items come first, then reds and finally greens.
  Then the order is by database rowid, which means newest first... which in practise is not all nice.

Further notes on the version
- The earlier front page problem is about the shop selector combo box value, when leaving the edit dialog, and the
current shop global. Now the current shop is set to '*' when leaving edit dialog. Not all fixed...
- Front page refreshing now done via timer, which is a threaded implementation that works glitchless...
but is a bit slow, you can see it.
- Animations are deemed not necessary
- Test cases are missing

This is my Qt/QML/Silica study project.


