# harbour-ostos
A shopping list app for Jolla, Sailfish OS native, simply QML &amp; Javascript. It should be a good, preferred one.
My motivation to develop this has come from the long years I have had to take care of children, cook, and go shopping, 
and the available shopping lists have been uncomfortable for me. I have used Jolla's 'Muistio' ('Notes') for the 
purpose, and it serves for the purpose in a minimalistic way. I wanted something else, and no shopping chain 
dependencies. This is not about building an ecosystem, just an app to make and use shopping list. ;-)

Yes I looked at Armadill0 's harbour-tasklist, but finally decided not to fork it. 

There are a couple of ideas that I wanted to be different:
- The first page show the list, and lets to a select a sub-list by clicking (ContextMenu)
- The items are easy to add, and have voluntary quantity, unit, classification and destination shop attributes
- The items should have more than just (on/off) state. In practise, I have found usable to be able to mark itemas as 
  'not found' - it's a real situation. Now there are three states "BUY" (yellow), "GOT" green, "FIND" red. 
   I could imagine a couple of more states too...
- Item edit is left uncontrolled in purpose. You can edit the unit and class to any text if you wish.
- State changing should be easy. - Just click the item line. For delete or edit buttons, press to get a context menu
- The line context menu has buttons at this first version, which might be considered intentional violation of UI 
  design recommendations. I might change it to text... but I wanted to see buttons there.
- The lists are self-arranging to some degree. At the moment they are arranged by state, yellow items come first, 
  then reds and finally greens. With localstorage's SQLite, many things are possible, and there are some 
  fields to make ordering tricks. (hits usage statistics, seq thought for forced order, control for something 
  I haven't decided yet)

This is my first QT QUICK project. There are a couple of ugly circumventings of glitches.

There are some missing things, misunderstandings and bugs.
- Classes are not editable by user
- Front page refreshing is... ugly. There is no event for onExpandedComboboxClosed:??
- Deleting a shop in shop editor causes a hangup...
- There are some quite outrageous ways to use Qt Quick, like ComboBox in PageHeader. However it quite works.

 It's quite usable but not finished. I will study more Qt when I have more time. :-D
 

