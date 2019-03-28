--MENU
--VARIABLES

local version, savefile = "ULTIMATE WOOD CHOPPER BETA 0.9.5 B", "uwcvariables0.9.2"
local w,h = term.getSize()
local select, distance, turtleslot, menu = 1, 7, 1, 1
local running, chopping, usebonemeal = true, true, true
local savestate, runningProgram = 0, ""
local extremeMode = false
turtle.select(turtleslot)

--VARIABLES
cancelTimer = 2
bonemealTimer = 120
bonemealFirstDelay = 0
amountMaxWoodSlotBonemeal = 14
amountMaxWoodSlotNoBonemeal = 7
amountMinBonemeal = 8
amountMinSaplings = 17
amountMinFuelLevel = 1200
amountFurnaceWoodBonemeal = 16
amountFurnaceWoodNoBonemeal = 8
debugMaxHeight = 55
usebonemeal = true
persistence = true
amountbonemealtimes = 2


function loadVariables()
 local file = fs.open(savefile,"r")
 cancelTimer = tonumber(file.readLine())
 bonemealTimer = tonumber(file.readLine())
 bonemealFirstDelay = tonumber(file.readLine())
 amountMaxWoodSlotBonemeal = tonumber(file.readLine())
 amountMaxWoodSlotNoBonemeal = tonumber(file.readLine())
 amountMinBonemeal = tonumber(file.readLine())
 amountMinSaplings = tonumber(file.readLine())
 amountMinFuelLevel = tonumber(file.readLine())
 amountFurnaceWoodBonemeal = tonumber(file.readLine())
 amountFurnaceWoodNoBonemeal = tonumber(file.readLine())
 debugMaxHeight = tonumber(file.readLine())
 local catchusebonemeal = file.readLine()
 if catchusebonemeal == "true" then usebonemeal = true else usebonemeal = false end
 distance = tonumber(file.readLine())
 local catchpersistence = file.readLine()
 if catchpersistence == "true" then persistence = true else persistence = false end
 amountbonemealtimes = tonumber(file.readLine())
 file.close()
end

function saveVariables()
 local file = fs.open(savefile,"w")
 file.writeLine(cancelTimer)
 file.writeLine(bonemealTimer)
 file.writeLine(bonemealFirstDelay)
 file.writeLine(amountMaxWoodSlotBonemeal)
 file.writeLine(amountMaxWoodSlotNoBonemeal)
 file.writeLine(amountMinBonemeal)
 file.writeLine(amountMinSaplings)
 file.writeLine(amountMinFuelLevel)
 file.writeLine(amountFurnaceWoodBonemeal)
 file.writeLine(amountFurnaceWoodNoBonemeal)
 file.writeLine(debugMaxHeight)
 file.writeLine(usebonemeal)
 file.writeLine(distance)
 file.writeLine(persistence)
 file.writeLine(amountbonemealtimes)
 for i=1,10 do
  file.writeLine("-1")
 end
 file.close()
end

--PRINT

