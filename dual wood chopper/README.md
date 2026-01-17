CC Forum Post: https://web.archive.org/web/20230213150646/https://www.computercraft.info/forums2/index.php?/topic/16495-dual-wood-chopper-session-persistence/#entry158371

CC Forum Post Text:

Hello everybody,

some of you might know me allready, some probably dont. I am around here (in the forums) for exactly ONE year.
On 28 December 2012 i also released my first program Fir Wood Chopper, which i improved in hundrets of hours to make it what is is today: Ultimate Wood Chopper.
So there are two "birthdays" to celebrate. And i have invented something for this day. Some say "Back to the roots" but i say this time "Improve the old".
So here it is:


# Dual² Wood Chopper

## What is Dual Wood Chopper?
This is my second wood chopping program. This time i focused on even more wood gathering speed to maximize your wood income. For this, i use two wireless mining turtles which communicate to chop down the tree simultaneously - one from above, one from below.
This program is just for 2x2 trees only. I recommand Fir Trees because of their special and unique behaviour.
Unfortunatly this program might be full of bugs and errors and i am going to fix and improve the program as i go.
I am happy if you test and use it to help me out with the beta testing.

## Dual Wood Chopper Beta 0.2
Pastebin:
yLxLmMaz

### How to install:
Craft yourself two wireless mining turtles. Try to fuel them both.
Give each turtle a (different) name by tiping in the turtle's screen:
label set turtle1

Download the program by tiping:
<code>pastebin get yLxLmMaz startup</code>

Start the program with:
<code>startup</code>

### Menu Usage:
You will end up in the main menu.

Use the W and S key to switch throught the menu options.

Press D to activate the selected option.

Press S to return into the last menu or exit the program.

No support for arrow keys at the moment.


### Start
#### -> Chop
Start this program if the turtle is on the ground and the second turtle up in the sky waiting.
The turtle will take saplings and bonemeal to create a tree and start chopping it down.
The second turtle in the sky is going to chop the tree down from above.
#### -> Go up
This program lets the turtle move up into the sky to the waiting spot.
It will then start chopping down any trees under it.
#### -> Build layout
Builds the layout with the given materials.

### Options
#### -> Number Values
Changethe values of the program to fit every tree and need.
#### -> Boolean Values
Turn various options on and off.

### Statistics
This opens up a statistic overview about all the materials gathered, created and used.




### How to setup (Automatically):
Instead of manually building the layout, you can let the turtle do the job.
Under Start -> Build layout you place the needed materials one by one by the turtle's explanations into the correct slots.
Then it will dig out the needed space and place everything correct.
The only thing you need is the flat ground. The turtle goes where the bonemeal chest is going to be and in front the tree will grow.




### How to setup (Manually):

You need three chests which dont connect (iron chests, normal and trap chests, ect.) and place them in a corner.
Place down a furnace and leave a hole in the ground to let the turtle get underneath and access it.
You need at least 2x2 dirt or grass blocks where the saplings are going to be placed.
The On/Off lever goes on the left of the bonemeal chest.

### How to start gaining wood:

Install the program like descriped above and be sure both turtles are fueled enough.
Start the program and set all your variables or leave them as they are.
With Start -> Go up you let the turtle go on position by moving up.
Place down the second turtle where the first turtle was before (like on the picture above).
Set the variables exactly the same or leave them as they are.
Be sure all your sapling and bonemeal chests are filled up.
Then start the program with Start -> Chop and the turtle will take out saplings, plant a 2x2 tree and bonemeal it.
And as soon as the tree grew it will start chopping down the tree simultaneously with the second turtle for maximum wood gaining speed.


### Variables and their meaning:
#### Height:
The turtles travel a given amount of blocks up and later down while chopping the tree.
Depending on the maximal height of your tree, this can be change to improve fuel usage.
#### Bonemeal Interval:
If the case happens that bonemealing didnt had the effect of growing the tree, the turtle will wait this amount of seconds until it tries again.
#### Waiting to Grow:
If the turtle doesnt use bonemeal it will wait a given amount of seconds before checking if the tree grew or not.
#### Tree Interval:
Before starting to place saplings the turtle waits these seconds. Just in case this farm produces too much wood ^^'
#### Redstone Ticks:
After the tree grew the turtle moves forward one block underneath the tree and pulses a redstone signal down into the dirt block. You can use this to trigger some kind of machine if you want to. Be aware that the turtle will wait this amount of time.
Every second has 10 redstone ticks.
#### #### Session Persistence:
This will automatically start where the turtle was shutdown when the chunk got unload.
For optimal use you should name the program startup and it will automatically resume.
#### Bonemeal Usage:
The turtle will take out bonemeal from the chest underneath it and bonemeal the tree to increase the growing speed of the tree.
#### Extended Tracking:
While chopping the tree this shows every action the turtle does on the screen. Good for bugfixing, but can effect the speed in the long run.


## Updates:
### Beta 0.2 30.12.2013 02:15
- fixed refuel cycle
- added statistic overview
- added build layout program
- added header in the menues
- added redstone signal pulse before going to chop
- added information about the build layout program and the individual variables

## To-Do:
- send changes to the variables to the second turtle up in the air
- maybe a computer to controll both turtles
- a video to present everything better
- a wild bug appears... unobtanium uses bug-fixing... it was very effective!!!

Hope you enjoy :D

unobtanium