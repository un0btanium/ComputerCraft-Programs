CC Forum Post: https://web.archive.org/web/20230212195034/https://www.computercraft.info/forums2/index.php?/topic/12485-smart-programmer-021-easily-create-loopable-programs-w-build-in-persistence/

CC Forum Post Text:

# Smart Programmer [0.2.1] | Easily create loopable programs /w build-in Persistence

Hello Minecrafter,

this time i give everybody the chance to make their own program without knowing any lua commands at all. Neat? I hope so. Select from the basic commands, up to commands from other mods to create your own program.

## SMART PROGRAMMER BETA VERSION 0.2.1

Pastebin: 3T0cBtKi

## Features:

- Simple menu; keyboard controlled
- Create own programs with common turtle interactions without knowing the lua command
- Run your own program in a loop to transport items or make an own tree farm and so on
- append and add allready existing programs to your new one -> re-use code
- add own commands even from other mods/apis/peripherals
- turn Live Tracking on and off

## Installation:
Label your turtle to let it save the programs and save files.

<code>label set \<name\></code>

Put the code in a text document without ending in ...yourMinecraftDirection\mods\ComputerCraft.zip\lua\rom\programs\turtle

Or if you are running a server you have to put it in ...yourMinecraftServerDirection\mods\ComputerCraft.zip\lua\rom\programs\turtle

Restart your Minecraft Client or Server (or both)

Or you can use the simple pastebin import. Simply type the following words into your turtle.

<code>pastebin get 3T0cBtKi startup</code>


## How to use:

If you downloaded the program, start it with the name you gave it (e.g. startup). You will find yourself in a small menu with at the moment three possible selectable programs.
D or Enter --- Open up submenu or start program
W or Up-key --- Select menu point above
S or Down-key --- Select menu point below
A or Backspace --- Go back to the menu before or exit the program



### Create

Select this if you want to create a new program. Press the numbers 1-6 to switch between the menus.
By pressing specific keys you add an action to the program. If Live Tracking is enabled, the turtle will make the added action (e.g. moving 5 blocks forward). This helps keeping the overview. Be sure the turtle has fuel in it to be able to move.

The Overview Menu shows you the last 8 actions you added to your program, but you also can delete the last actions.
By adding an allready existing program, you import a program and append it to the program you are creating.
You also can add own commands, but be sure that the command is written correctly and works. Please double check every time!

If you finished your program, go back to the first menu, press Enter and give your program a name. Be sure the turtle can run the program in a infinite loop over and over again.


### Start

If you have created at least one program, you can choose from this menu one of them. Use the keys W and S or Up and Down to select one of your programs. Start with D or Enter or go back to the menu with A or Backspace.

If you selected a program it will run forever, so be sure that the turtle will refuel at some point or stop in front of something if you think it can be shutdown.

If the turtle gets shutdown in an unloaded chunk it will start again where it was left.

If you want to stop the turtle from working, you have to hold STRG + T until the program gets terminated and then write the following command.

<code>delete Savepoint</code>

Then you can start the program again (with e.g. startup) and get into the main menu to create, start or delete a program.



### Delete
Deletes a program out of your list.
Advanced knowledge: It still exists in the turtle's folder. You can redo the delete by adding the name of the program in the file "listOfRoutes" in the turtle's folder.



## To-Do:

- add if-statements
- most actions dont get redone if an action gets deleted (except redstone output at the moment)


## Updates:

### Beta Version 0.2.1
- fixed bug; now turtle can go up

### Beta Version 0.2.0
- added delete option
- added sleep command called wait
- added the possibility of adding own commands
- added the possibility of adding allready existing programs
- improved menu and submenus when programming a program
- improved Live Tracking: Now can be turned off and on while programming



If there are any questions, suggestions, errors or bugs, feel free to leave a comment to improve this program pack.

Thank you for your attention.

UNOBTANIUM