function printCentered(str, ypos)
 term.setCursorPos(w/2 - #str/2, ypos)
 term.write(str)
end

function printRight(str, ypos)
 term.setCursorPos(w-#str, ypos)
 term.write(str)
end

function clearScreen()
 term.clear()
 term.setCursorPos(1,1)
 term.clear()
end

function drawHeader(title, line)
 printCentered(title, line)
 printCentered(string.rep("-", w), line+1)
end

function drawCopyright()
 printRight("by UNOBTANIUM", h)
end



--MENUS

local menupoint = {
{"Chop", "Turtle Interactions", "Build and Expand", "Help", "Credits", "Quit",nil},
{"Farm","Single Tree","Back",nil,nil,nil},
{"Standard Farm","Expanded Farm","Variables","Back",nil,nil,nil},
{"Build the standard farm","Expand the standard farm", "Build the expanded farm", "Add more chests","Back",nil,nil},
{"Standard Farm","Expanded Farm","Back",nil,nil,nil,nil},
{"Position","Dig needed space","Debug","Move Down","Back",nil,nil},
{"Help Programs","Help Interface","Back",nil,nil,nil,nil},
{"General 1x1 Tree","General 2x2 Tree","Back",nil,nil,nil,nil},
{"Movement","Actions","Control","Back",nil,nil,nil,nil},
{"Forward","Back","Up","Down","Turn Left","Turn Right","Back"},
{"Refuel","Dig","Select","Back",nil,nil,nil},
{"Up","Front","Down","Back",nil,nil,nil},
{"Bonemeal","Amount","Timer","Height","Slot","Persistence","Back"}
}

local menupointselected = {
{">> Chop <<", ">> Turtle Interactions <<", ">> Build and Expand <<", ">> Help <<", "> Credits <", "> Quit <",nil},
{">> Farm <<",">> Single Tree <<","> Back <",nil,nil,nil,nil},
{"> Standard Farm <","> Expanded Farm <",">> Variables <<","> Back <",nil,nil,nil},
{"> Build the standard farm <","> Expand the standard farm <", "> Build the expanded farm <","> Add more chests <","> Back <",nil,nil},
{"> Standard Farm <","> Expanded Farm <","> Back <",nil,nil,nil,nil},
{"> Position <","> Dig needed space <",">> Debug <<","> Move Down <","> Back <",nil,nil},
{">> Help Programs <<","> Help Interface <","> Back <",nil,nil,nil,nil},
{"> General 1x1 Tree <","> General 2x2 Tree <","> Back <",nil,nil,nil,nil},
{">> Movement <<",">> Actions <<","> Control <","> Back <",nil,nil,nil},
{"> Forward <","> Back <","> Up <","> Down <","> Turn Left <","> Turn Right <","> Back <"},
{"> Refuel <",">> Dig <<","> Select <","> Back <",nil,nil,nil},
{"> Up <","> Front <","> Down <","> Back <",nil,nil,nil},
{"> Bonemeal <","> Amount <","> Timer <","> Height <","> Slot <","> Persistence <","> Back <"}
}

local menupointnext = {
{2, 9, 4, 7, "credits", "quit"},
{3,8,1},
{"standard","expanded",13,2},
{"build","expand", "buildexpanded","expandchests",1},
{"debugstandard","debugexpanded",6},
{"position","digSpace",5,"godown",7},
{6,"helpinterface",1},
{"onebyone","twobytwo",2},
{10,11,"control",1},
{"forward","back","up","down","left","right",9},
{"refuel",12,"select",9},
{"digup","digfront","digdown",10},
{"varBonemeal","varAmount","varTimer","varHeight","varSlot","varPersistence",3}
}

function drawMenu()
 drawHeader(version, 1)
 if menu == 1 then
  drawCopyright()
 end

 for i=1,7 do
  if menupoint[menu][i] then
   if select == i then
    printCentered(menupointselected[menu][i], i+4)
   else
    printCentered(menupoint[menu][i], i+4)
   end
  end
 end
end


--RUN MENU

function runMenu()
 local showVariableHint = true
 while running do
  clearScreen()
  if menu == 13  and showVariableHint then
   UWCvariables()
   showVariableHint = false
  end
  drawMenu(menu)

  local id, key = os.pullEvent("key")
  if key == 200  or key == 17 then
   select = select-1
  end
  if key == 208 or key == 31 then
   select = select+1
  end

  if select == 0 then
   for i=7,1,-1 do
    if menupoint[menu][i] then
     select = i
     break
    end
   end
  end

  if not menupoint[menu][select] then
   select = 1
  end

  if key == 14 or key == 30 then
   for i=7,1,-1 do
    if menupoint[menu][i] then
     select = i
     break
    end
   end
   if type(menupointnext[menu][select]) == "string" then
    clearScreen()
    running = false
    break
   elseif type(menupointnext[menu][select]) == "number" then
    menu = menupointnext[menu][select]
    for i=7,1,-1 do
     if menupoint[menu][i] then
      select = i
      break
     end
    end
   end
  end

  clearScreen()
  if key == 28 or key == 32 then
   if type(menupointnext[menu][select]) == "string" then
    startProgram(menupointnext[menu][select])
   elseif type(menupointnext[menu][select]) == "number" then
    menu = menupointnext[menu][select]
    select = 1
   end
  end
 end
end

function startProgram(input)
 if input == "quit" then
  running = false
  runningProgram = ""
  saveVariables()
  saveSavePoint(0)
  return
 elseif input == "credits" then
  drawMenuCredits()
 elseif input == "standard" then
  distance = 7
  runningProgram = "standard"
  saveSavePoint(0)
  saveVariables()
  chop()
  runningProgram = ""
  saveVariables()
 elseif input == "expanded" then
  distance = 9
  runningProgram = "expanded"
  saveSavePoint(0)
  saveVariables()
  chop()
  runningProgram = "expanded"
  saveVariables()
 elseif input == "debugstandard" then
  distance = 7
  FWCdebug()
 elseif input == "debugexpanded" then
  distance = 9
  FWCdebug()
 elseif input == "build" then
  FWCbuild()
 elseif input == "buildexpanded" then
  UWCbuildexpanded()
 elseif input == "expand" then
  FWCexpand()
 elseif input == "helpinterface" then
  FWChelp()
 elseif input == "position" then
  FWCposition()
 elseif input == "expandchests" then
  FWCexpandchests()
 elseif input == "onebyone" then
  FWConebyone()
 elseif input == "twobytwo" then
  FWCtwobytwo()
 elseif input == "digSpace" then
  FWCdigSpace()
 elseif input == "forward" then
  turtle.forward()
 elseif input == "back" then
  turtle.back()
 elseif input == "up" then
  turtle.up()
 elseif input == "down" then
  turtle.down()
 elseif input == "left" then
  turtle.turnLeft()
 elseif input == "right" then
  turtle.turnRight()
 elseif input == "refuel" then
  turtle.refuel(1)
 elseif input == "select" then
  turtleslot = turtleslot + 1
  if turtleslot > 16 then turtleslot = 1 end
  turtle.select(turtleslot)
 elseif input == "digup" then
  turtle.digUp()
 elseif input == "digfront" then
  turtle.dig()
 elseif input == "digdown" then
  turtle.digDown()
 elseif input == "godown" then
  UWCgodown()
 elseif input == "varBonemeal" then
  varBonemeal()
 elseif input == "varAmount" then
  varAmount()
 elseif input == "varTimer" then
  varTimer()
 elseif input == "varHeight" then
  varHeight()
 elseif input == "varSlot" then
  varSlot()
 elseif input == "varPersistence" then
  varPersistence()
 elseif input == "control" then
  control()
 elseif input == "" then
  runMenu()
  return
 end
end

--LAST SESSION


function saveSavePoint(i)
 sleep(0)
 savestate = i
 local file = fs.open("uwcsavepoint","w")
 file.writeLine(savestate)
 file.writeLine(runningProgram)
 file.close()
end

function loadSavePoint()
 local file = fs.open("uwcsavepoint","r")
 savestate = tonumber(file.readLine())
 runningProgram = file.readLine()
 file.close()
end

function checkForLastSession()
 if not fs.exists("uwcsavepoint") then return end
 if not persistence then return end
 loadSavePoint()
 if savestate == 0 then
  startProgram(runningProgram)
  return
 end
 print("Turtle shutdown while it was working.")
 print("Starting last program")
 print("Stop persistence by pressing any key in the next 5 seconds.")
 local delay = os.startTimer(5)
 while true do
  local event = {os.pullEvent()}
  if event[1] == "timer" then
   break
  elseif event[1] == "char" then
   runningProgram = ""
   saveSavePoint(0)
   return
  end
 end
 print("Continue...")
 print("")
 while savestate > 0 do
  if savestate >= 8 then
   cutWood()
  end
  if savestate == 7 then
   turtle.back()
   saveSavePoint(2)
   turtle.down()
  end
  if savestate == 2 then
   saveSavePoint(4)
   turtle.turnLeft()
  end
  if savestate == 4 then
   saveSavePoint(1)
   turtle.turnLeft()
  end
  if savestate == 3 then
   saveSavePoint(1)
   turtle.turnRight()
  end
  if savestate == 6 then
   saveSavePoint(1)
   turtle.turnRight()
  end
  if savestate == 1 then
   local max = 1
   while not turtle.detect() and max < 15 do turtle.forward() max = max + 1 end
   if max == 15 then saveSavePoint(0) os.shutdown() end
   saveSavePoint(5)
  end
  if savestate == 5 then
   storeWood()
   saveSavePoint(0)
   turtle.turnRight()
  end
 end
 startProgram(runningProgram)
end

--CREDITS

function drawMenuCredits()
 drawHeader(version,1)
 printCentered("all nicknames from the CC forums!!",3)
 printCentered("- IDEA, CODEING & PUBLISHER -",5)
 printCentered("unobtanium",6)
 printCentered("- HELPING WITH CODING -",8)
 printCentered("theoriginalbit, Mtdj2, NitrogenFingers", 9)
 printCentered("- SPECIAL THANKS GOES TO -",11)
 printCentered("Hoppingmad9, xInDiGo, Seleck",12)
 printCentered("Permutation, PhilHibbs, DavEdward ",13)
 read()
 clearScreen()
 drawHeader(version,1)
 printCentered("- MENTIONABLES -",3)
 printCentered("HotGirlEAN, snoxx, steel_toed_boot,",4)
 printCentered("Zagi, Kylun, Kravyn, PhaxeNor, ughzug",5)
 printCentered("sjkeegs, atlas, Minithra, TheFan",6)
 printCentered("grumpysmurf, Quickslash78, lewanator1",7)
 printCentered("behedwin, TESTimonSHOOTER",8)
 printCentered("Kevironi, Fuzzlewhumper, Bigdavie",9)
 printCentered("Viproz, Bigjimmy12, bomanski, punchin",10)
 printCentered("oxgon, ahwtx, zilvar2k11",11)
 printCentered("The_Ianator, Coolkrieger3", 12)
 read()
 clearScreen()
 drawHeader(version,1)
 printCentered(version,1)
 printCentered("And last but not least",6)
 printCentered("You, the users and players :D",7)
 printCentered("Thank you everybody!!!", 10)
 read()
end


--ULTIMATE WOOD CHOPPER PROGRAMS
--VARIABLES
local dirtexpand, pipeexpand, obsidianpipeexpand, blockslot, coal, chest, furnace, dirt, pipe, ironpipe, goldpipe, obsidianpipe, woodenpipe, engine, lever, bonemeal, stone1, stone2, stone3, sapling, fuel = 2,3,4,5,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,3

--MOVE FUNCTIONS

function forward()
 while not turtle.forward() do end
end

function back()
 while not turtle.back() do end
end

function up()
 while not turtle.up() do end
end

function down()
 while not turtle.down() do end
end

--MAIN CHOP PROGRAM FUNCTIONS

function moveForward(j)
 for i = 1,j do
  forward()
 end
end

function moveForwardRemove(j)
 for i = 1,j do
  turtle.dig()
  forward()
 end
end

function getCoal()
 local delay = os.startTimer(cancelTimer)
 print("Taking coal out of the chest!")
 print("If nothing happens the chest has too less materials!")
 print("Press Enter to terminate process!")
 
 while turtle.getFuelLevel() < amountMinFuelLevel do
  event = { os.pullEvent() }
  if event[1] == "timer" and event[2] == delay then
   turtle.select(16)
   turtle.suck()
   if turtle.getItemCount(16) > 0 then  
    turtle.refuel(math.ceil((amountMinFuelLevel - turtle.getFuelLevel())/80))
    turtle.drop()
    if turtle.getItemCount(16) > 0 then
     turtle.select(16)
     turtle.refuel()
    end
    if turtle.getFuelLevel() < amountMinFuelLevel then
     delay = os.startTimer(2)
    end
   else 
    delay = os.startTimer(cancelTimer)
   end
  elseif event[1] == "key" and event[2] == 28 then
   print("Terminated by User!")
   clearScreen()
   runningProgram = ""
   saveSavePoint(0)
   os.reboot()
  end
 end
 print("Succesful!")
end

function getSaplings()
 local taking = true
 local delay = os.startTimer(cancelTimer)
 print("Taking saplings out of the chest!")
 print("If nothing happens the chest has too less materials!")
 print("Press Enter to terminate process!")

 while taking == true do
  event = { os.pullEvent() }
  if event[1] == "timer" and event[2] == delay then
   if turtle.getItemCount(1) > 0 then
    if turtle.getItemCount(2) > 0 then
     turtle.select(1)
     turtle.suck()
     if turtle.getItemCount(3) > 0 then
      turtle.select(3)
      turtle.drop()
     end
    else
     turtle.select(1)
     turtle.suck()
     if turtle.getItemCount(2) > 0 then
      turtle.select(2)
      turtle.drop()
     end    
    end
   else
    turtle.select(1)
    turtle.suck()
   end
   if turtle.getItemCount(3) > 0 then
    print("!!!!!!!!!")
    print("The sapling chest is full! Please take out some stacks, otherwise you lose items! The turtle will drop them!")
    print("!!!!!!!!!")
    turtle.select(3)
    turtle.dropDown()
   end
   if turtle.getItemCount(1) < amountMinSaplings then
    delay = os.startTimer(cancelTimer)
   else
    taking = false
   end
  elseif event[1] == "key" and event[2] == 28 then
   print("Terminated by User!")
   turtle.turnRight()
   forward()
   turtle.turnRight()
   clearScreen()
   runningProgram = ""
   saveSavePoint(0)
   os.reboot()
  end
 end
 print("Succesful!")
end

function getBonemeal()
 local taking = true
 local delay = os.startTimer(cancelTimer)
 print("Taking bonemeal out of the chest!")
 print("If nothing happens the chest has too less materials!")
 print("Press Enter to terminate process!")

 while taking == true do
  event = { os.pullEvent() }
  if usebonemeal == true then
   if event[1] == "timer" and event[2] == delay then
   if turtle.getItemCount(2) > 0 then
    turtle.select(2)
    turtle.suckUp()
    if turtle.getItemCount(3) > 0 then
     turtle.select(3)
     turtle.dropUp()
    end
   else
    turtle.select(2)
    turtle.suckUp()
   end
    if turtle.getItemCount(3) > 0 then
     print("!!!!!!!!!")
     print("The bonemeal chest is full! Please take out some stacks, otherwise you lose items! The turtle will drop them!")
     print("!!!!!!!!!")
     turtle.select(3)
     turtle.dropDown()
    end
    if turtle.getItemCount(2) < amountMinBonemeal then
     delay = os.startTimer(cancelTimer)
    else
     taking = false
    end
   elseif event[1] == "key" and event[2] == 28 then
    print("Terminated by User!")
    turtle.turnRight()
    forward()
    turtle.turnRight()
    clearScreen()
    runningProgram = ""
    saveSavePoint(0)
    os.reboot()
   end
  else
   turtle.select(2)
   turtle.dropUp()
   taking = false
  end
 end
 print("Successful!")
end

function storeWood()
 print("Storing wood in the chests!")
 chestfull = true
 while chestfull == true do
  if usebonemeal == true then
   for i=3,16 do
    if turtle.getItemCount(i) > 0 then
     turtle.select(i)
     chestfull = turtle.drop()
    end
   end
  else
   for i=2,16 do
    if turtle.getItemCount(i) > 0 then
     turtle.select(i)
     chestfull = turtle.drop()
    end
   end
  end

  chestfull = not chestfull
   
  if chestfull == true and turtle.detectUp() == true then
   print("Wood! Wood everywhere!!!")
   print("Your wood chests are full!")
   print("Try to add more vertical chests or take wood out of them.")
   print("")
   chopping = false
   while turtle.detectDown() == false do
    down()
   end
   turtle.turnRight()
  end

  if chestfull == true and turtle.detectUp() == false then
   up()
   print("This Chest is full!")
  end

 end
 
 while turtle.detectDown() == false do
 down()
 end
 
 print("Successful stored the wood!")
 print("")
end

function treeGrew()
 turtle.select(1)
 if turtle.compare() then
  return false
 else
  return true
 end
end

function plantTree()
 if turtle.detect() and treeGrew() then print("There is allready a tree!") return true end
 turtle.select(1)
 if not turtle.detect() then
  print("Planting saplings!")
  turtle.dig()
  forward()
  turtle.dig()
  forward()
  saveSavePoint(6)
  turtle.turnRight()
  turtle.dig()
  while not turtle.place() do sleep(0.5) print("Failed placing a sapling!") end
  saveSavePoint(2)
  turtle.turnLeft()
  back()
  while not turtle.place() do sleep(0.5) print("Failed placing a sapling!") end
  saveSavePoint(6)
  turtle.turnRight()
  turtle.dig()
  while not turtle.place() do sleep(0.5) print("Failed placing a sapling!") end
  saveSavePoint(2)
  turtle.turnLeft()
  back()
  while not turtle.place() do sleep(0.5) print("Failed placing a sapling!") end
  if usebonemeal then
   sleep(bonemealFirstDelay + 0.2)
  end
 end
 while true do
  if usebonemeal then
   if turtle.getItemCount(2) <= amountbonemealtimes + 1 then
    print("Ran out of bonemeal!")
    print("")
    return false
   end
   print("Fertilizing the sapling with bonemeal!")
   turtle.select(2)
   local amountPlaced = 0
   for i=1,amountbonemealtimes do
    if turtle.place() then
     amountPlaced = amountPlaced + 1
    end
    sleep(0.6)
   end
   print("Fertilized the sapling ".. amountPlaced .." times!")
  end
  turtle.select(1)

  if not treeGrew() then
   print("Tree didnt grew yet!")
   if usebonemeal then
    print("Bonemealing again in " .. bonemealTimer .." seconds...")
   else
    print("Check again in " .. bonemealTimer .." seconds...")
   end
   back()
   sleep(bonemealTimer)
   forward()
  else
   print("Successful planted new tree!")
   print("")
   return true
  end
 end
end


function getMaterials()
 saveSavePoint(4)
 turtle.turnLeft()
 saveSavePoint(1)
 turtle.turnLeft()
 moveForward(distance)
 
 turtle.select(3)
 if usebonemeal then
  turtle.dropDown(amountFurnaceWoodBonemeal)
 else
  turtle.dropDown(amountFurnaceWoodNoBonemeal)
 end
 saveSavePoint(5)
 storeWood()

 saveSavePoint(0)
 turtle.turnRight()
    
 if redstone.getInput("back") == false then
  print("Shutdown by redstone signal!")
  chopping = false
  runningProgram = ""
  saveSavePoint(0)
 else
  getCoal()
  saveSavePoint(2)
  turtle.turnRight()
  turtle.forward()
  saveSavePoint(3)
  turtle.turnRight()  
  getSaplings()
  getBonemeal()
  saveSavePoint(2)
  turtle.turnLeft()
  moveForward(distance-1)
 end
end

function chopUp()
 turtle.dig()
 while turtle.detectUp() do
  saveSavePoint(110)
  turtle.digUp()
  saveSavePoint(102)
  up()
  turtle.dig()
 end
end

function chopDown()
 turtle.dig()
 while turtle.detectDown() do
  saveSavePoint(111)
  turtle.digDown()
  saveSavePoint(103)
  down()
  turtle.dig()
 end
end

function cutWood()
 turtle.select(1)
 if savestate == 2 then
  turtle.dig()
  saveSavePoint(100)
  forward()
 end
 if savestate == 100 then
  if turtle.detectUp() then
   print("Chopping down the tree!")
   saveSavePoint(101)
   turtle.turnRight()
  else
   saveSavePoint(2)
   back()
   print("ERROR!!! No tree above!")
   print("Prevented: Digging down to bedrock!")
   return
  end
 end
 if savestate == 101 then
  turtle.dig()
  saveSavePoint(102)
  turtle.turnLeft()
 end
 if savestate == 110 then
  saveSavePoint(102)
  up()
 end
 if savestate == 102 then
  chopUp()
  saveSavePoint(8)
  turtle.turnRight()
 end
 print("Reached the top of the tree!")
 if savestate == 8 then
  turtle.dig()
  saveSavePoint(9)
  forward()
 end
 if savestate == 9 then
  saveSavePoint(103)
  turtle.turnLeft()
 end
 if savestate == 111 then
  saveSavePoint(103)
  down()
 end
 if savestate == 103 then
  chopDown()
  saveSavePoint(104)
  turtle.dig()
 end
 if savestate == 104 then
  saveSavePoint(105)
  down()
 end
 if savestate == 105 then
  saveSavePoint(106)
  turtle.dig()
 end
 if savestate == 106 then
  saveSavePoint(10)
  back()
 end
 print("Successful chopped the tree!")
 print("")
 if savestate == 10 then
  saveSavePoint(11)
  turtle.turnLeft()
 end
 if savestate == 11 then
  saveSavePoint(12)
  forward()
 end
 if savestate == 12 then
  saveSavePoint(2)
  turtle.turnRight()
 end
end





function chop()
 if redstone.getInput("back") == true then
  saveSavePoint(0)
  print("Starting the Fir Wood Chooper program!")
  getCoal()
  if turtle.getItemCount(3) > 0 or turtle.getItemCount(16) > 0 then
   saveSavePoint(1)
   turtle.turnLeft()
   storeWood()
   saveSavePoint(0)
   turtle.turnRight()
  end
  saveSavePoint(2)
  turtle.turnRight()
  forward()
  saveSavePoint(3)
  turtle.turnRight()
  if turtle.getItemCount(1) < amountMinSaplings then
   getSaplings()
  end
  if turtle.getItemCount(2) < amountMinBonemeal and usebonemeal == true then
   getBonemeal()
  end
  if turtle.getItemCount(2) > 0 and usebonemeal == false then
   turtle.select(2)
   turtle.dropUp()
  end
  saveSavePoint(1)
  turtle.turnRight()
  forward()
  saveSavePoint(0)
  turtle.turnRight()
  saveSavePoint(2)
  turtle.turnRight()
  moveForward(distance)
  
  while chopping == true do
   local needMaterials = false
   if turtle.getFuelLevel() < 200 then
    needMaterials = true
    print("Have to refuel!")
   end
   if turtle.getItemCount(1) < amountMinSaplings then
    needMaterials = true
    print("Need more Saplings!")
   end
   if usebonemeal and turtle.getItemCount(2) < amountMinBonemeal then
    needMaterials = true
    print("Need more bonemeal!")
   end
   if usebonemeal and turtle.getItemCount(amountMaxWoodSlotBonemeal) > 0 then
    needMaterials = true
    print("Enough wood harvested!")
   elseif not usebonemeal and turtle.getItemCount(amountMaxWoodSlotNoBonemeal) > 0 then
    needMaterials = true
    print("Enough wood harvested!")
   end
   if needMaterials then
    getMaterials()
   end
   if chopping then
    if plantTree() then
     cutWood()
    end
   end
   sleep(0)
  end
 else
  runningProgram = ""
  saveSavePoint(0)
  print("No redstone signal, no wood!")
  print("Be sure the Turtle is facing the coal chest and stays above the furnace!")
  print("The redstone signal has to be in the back of the Turtle!")
 end
 print("Press Enter to get back into the menu...")
 read()
 chopping = true
end

--MAIN DEBUG FUNCTIONS

function FWCdebug()
 getCoal()
 turtle.turnRight()
 moveForward(distance)
 local height = 0
 turtle.select(1)
 turtle.dig()
 forward()
 turtle.dig()
 while not turtle.detectUp() and height < debugMaxHeight do
  turtle.up()
  height = height + 1
 end
 turtle.dig()
 while turtle.detectUp() do
  turtle.digUp()
  turtle.up()
  turtle.dig()
  height = height + 1
 end
 turtle.turnRight()
 turtle.dig()
 forward()
 turtle.turnLeft()
 turtle.dig()
 while height > 0 do
  turtle.digDown()
  down()
  turtle.dig()
  height = height - 1
 end
 back()
 turtle.turnLeft()
 forward()
 turtle.turnLeft()
 moveForward(distance)
 turtle.turnRight()
 print("Debug finished! Please take the wood out of the inventory!")
 print("Press Enter to get back into the menu!")
 read()
end

-- MOVEMENT FUNCTIONS

function dbp(j) -- dig down, place down, back (dig), place
 j = j or 1
 for i=1,j do
  turtle.digDown()
  turtle.placeDown()
  db()
  turtle.place()
 end
end

function lb() -- left, back (dig)
 turtle.turnLeft()
 db()
end

function db() -- back (dig)
 if not turtle.back() then
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.dig()
  turtle.forward()
  turtle.turnLeft()
  turtle.turnLeft()
 end
end

function bp(j) -- back (dig), place
 j = j or 1
 for i=1,j do
  db()
  turtle.place()
 end
end

function checkBlocks()
 if turtle.getItemCount(blockslot) == 0 and blockslot < 10 then
  blockslot = blockslot + 1
  turtle.select(blockslot)
 end
end

function fd(j) -- forward (dig)
 j = j or 1
 for i=1, j do
  if turtle.detect() then
   turtle.dig()
  end
 turtle.forward()
 end
end

function fdown(j) -- forward, placeDown (digDown)
 j = j or 1
 for i=1,j do
  if not turtle.forward() then
   turtle.dig()
   turtle.forward()
  end
  if turtle.detectDown() then
   turtle.digDown()
  end
  turtle.placeDown()
 end
end

function fde(j,check) -- forward (dig), digUp, digDown, checkBlocks, placeDown
 j = j or 1
 check = check or true
 for i=1,j do
  dfd(1)
  if check then
   checkBlocks()
  end
  turtle.placeDown()
 end
end

function dfd(j) -- forward (dig), digUp, digDown
 j = j or 1
 for i=1,j do
  df(1)
  turtle.digDown()
 end
end

function df(j) -- forward (dig), digUp
 j = j or 1
 for i=1,j do
  if turtle.detect() then
   turtle.dig()
  end
  forward()
  turtle.digUp()
 end
end

function dd() -- digDown, down
 turtle.digDown() 
 turtle.down()
end

function du() -- digUp, up
 turtle.digUp()
 turtle.up()
end





-- BUILD FUNCTIONS

function buildBase(standard)
 turtle.select(stone3)
 if not standard then
  entrance()
  dd()
  dd()
  moveForward(2)
  turtle.dig()
  turtle.place()
  turtle.turnLeft()
  db()
  turtle.place()
  du()
  du()
  turtle.turnLeft()
  turtle.turnLeft()
 end
 turtle.placeDown()
 turtle.turnLeft()
 turtle.select(chest)
 turtle.place()
 turtle.select(sapling)
 turtle.drop()
 turtle.turnRight()
 turtle.select(chest)
 turtle.placeUp()
 turtle.select(bonemeal)
 turtle.dropUp()
 forward()
 turtle.select(chest)
 turtle.place()
 du()
 turtle.place()
 du()
 turtle.place()
 turtle.select(stone3)
 turtle.placeUp()
 
 dd()
 dd()
 dd()
 turtle.turnRight()
 turtle.select(woodenpipe)
 turtle.place()
 turtle.turnLeft()
 dd()
 turtle.select(furnace)
 turtle.placeUp()
 turtle.select(coal)
 turtle.dropUp(1)
 turtle.select(ironpipe)
 turtle.dig()
 turtle.place()
 lb()
 turtle.select(pipe)
 turtle.place()
 turtle.turnLeft()
 db()
 turtle.select(goldpipe)
 turtle.place()
 du()
 du()
 turtle.select(chest)
 turtle.place()
 turtle.select(coal)
 turtle.drop(1)
 turtle.select(engine)
 turtle.placeDown()
 db()
 turtle.select(stone3)
 turtle.placeDown()
 lb()
 turtle.select(lever)
 turtle.place()
 db()
 turtle.turnRight()
 moveForward(2)
 dd()
 turtle.select(pipe)
 turtle.dig()
 turtle.place()
 dd()
 turtle.dig()
 turtle.place()
 dd()
 if standard then
  fd(2)
  turtle.select(obsidianpipe)
  turtle.place()
  db()
  turtle.select(pipe)
  turtle.place()
  db()
 end
 turtle.place()
 
 turtle.turnLeft()
 du()
 du()
 du()
 turtle.select(stone3)
 turtle.placeDown()
 fd()
 turtle.turnRight()
 turtle.turnRight()
 turtle.select(lever)
 turtle.place()
 turtle.turnRight()
 turtle.turnRight() 
end

function entrance()
 moveForward(2)
 turtle.turnRight()
 fd()
 turtle.placeUp()
 dbp(1)
 turtle.placeUp()
 turtle.digDown()
 turtle.placeDown()
 db()
 turtle.placeUp()
 dbp(1)
end


function FWCbuild()
 if turtle.detectDown() then
  print("There is a block underneath the turtle.")
  print("Be sure you have free space under the turtle.")
  print("Press Enter to get back to the menu.")
  read()
  return false
 end
 turtle.select(coal)
 for i=1,fuel do
  while not turtle.refuel(1) do print("Refuel didnt worked.") sleep(1) end
 end
 turtle.select(stone1)
 entrance()
 dd()
 dd()
 turtle.turnLeft()
 turtle.turnLeft()
 fd()

 dbp(4)
 turtle.select(stone1)
 bp(1)
 
 dbp(3)
 
 lb()
 dbp(2)
 bp(8)
 
 lb()
 bp(8)
 
 lb()
 bp(8)
 dbp(1)
 turtle.digDown()
 turtle.placeDown()
 turtle.turnLeft()
 bp(1) 
 
 turtle.turnRight()
 turtle.turnRight()
 dd()
 turtle.digDown()
 turtle.placeDown()
 fde(7,false)
 turtle.turnLeft()
 fde(1,false)
 turtle.turnLeft()
 turtle.select(stone1)
 fde(7,false)
 
 turtle.select(stone2)
 turtle.turnRight()
 du()
 fdown(1)
 for i = 1,4 do
  fdown(7)
  turtle.turnRight()
  fdown(1)
  turtle.turnRight()
  fdown(7)
  if i < 4 then
   turtle.turnLeft()
   fdown(1)
   turtle.turnLeft()
  end
 end
 
 turtle.select(stone3)
 du()
 du()
 turtle.turnRight()
 moveForward(3)
 turtle.turnRight()
 moveForward(2)
 turtle.select(dirt)
 fdown(2)
 turtle.turnLeft()
 fdown(1)
 turtle.turnLeft()
 fdown(1)
 moveForward(7)

 buildBase(true)
 
 print("Finally set up the farm! Enjoy!")
 print("Flip the lever for the redstone engine.")
 print("")
 print("Press Enter to get back into the menu!")
 read()
end

-- EXPAND FUNCTIONS

function destroy()
 turtle.turnRight()
 moveForward(3)
 dd()
 dd()
 dd()
 turtle.turnRight()
 turtle.select(obsidianpipeexpand)
 fd()
 turtle.turnRight()
 turtle.select(pipeexpand)
 fd()
 turtle.select(blockslot)
 turtle.turnLeft()
 df(3)
 turtle.select(16)
 turtle.dig()
 turtle.forward()
 turtle.select(blockslot)
 turtle.turnLeft()
 du()
 dfd(2)
 df(9)
 turtle.turnLeft()
 df(9)
 turtle.turnLeft()
 df(8)
 dfd(2)
 if turtle.detectDown() then
  turtle.select(16)
  turtle.digDown()
  turtle.select(blockslot)
 end
 dd()
 if turtle.detectDown() then
  turtle.select(16)
  turtle.digDown()
  turtle.select(blockslot)
 end
 dd()
 turtle.turnLeft()
 df(8)
 turtle.turnLeft()
 df(1)
 turtle.turnLeft()
 df(7)
 turtle.turnRight()
 du()
 df(1)
 for i=1,4 do
  df(7)
  turtle.turnRight()
  df(1)
  turtle.turnRight()
  df(7)
  if i < 4 then
   turtle.turnLeft()
   fd()
   turtle.turnLeft()
  end
 end
 forward()
end

function layout(expanding)
 turtle.select(blockslot)
 if expanding then
  forward()
  du()
  du()
  du()
  fd()
  turtle.turnLeft()
  db()
  db()
 end
 turtle.digDown()
 turtle.placeDown()
 fde(7)
 for i=1,3 do
  turtle.turnLeft()
  fde(7)
  df()
  dd()
  turtle.digDown()
  turtle.placeDown()
  fde(1)
  du()
  db()
  turtle.digDown()
  turtle.placeDown()
  fde(9)
 end
 turtle.turnLeft()
 fde(6)
 turtle.turnLeft()
 df()
 turtle.turnRight()
 for i=1,10 do
  df()
 end
 turtle.turnLeft()
 for i=1,8 do
  df()
 end
end

function corners()
 dd()
 for i=1,4 do
  fde(7)
  turtle.turnLeft()
  fde(6)
  turtle.turnLeft()
  df()
  turtle.turnLeft()
  fde(5)
  turtle.turnRight()
  fde(4)
  turtle.turnRight()
  df()
  turtle.turnRight()
  fde(3)
  turtle.turnLeft()
  fde(2)
  db()
  turtle.turnLeft()
  fde(1)
  turtle.turnRight()
  turtle.turnRight()
  for i=1,3 do
   df()
  end
  turtle.turnLeft()
  for i=1,5 do
   df()
  end
 end
end

function lines(j)
 fde(j)
 db()
 turtle.turnLeft()
 fde(1)
 turtle.turnLeft()
 fde(j-2)
 if j > 4 then
  db()
  turtle.turnRight()
  fde(1)
  turtle.turnRight()
  lines(j-4)
 end
end

function plateau()
 dd()
 db()
 turtle.digDown()
 turtle.placeDown()
 turtle.turnLeft()
 lines(15)
 turtle.turnLeft()
  for i=1,8 do
   df()
  end
 turtle.turnLeft()
  for i=1,8 do
   df()
  end
 turtle.turnRight()
 turtle.turnRight()
 turtle.digDown()
 turtle.placeDown()
 lines(15)
end

function pipeAndDirt()
 db()
 turtle.turnLeft()
 moveForward(9)
 turtle.select(dirtexpand)
 turtle.digUp()
 fd()
 turtle.digUp()
 turtle.turnRight()
 fd()
 turtle.digUp()
 turtle.turnRight()
 fd()
 turtle.digUp()
 fd()
 turtle.placeUp()
 fd()
 turtle.placeUp()
 turtle.turnRight()
 fd()
 turtle.placeUp()
 turtle.turnRight()
 fd()
 turtle.placeUp()
 dd()
 turtle.select(obsidianpipeexpand)
 turtle.placeUp()
 dd()
 turtle.select(pipeexpand)
 turtle.placeUp()
 for i=1,10 do
  fd()
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.place()
  turtle.turnLeft()
  turtle.turnLeft()
 end
 fd()
 for i=1,5 do
  du()
 end
 db()
 turtle.turnRight()
 fd()
 dd()
end

-- EXPAND

function FWCexpand()
 print("Expanding farm!")
 print("The refueling needs around 8 coal!")
 while turtle.getFuelLevel() < 600 do
  turtle.select(coal)
  if turtle.refuel(1) then
   print("Refueling!")
  else
   print("Didn't refueled!")
   sleep(1)
  end
 end
 blockslot = 5
 destroy()
 layout(true)
 corners()
 plateau()
 pipeAndDirt()
 print("Finished!")
 print("Press Enter to get back into the menu!")
 read()
end

-- UWC BUILD EXPANDED FARM RIGHT AWAY

function UWCbuildexpanded()
 local doesItDig = true
 if turtle.detectDown() then
  print("There is a block underneath the turtle.")
 end
 print("Do you want the turtle to dig the needed space for you?")
 print("Y/N")
 local id, key = os.pullEvent("key")
 if key == 49  then
  doesItDig = false
  print("Start building!")
  turtle.turnLeft()
  turtle.turnLeft()
 end
 if doesItDig then
  turtle.select(1)
  print("Place a charcoal in slot 1 (top left, the selected one)")
  while turtle.getItemCount(1) == 0 do sleep(1) end
  print("Start building and digging!")
  turtle.refuel(1)
  sleep(1)
  du()
  db()
  db()
  dd()
  UWCdigBaseSpace()
  forward()
  turtle.turnLeft()
  forward()
  for i=1,16 do
   if turtle.getItemCount(i) > 0 then
    turtle.select(i)
    turtle.drop()
   end
  end 
 end
 sleep(1)
 for i=1,16 do
  turtle.select(i)
  turtle.suck()
 end
 turtle.select(1)
 turtle.refuel(8)
 turtle.turnLeft()
 turtle.turnLeft()
 buildBase(false)
 turtle.turnLeft()
 for i=4,5 do
  turtle.select(i)
  turtle.transferTo(i-2)
 end
 turtle.select(8)
 turtle.transferTo(4)
 for i=13,15 do
  turtle.select(i)
  turtle.transferTo(i-8)
 end
 turtle.select(5)
 for i=1,3 do
  turtle.suck()
 end
 turtle.turnLeft()
 turtle.turnLeft()
 moveForward(3)
 turtle.turnRight()
 moveForward(2)
 turtle.turnRight()
 fd()
 turtle.turnLeft()
 blockslot = 5
 layout(false)
 corners()
 plateau()
 pipeAndDirt()
 print("Finished building the expanded farm!")
 print("Please take ALL items out of the inventory!")
 print("Press Enter to get back into the menu!")
 read()
end


--FWChelp 77777777777777777777777777777777777777777

function FWChelp()
 print("Welcome to the UWC Help Interface!")
 print("If you have any question, suggestions, bugs or feedback, let me know: Type")
 print("computercraft forum ultimate wood chopper")
 print("in Google and write a post or PM at me ;D")
 read()
end

--FWCposition 999999999999999999999999999999999999

function FWCposition()
 turtle.select(coal)
 turtle.refuel(1)
 up()
 up()
 up()
 up()
 turtle.turnRight()
 forward()
 forward()
 forward()
 forward()
 turtle.turnLeft()
 forward()
 forward()
 print(" ")
 print("Turtle in Base. Ready to set up farm.")
 print("Be sure the turtle has all the materials it needs.")
 print("Press Enter to get back into the menu.")
 read()
end

--FWCexpandchests

function FWCexpandchests()
 print("Adding more chests!")
 local amount = turtle.getItemCount(2)
 turtle.turnLeft()
 while not turtle.detectUp() do 
  turtle.up()
 end
 turtle.select(3)
 turtle.digUp()
 turtle.select(2)
 while amount > 0 do
  up()
  turtle.place()
  amount = amount-1
 end
 turtle.select(3)
 turtle.placeUp()
 while turtle.down() do end
 turtle.turnRight()
 print("Finsihed!")
 print("Press Enter to get back into the menu.")
 read()
end

--FWCtwobytwo

function FWCtwobytwo()
 print("Chopping down 2x2 tree.")
 while turtle.getFuelLevel() < 200 do
  sleep(2)
  turtle.select(1)
  turtle.refuel(1)
  print("Refueled!")
 end
 savestate = 2
 cutWood()
 print("Press Enter to get back into the menu.")
 read()
end

--FWConebyone

function FWConebyone()
 print("Chopping down 1x1 tree.")
 while turtle.getFuelLevel() < 200 do
  sleep(2)
  turtle.select(1)
  turtle.refuel(1)
  print("Refueled!")
 end
 turtle.select(2)
 turtle.dig()
 forward()
 while turtle.compareUp() do
  turtle.digUp()
  up()
 end
 while not turtle.detectDown() do
  turtle.down()
 end
 print("Finsihed!")
 print("Press Enter to get back into the menu.")
 read()
end

--FWCdigSpace

function UWCdigBaseSpace()
 turtle.turnLeft()
 forward()
 turtle.turnRight()
 dd()
 dd()
 for i=1,3 do
  for j=1,4 do
   turtle.dig()
   forward()
   turtle.digUp()
  end
  if i<3 then
   for j=1,4 do
    back()
   end
   turtle.turnRight()
   turtle.dig()
   forward()
   turtle.digUp()
   turtle.turnLeft()
  end
 end
 back()
 turtle.digDown()
 db()
 turtle.digDown()
 df()
 up()
 up()
 turtle.turnLeft()
end

function FWCdigSpace()
 os.sleep(2)
 turtle.select(1)
 turtle.refuel(5)
 back()
 back()
 UWCdigBaseSpace()
 moveForward(5)
 turtle.turnRight()
 forward()
 turtle.digDown()
 down()
 turtle.digDown()
 down()
 turtle.digDown()
 for i=1,5 do
  for j=1,11 do
   turtle.dig()
   turtle.forward()
   turtle.digUp()
   turtle.digDown()
  end
  turtle.turnRight()
  turtle.dig()
  turtle.forward()
  turtle.turnRight()
  turtle.digUp()
  turtle.digDown()
  for j=1,11 do
   turtle.dig()
   turtle.forward()
   turtle.digUp()
   turtle.digDown()   
  end
  if i < 5 then
   turtle.turnLeft()
   turtle.dig()
   turtle.forward()
   turtle.turnLeft()
   turtle.digDown()
   turtle.digUp()
  end
 end
 turtle.back()
 turtle.turnRight()
 turtle.forward()
 turtle.down()
 turtle.digDown()
 turtle.down()
 for i=1,8 do
  turtle.turnRight()
  turtle.dig()
  turtle.turnLeft()
  turtle.dig()
  turtle.forward()
 end
 turtle.turnLeft()
 turtle.up()
 turtle.up()
 turtle.up()
 turtle.up()
 turtle.turnLeft()
 moveForward(4)
 turtle.turnRight()
 moveForward(3)
 turtle.turnLeft()
 turtle.turnLeft()
 print("Finished!")
 print("Press Enter to get back into the menu!")
 read()
end

-- VARIABLE CHANGE MENU

function varBonemeal()
 local input = 0

 print("Bonemeal")
 print("Should the turtle take out bonemeal of the chest and use it on the tree to get wood faster?")
 print("If not the turtle will wait until the tree is fully grown.")
 print("Standard: true")
 print("Use bonemeal: 1")
 print("Dont use bonemeal: 0")
 print("Current: " .. tostring(usebonemeal))
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input == 1 then usebonemeal = true
  elseif input == 0 then usebonemeal = false end
 end
 clearScreen()

 print("Set to: " .. tostring(usebonemeal))
 print("")
 print("Bonemeal")
 print("How many bonemeal should be used on the tree at the same time if the turtle should use it?")
 print("Standard: 2")
 print("Minimum: 1")
 print("Maximum: 10")
 print("Current: " .. amountbonemealtimes)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 1 and input <= 10 then amountbonemealtimes = input end
 end
 clearScreen()

 print("Set to: " .. amountbonemealtimes)
 print("")
 print("Saving variables...")
 saveVariables()
 sleep(0.2)
 print("Saved variables!")
 sleep(0.2)
end

function varAmount()
 local input = 0

 print("Amount")
 print("Turtle needs this amount or more bonemeal in slot 2 before keep going.")
 print("Standard: 8")
 print("Minimum: 3 Maximum: 64")
 print("Current: " .. amountMinBonemeal)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input > 2 and input < 65 then amountMinBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountMinBonemeal)
 print("")
 print("Amount")
 print("Turtle needs this amount or more saplings in slot 1 before keep going.")
 print("Standard: 17")
 print("Minimum: 5 Maximum: 64")
 print("Current: " .. amountMinSaplings)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input > 4 and input < 65 then amountMinSaplings = input end
 end
 clearScreen()

 print("Set to: " .. amountMinSaplings)
 print("")
 print("Amount")
 print("After chopping down trees, the turtle places some wood into the furnace.")
 print("How many wood should be put into the furnace if bonemeal is used?")
 print("Standard: 16")
 print("Minimum: 0  Maximum: 64")
 print("Current: " .. amountFurnaceWoodBonemeal)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 and input < 65 then amountFurnaceWoodBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountFurnaceWoodBonemeal)
 print("")
 print("Amount")
 print("After chopping down trees, the turtle places some wood into the furnace.")
 print("How many wood should be put into the furnace if no bonemeal is used?")
 print("Standard: 8")
 print("Minimum: 0  Maximum: 64")
 print("Current: " .. amountFurnaceWoodNoBonemeal)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 and input < 65 then amountFurnaceWoodNoBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountFurnaceWoodNoBonemeal)
 print("Amount")
 print("At base the turtle refuels charcoal up to this fuel level before chopping down more trees.")
 print("Standard: 1200")
 print("Set this to 0 if you dont want the turtle to use coal!")
 print("Current: " .. amountMinFuelLevel)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 then amountMinFuelLevel = input end
 end
 clearScreen()

 print("Set to: " .. amountMinFuelLevel)
 print("")
 print("Saving variables...")
 saveVariables()
 sleep(0.2)
 print("Saved variables!")
 sleep(0.2)
