CC Forum Post: https://web.archive.org/web/20230213150649/http://www.computercraft.info/forums2/index.php?/topic/13110-turtle-trading-station-030/

CC Forum Post Text:

Hello Minecraft- and ComputerCraft-Community,

i am here to present you my Turtle Trading Station (TTS), which makes trading with other people easier and more compact then ever before (maybe).


# What does the Turtle Trading Station?
Using this program in a multiplayer world, makes trading with other players very easy. Including password secured admin section and an user friendly overview about everything, helps the player to get into it right away.
Add trades, fill chests, get items, change chest slot amount, and easy information access to the turtle if everything is running okay.



## TURTLE TRADING STATION BETA 0.3.0

Pastebin Computer:
Md5UXKbP

Pastebin Turtle:
NunH2naj

## Features:

### admin screen
- password secured
- change various settings
- create trades
- refill chests
- get items out of the chests
- get quickly information how the turtle is doing
- refuel the turtle

### customer screen
- trades are sorted: supply and demand
- shows list of possible trades depending on the selected supply and demand
- clear definition of what the customer has to do and what he buys for what
- key presses only lowers the failure of the customers

### turtle & trading
- quick moving between the chests
- can be place a distance away to protect what is in the chests
- handles exchange money
- handles big trades with items stacks over 16 slots (turtle maximal slots in the inventory)
- detects:
-- if the customer wanted to cheat and put in the wrong kind of item
-- if the customer didn't even placed an item in the chest
-- if the trade is even possible with the amount of items insert
-- how many times the trade is possible depending on the insert items, the amount of items and the left free space in the chests



### Installation:
Label your turtle and computer to let it save the programs and save files.

label set \<name\>

If the HTTP API is enabled, you can use the pastebin import. Simply type the following words into your turtle.

Computer:
pastebin get Md5UXKbP startup

Turtle:
pastebin get NunH2naj startup


### How to use:
Build a nice trading area like shown at the picture at the beginning of this post. The dimensions of the chests can be 4x4 on two sides, but you can lower this amount if you know allready, that you dont have so many demands and offers.

You also have to place a chest - or better a double chest - underneath the turtle. The block above the chest has to be a non-solid block for example a stair.

Or use an enderchest:

Place a modem on the turtle and on the top side of the computer.
After installing both programs, on the computer and on the turtle, you can run the programs. I recommend using "startup" so they can automatically resume after you reload a chunk.
The computer asks for a password. Type in some letters (!) of your choice and finish with Enter. The password wont be visible until you hit Enter. An overview menu shows you the computer id. Enters the computers ID into the turtles screen and take the turtle's id and enter it into the computer. This let's them communicate with each other. Then you can tipe in a welcome text for the customers. Say hello or/and the newest and hottest purchases to the people. That is your place to be creative.
You can change the password, the turtle id and the welcome text in the admin menu under "Options".

The turtle now waits for incoming messages. The computer shows the admin menu with multiple options:

#### 1 - Start
This will leave the admin menu and start up the customer one, where everybody can go and buy items.
You can leave the customer menu by simply tiping your passwort.
Spoiler 

#### 2 - Add
This is going to add a new trade. You have to answer som questions:
Which item do you want? Demand
Which item do you have and give? Offer
Be sure that you write the names correctly!
Then how many items you want and then give. (E.g. You want 1 Iron Ingot and give 8 Oak Wood)
If you dont have a chest with the demand or offer item it will ask for an indicator item. Place it in the chest and hit Enter.
Your trade should be created.

#### 3 - Get
If you are having items from trades in your chests, you can select the item and the amount here and the turtle will go and grab them for you. Do not take items out of the chests by yourself!

#### 4 - Refill
If some chests are not full enough to make some serious trading, you should check this menu out. Select an item type and place the items in the chest (not the accual item chest!) and hit Enter.
The turtle will fill them into the correct chest.

#### 5 - Refuel
Place some coal into the chest and the turtle will refuel it.
Be aware that the turtle wont work correctly if it doesnt have fuel in it anymore!

#### 6 - Slots
If you are using double chests or an other type of chest from an other mode, you can set the amount of slots in them here. This will keep the overview for the turtle and sends you a message if a chest is full.

#### 7 - Options
Change your password, the turtle id and the welcome text here.

#### 8 - Get Info
Checks if the turtle has everything it needs. You shouldn't ignore this one, so hit it everytime until it says it is fine.

#### 9 - Help
Links you back to this forum post. Just in case, if someone needs serious help :s

#### 0 - Quit
Quits just the computer program. You have to terminate the turtle program by holding STRG + T for some seconds.


#### Advanced Usage:
You can place an enderchest down and have the turtle and computer saperated. Be aware that the turtle and computer have to be in range to communicate over rednet with each other.

On the bottom left of the admin menu, you can see the computer id.

You can delete all trades by tiping in the computer's and turtle's screen:

delete ttsVariables

delete ttsTrades

If the turtle says "access denied", reboot your computer/turtle and try again.

If the computer doesnt react anymore, shutdown the turtle and the computer with STRG + T and restart them again. If the problem still occurs send me a message here!

You can change the side on which the modem of the computer goes in the code itself.
Download the file and edit it with "edit <nameYouGaveTheFile>".
At the first line you can change the "top" to another side: "bottom", "left", "right", "back". Dont forget to use brackets!

The computer safes just the trades, including the amount of the items and the item names. The turtle knows which kind of item and how many are in the chests. I may change this to speed some parts of the purchases for the customer up.


## Updates

### Beta 0.3.0
- added the turtle to detect if a chest cant handle any more items depending on the trade times possible, the insert items, the items left in the chest

### Beta 0.2.0
- improved the text shown; doesnt cut off on the end of the screen
- added individual welcome text feature which gets shown for the customer




## Found a bug, got an error or something didnt worked?

Something is strange or you even get a error message, please fill in this following layout and post it in this post:
Does the problem still occures if tts gets redownloaded:
FTB Version:
Singleplayer or Multiplayer:
Error Code:
What happened:

This is helping me a lot to quickly find where your problem is and hopefully how to fix it. If you get an error please write it down too. Mention which programs you where using and what/how many items in the turtle and chests were.

That's it! I hope i didn't forget anything.
Because the program is still in beta i cant say that it is bugfree!
If there are any questions, suggestions, errors or bugs, feel free to leave a comment to improve this program pack.

Thank you for your attention.

unobtanium