end

function varTimer()
 local input = 0

 print("Timer")
 print("Turtle fails to take enough materials out of a chest.")
 print("How long does he waits until it tries again?")
 print("In this time the turtle can be terminated by the user.")
 print("Standard: 2")
 print("Minimum: 1")
 print("Current: " .. cancelTimer)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 1 then cancelTimer = input end
 end
 clearScreen()

 print("Set to: " .. cancelTimer)
 print("")
 print("Timer")
 print("Turtle fails to fertilize the tree with bonemeal.")
 print("How long should it wait until it tries again?")
 print("Standard: 120")
 print("Current: " .. bonemealTimer)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 then bonemealTimer = input end
 end
 clearScreen()
 
 print("Set to: " .. bonemealTimer)
 print("")
 print("Timer")
 print("Turtle planted the saplings.")
 print("How long should the turtle wait before fertilizing the first time?")
 print("Standard: 0")
 print("Current: " .. bonemealFirstDelay)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 then bonemealFirstDelay = input end
 end
 clearScreen()

 print("Set to: " .. bonemealFirstDelay)
 print("")
 print("Saving variables...")
 saveVariables()
 sleep(0.2)
 print("Saved variables!")
 sleep(0.2)
end

function varSlot()
 local input = 0

 print("Slot")
 print("Turtle goes back to base if the inventory slot has items in it.")
 print("Which slot should it be if the turtle uses bonemeal?")
 print("Standard: 14")
 print("Minimum: 3  Maximum: 16")
 print("Current: " .. amountMaxWoodSlotBonemeal)
 turtle.select(tonumber(amountMaxWoodSlotBonemeal))
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 3 and input <= 16 then amountMaxWoodSlotBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountMaxWoodSlotBonemeal)
 print("")
 print("Slot")
 print("Turtle goes back to base if inventory slot has items in it.")
 print("Which slot should it be if the turtle doesnt use bonemeal?")
 print("Standard: 7")
 print("Minimum: 2  Maximum: 16")
 print("Current: " .. amountMaxWoodSlotNoBonemeal)
 turtle.select(tonumber(amountMaxWoodSlotNoBonemeal))
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 2 and input <= 16 then amountMaxWoodSlotNoBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountMaxWoodSlotNoBonemeal)
 print("")
 print("Saving variables...")
 saveVariables()
 sleep(0.2)
 print("Saved variables!")
 sleep(0.2)
end

function varHeight()
 local input = 0

 print("Height")
 print("If the turtle debugs the farm, it checks how height it is.")
 print("At which height should it turn back down?")
 print("Standard: 55")
 print("Minimum: 1  Maximum: 200")
 print("Current: " .. debugMaxHeight)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input > 0 and input < 201 then debugMaxHeight = input end
 end
 clearScreen()

 print("Set to: " ..debugMaxHeight)
 print("")
 print("Saving variables...")
 saveVariables()
 sleep(0.2)
 print("Saved variables!")
 sleep(0.2)
end

function varPersistence()
 print("Persistence")
 print("If the turtle shutdown, because the chunk unload, while running a farm program the turtle restarts where it was left and keeps going. Because this might cause trouble in server, you can turn it on and off here by opening up this screen.")
 print("")
 persistence = not persistence
 term.write("Persistence is ")
 if persistence then
  print("ENABLED!")
 else
  print("DISABLED!")
 end
 print("")
 print("Saving variables...")
 saveVariables()
 sleep(0.2)
 print("Saved variables!")
 sleep(7)
end


function UWCvariables()
 print("Welcome in the variable change menu.")
 print("You have the choice to individualise your chopping turtle.")
 print("These variables are just used for the farm and get saved and loaded every time.")
 read()
 print("Select a type of variables and you are getting shown the variables one by one.")
 read()
 print("If you want to skip a variable and leave it where it is, you just have to press Enter.")
 read()
 print("If you want to change a variable, type in the number and press Enter.")
 print("Press Enter to continue...")
 read()
 clearScreen()
end


function UWCgodown()
 while not turtle.detectDown() do
  turtle.down()
 end
end

function control()
 local blockslot = 1
 local mode = "move"
 local working = true
 turtle.select(blockslot)

 function info()
  clearScreen()
  print("Navigate your turtle with your keyboard.")
  print("W A S D --- Horizontal")
  print("Space SHIFT --- Vertical")
  print("E --- Switch between dig mode/ place mode/ move mode")
  print("Q --- Select next slot")
  print("Strg --- Leave the conrol interface.")
  print("")
  print("Turtle Mode: " .. mode)
 end

 while working do
  info()
  local id, key = os.pullEvent("key")
  if key == 29 then
   working = false
  elseif key == 16 then
   blockslot = blockslot + 1
   if blockslot == 17 then
    blockslot = 1
   end
   turtle.select(blockslot)
  elseif key == 30 then
   turtle.turnLeft()
  elseif key == 31 then
   turtle.back()
  elseif key == 32 then
   turtle.turnRight()

  elseif mode == "move" then
   if key == 17 then
    turtle.forward()
   elseif key == 57 then
    turtle.up()
   elseif key == 42 then
    turtle.down()
   elseif key == 18 then
    mode = "dig"
   end

  elseif mode == "dig" then
   if key == 17 then
    turtle.dig()
   elseif key == 57 then
    turtle.digUp()
   elseif key == 42 then
    turtle.digDown()
   elseif key == 18 then
    mode = "place"
   end

  elseif mode == "place" then
   if key == 17 then
    turtle.place()
   elseif key == 57 then
    turtle.placeUp()
   elseif key == 42 then
    turtle.placeDown()
   elseif key == 18 then
    mode = "move"
   end
  end
 end
end


--MAIN PROGRAM

if fs.exists(savefile) then
 loadVariables()
end

checkForLastSession()

while running == true do
 runMenu()
end