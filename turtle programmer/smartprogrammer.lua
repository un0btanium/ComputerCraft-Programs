version = "Smart Programmer 0.2.1"
running = true
w,h = term.getSize()
select = 1
a, b, c, d, e, f, z = 6,7,8,9,10,11,h-2
newroute ,route = {}, {}
listOfRoutes = {}
runningRoute = ""
currentPoint= 0
currentStepPoint = 1


--PRINT

function printCentered(str, ypos)
 term.setCursorPos(w/2 - #str/2, ypos)
 term.write(str)
end

function drawCopyright()
 local str = "by UNOBTANIUM"
 term.setCursorPos(w-#str, h)
 term.write(str)
end

function drawHeader(title, line)
 printCentered(title, line)
 printCentered(string.rep("-", w), line+1)
end

function clearScreen()
 term.clear()
 term.setCursorPos(1,1)
 term.clear()
end

--SAVE & LOAD & DELETE

function saveListOfRoutes()
 local file = fs.open("listOfRoutes", "w")
 for i=1, countArray(listOfRoutes) do
  file.writeLine(listOfRoutes[i])
 end
 file.close()
end

function loadListOfRoutes()
 if fs.exists("listOfRoutes") then
  local file = fs.open("listOfRoutes", "r")
  local line = file.readLine()
  local j = 1
  while line do
   listOfRoutes[j] = line
   j = j + 1
   line = file.readLine()
  end
  file.close()
 end
end

function saveSavepoint(input1, input2)
 local file = fs.open("Savepoint", "w")
 file.writeLine(tonumber(input1))
 file.writeLine(runningRoute)
 file.writeLine(tonumber(input2))
 file.close()
end

function loadSavepoint()
 local file = fs.open("Savepoint", "r")
 currentPoint = tonumber(file.readLine())
 runningRoute = file.readLine()
 currentStepPoint = tonumber(file.readLine())
 file.close()
end


function saveRoute(name)
 local file = fs.open(name, "w")
 for i=1, countArray(route) do
  file.writeLine(route[i])
 end
 file.close()
 local routeAllreadyExists = false
 if countArray(listOfRoutes) > 0 then
  for i=1, countArray(listOfRoutes) do
   if listOfRoutes[i] == name then
    routeAllreadyExists = true
   end
  end
 end
 if not routeAllreadyExists then
  table.insert(listOfRoutes, 1, name)
 end
 saveListOfRoutes()
end

function resetRoute()
 for i=1, countArray(route) do
  route[i] = nil
 end
end

function loadRoute(name)
 local file = fs.open(tostring(name), "r")
 resetRoute()
 local line = file.readLine()
 local j = 1
 while line do
  route[j] = line
  j = j + 1
  line = file.readLine()
 end
 file.close()
end

function deleteRoute(name)
 if countArray(listOfRoutes) > 0 then
  for i=1, countArray(listOfRoutes) do
   if listOfRoutes[i] == name then
    table.remove(listOfRoutes ,i)
   end
  end
  saveListOfRoutes()
 end
end

-- MENUS

function drawMenuMain()
 drawHeader(version, 1)
 drawCopyright()

 if select == 1 then
  printCentered("> Start <", a)
 else
  printCentered("Start", a)
 end
 if select == 2 then
  printCentered("> New <", b)
 else
  printCentered("New", b)
 end
 if select == 3 then
  printCentered("> Delete <", c)
 else
  printCentered("Delete", c)
 end
 if select == 4 then
  printCentered("> Quit <", z-2)
 else
  printCentered("Quit", z-2)
 end
end


-- MENUSTATE

local menustate = "main"

local mopt = {
 ["main"] = {
  options = {"start", "new", "delete", "quit"},
  draw = drawMenuMain
 }
}

function runMenu()
 while running do
  clearScreen()
  mopt[menustate].draw()

  local id, key = os.pullEvent("key")
  if key == 200 or key == 17 then
   select = select-1
  end
  if key == 208 or key == 31 then
   select = select+1
  end
  if key == 14 or key == 30 then
   if not menustate == "quit" then
    select = #mopt[menustate].options
    menustate = mopt[menustate].options[select]
    select = 1
   else
    clearScreen()
    running = false
    break
   end
  end
  if select == 0 then
   select = #mopt[menustate].options
  end
  if select > #mopt[menustate].options then
   select = 1
  end
  clearScreen()
  if key == 28 or key == 32 then
   if mopt[menustate].options[select] == "quit" then
    running = false
   elseif mopt[menustate].options[select] == "start" then
    startRoute()
   elseif mopt[menustate].options[select] == "new" then
    createNewRoute()
   elseif mopt[menustate].options[select] == "delete" then
    selectRoute()
    if runningRoute == "" then else
     deleteRoute(runningRoute)
    end
   elseif true then
    menustate = mopt[menustate].options[select]
    select = 1
   end
  end
 end
end



-- IMPORTANT FUNCTIONS

function countArray(array)
 local actions = 0
 for k,v in pairs(array) do
  actions = actions + 1
 end
 return actions
end

local function transfer(i)
 if i == 2 then
  return "1"
 elseif i == 3 then
  return "2"
 elseif i == 4 then
  return "3"
 elseif i == 5 then
  return "4"
 elseif i == 6 then
  return "5"
 elseif i == 7 then
  return "6"
 elseif i == 17 then
  return "w"
 elseif i == 30 then
  return "a"
 elseif i == 31 then
  return "s"
 elseif i == 32 then
  return "d"
 elseif i == 57 then
  return "spacebar"
 elseif i == 42 then
  return "shift"
 elseif i == 19 then
  return "refuel"
 elseif i == 16 then
  return "suck"
 elseif i == 18 then
  return "drop"
 elseif i == 21 then
  return "attack"
 elseif i == 45 then
  return "redstone"
 elseif i == 29 then
  return "strg"
 elseif i == 46 then
  return "select"
 elseif i == 28 then
  return "enter"
 else
  return ""
 end
end

function savePos(a, b, c)
 if b < c then
  saveSavepoint(a,b+1)
 else
  saveSavepoint(a+2,1)
 end
end

function makeAction(j ,action, amount)
 j = tonumber(j)
 amount = tonumber(amount)

 if action == "w" then
  for i=currentStepPoint,amount do
   savePos(j,i,amount)
   while not turtle.forward() do 
    saveSavepoint(j,i)
    while turtle.detect() do
     sleep(1)
    end
    savePos(j,i,amount)
   end
  end
 elseif action == "s" then
  for i=currentStepPoint, amount do
   savePos(j,i,amount)
   while not turtle.back() do 
    saveSavepoint(j,i)
    sleep(1)
   end
   savePos(j,i,amount)
  end

 elseif action == "spacebar" then
  for i=currentStepPoint, amount do
   savePos(j,i,amount)
   while not turtle.up() do 
    saveSavepoint(j,i)
    while turtle.detectUp() do
     sleep(1)
    end
    savePos(j,i,amount)
   end
  end
 elseif action == "shift" then
  for i=currentStepPoint, amount do
   savePos(j,i,amount)
   while not turtle.down() do 
    saveSavepoint(j,i)
    while turtle.detectDown() do
     sleep(1)
    end
    savePos(j,i,amount)
   end
  end
 elseif action == "a" then
  saveSavepoint(j+2,1)
  turtle.turnLeft()
 elseif action == "d" then
  saveSavepoint(j+2,1)
  turtle.turnRight()
 elseif action == "attack" then
  saveSavepoint(j+2,1)
  turtle.attack()
 elseif action == "suckUp" then
  saveSavepoint(j+2,1)
  turtle.suckUp()
 elseif action == "suckDown" then
  saveSavepoint(j+2,1)
  turtle.suckDown()
 elseif action == "suckFront" then
  saveSavepoint(j+2,1)
  turtle.suck()
 elseif action == "dropUp" then
  saveSavepoint(j+2,1)
  turtle.dropUp(amount)
 elseif action == "dropDown" then
  saveSavepoint(j+2,1)
  turtle.dropDown(amount)
 elseif action == "dropFront" then
  saveSavepoint(j+2,1)
  turtle.drop(amount)
 elseif action == "select" then
  saveSavepoint(j+2,1)
  turtle.select(amount)
 elseif action == "rw" or action == "ra" or action == "rs" or action == "rd" or action == "rspacebar" or action == "rshift" then
  saveSavepoint(j+2,1)
  toggleRedstone(action)
 elseif action == "refuel" then
  saveSavepoint(j+2,1)
  turtle.refuel(amount)
 elseif action == "wait" then
  saveSavepoint(j+2,1)
  sleep(amount)
 else
  saveSavepoint(j+2,1)
  loadstring(action())
 end
end

function toggleRedstone(side)
 if side == "rw" then side = "front"
 elseif side == "ra" then side = "left"
 elseif side == "rs" then side = "back"
 elseif side == "rd" then side = "right"
 elseif side == "rspacebar" then side = "top"
 elseif side == "rshift" then side = "bottom" end
 redstone.setOutput(side, not redstone.getOutput(side))
end


-- CREATE NEW ROUTE


function createNewRoute()
 local liveTracking = false
 local input = ""
 for i=1, countArray(newroute) do
  newroute[i] = nil
 end
 resetRoute()
 clearScreen()

-- MENU SCREENS

 local selectedmenu = 0
 while true do
  clearScreen()
  if selectedmenu == 0 then
   drawHeader("Create a new route", 1)
   term.setCursorPos(1,3)
   print[[  1 -- Movement
  2 -- Standard Actions
  3 -- Add a program
  4 -- Overview Screen
  5 -- Toggle Live Tracking
  6 -- Add own command

  ENTER -- Finish and Save
  Left STRG -- EXIT]]
   term.write("  Live Tracking ") 
   if liveTracking then print("enabled") else print("disabled") end

  elseif selectedmenu == 1 then
   drawHeader("Movement", 1)
   term.setCursorPos(1,3)
   print[[  W & S -- Forward & Back
  A & D -- Turn Left & Turn Right
  SPACE BAR -- Up
  Left SHIFT -- Down
  R -- Refuel

  Left STRG -- Back]]
  
  elseif selectedmenu == 2 then
   drawHeader("Actions", 1)
   term.setCursorPos(1,3)
   print[[  Q -- Suck
  E -- Drop
  Y -- Attack
  X -- Redstone
  C -- Select Slot
  W -- Wait

  Left STRG -- Back]]
  end


-- INPUT

  local id, key = os.pullEvent("key")
  input = transfer(key)
  sleep(0.1)
  clearScreen()

-- MENU 0

  if selectedmenu == 0 then
   if input == "enter" then
    print("This route has " .. #newroute/2 .. " actions.")
    print("How do you want to name the route?")
    local name = read()
    for i=1, countArray(newroute) do
     route[i] = newroute[i]
    end
    saveRoute(name)
    break
   elseif input == "strg" then
    break
   end
  clearScreen()



-- MENU 1

  elseif selectedmenu == 1 then
   if input == "strg" then
    selectedmenu = 0
   elseif input == "w" then
    print("How far should the turlte move forward?")
    local far = tonumber(read())
    if far > 0 then
     table.insert(newroute, "w")
     table.insert(newroute, far)
     if liveTracking then makeAction(0,"w", far) end
    end
 
   elseif input == "a" then
    table.insert(newroute, "a")
     table.insert(newroute, "0")
    if liveTracking then makeAction(0,"a",0) end
 
   elseif input == "s" then
    print("How far should the turlte move backwards?")
    local far = tonumber(read())
    if far > 0 then
     table.insert(newroute, "s")
     table.insert(newroute, far)
     if liveTracking then makeAction(0,"s", far) end
    end
 
   elseif input == "d" then
    table.insert(newroute, "d")
    table.insert(newroute, "0")
    if liveTracking then makeAction(0,"d", 0) end
 
   elseif input == "spacebar" then
    print("How far should the turlte move up?")
    local far = tonumber(read())
    if far > 0 then
     table.insert(newroute, "spacebar")
     table.insert(newroute, far)
     if liveTracking then makeAction(0,"spacebar", far) end
    end
 
   elseif input == "shift" then
    print("How far should the turlte move down?")
    local far = tonumber(read())
    if far > 0 then
     table.insert(newroute, "shift")
     table.insert(newroute, far)
     if liveTracking then makeAction(0,"shift", far) end
    end
   
   elseif input == "refuel" then
    print("How many items should be used to refuel the turtle?")
    local amount = tonumber(read())
    if amount < 0 then
     amount = 1
    elseif amount > 64 then
     amount = 64
    end
    table.insert(newroute, "refuel")
    table.insert(newroute, amount)
    if liveTracking then
     turtle.refuel(amount)
    end
   end

-- MENU 2

  elseif selectedmenu == 2 then
   if input == "strg" then
    selectedmenu = 0
   elseif input == "suck" then
    print[[  On which side should the turtle suck items out?
  W -- in front
  SPACE BAR -- above
  SHIFT -- below]]
    local id, key = os.pullEvent("key")
    local side = transfer(key)
    if side == "spacebar" then
     table.insert(newroute, "suckUp")
     if liveTracking then makeAction(0,"suckUp","0") end
    elseif side == "shift" then
     table.insert(newroute, "suckDown")
     if liveTracking then makeAction(0,"suckDown","0") end
    else
     table.insert(newroute, "suckFront")
     if liveTracking then makeAction(0,"suckFront","0") end
    end
    table.insert(newroute, "0")
 
   elseif input == "drop" then
    print[[On which side should the turtle drop items into?
  W -- in front
  SPACE BAR -- above
  SHIFT -- below]]
    local id, key = os.pullEvent("key")
    local side = transfer(key)
    print("How many items should be dropped?")
    sleep(0.1)
    local amount = tonumber(read())
    if amount < 0 or amount > 64 then
     amount = 64
    end
    if side == "spacebar" then
     table.insert(newroute, "dropUp")
     table.insert(newroute, amount)
     if liveTracking then makeAction(0,"dropUp", amount) end
    elseif side == "shift" then
     table.insert(newroute, "dropDown")
     table.insert(newroute, amount)
     if liveTracking then makeAction(0,"dropDown", amount) end
    else
     table.insert(newroute, "dropFront")
     table.insert(newroute, amount)
     if liveTracking then makeAction(0,"dropFront", amount) end
    end
  
   elseif input == "select" then
    print("Which slot should the turtle select?")
    local slot = tonumber(read())
    if slot < 1 or slot > 16 then
     slot = 1
    end
    table.insert(newroute, "select")
    table.insert(newroute, slot)
    if liveTracking then makeAction(0,"select", slot) end
   
   elseif input == "attack" then
    table.insert(newroute, "attack")
    table.insert(newroute, "0")
    if liveTracking then makeAction(0,"attack",1) end
  
   elseif input == "redstone" then
    print[[On which side a redstone signal be toggled on or off?
W -- in front
A -- on the left
S -- on the back
D -- on the right
SPACE BAR -- above
SHIFT -- below]]

    local id, key = os.pullEvent("key")
    local side = transfer(key)
    if side == "w" or side == "a" or side == "s" or side == "d" or side == "spacebar" or side == "shift" then
     side = "r" .. side
    end
    table.insert(newroute, side)
    table.insert(newroute, "0")
    if liveTracking  then toggleRedstone(side) end    
   elseif input == "strg" then
    selectmenu = 0
   elseif input == "w" then
    print("How many seconds should the turtle wait?")
    local time = math.floor(tonumber(read()))
    if time < 0 then
     slot = 1
    end
    table.insert(newroute, "wait")
    table.insert(newroute, time)
   end
  end --end of selectedmenu

-- GLOBAL MENU
  
  if input == "1" then
   selectedmenu = 1
  elseif input == "2" then
   selectedmenu = 2
  elseif input == "3" then
   selectRoute()
   if runningRoute == "" then else
    for i=1, countArray(route),2 do
     table.insert(newroute, route[i])
     table.insert(newroute, route[i+1])
     if liveTracking then makeAction(0,route[i],route[i+1]) end
    end
    resetRoute()
    runningRoute = ""
   end
   selectmenu = 0
  elseif input == "4" then
   overviewScreen()
   elseif input == "5" then
   liveTracking = not liveTracking
  elseif input == "6" then
   print("Tipe in the command:")
   local owncommand = read()
   if owncommand == "" then else
    table.insert(newroute, owncommand)
    table.insert(newroute, "0")
    if liveTracking then makeAction(0,owncommand,"0") end
   end
  end
 end --end of while
 clearScreen()
 saveSavepoint(0,0)
end -- end of function



--OVERVIEW SCREEN
function overviewScreen()
 local showScreen = true
 local max = 0
 local lastmax = 0
 local routeBeforeMax = ""
 local routeBeforeMaxPlus = ""
 while showScreen do
  clearScreen()
  print("Last eight actions:")
  for i=15,1,-2 do
   max = countArray(newroute)
   if max - i > 0 then
    beforeMax = max-(i-1)
    routeBeforeMax = newroute[beforeMax]
    routeBeforeMaxPlus = newroute[max-i]
    if beforeMax/2 < 10 then
     term.write(beforeMax/2 .. "  | ")
    elseif beforeMax/2 < 100 then 
     term.write(beforeMax/2 .. " | ")
    elseif beforeMax/2 < 1000 then 
     term.write(beforeMax/2 .. "| ")
    elseif beforeMax/2 < 10000 then
     term.write(beforeMax/2 .. " ")
    end
    if routeBeforeMaxPlus == "w" then
     print("Forward: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "a" then
     print("Turn Left")
    elseif routeBeforeMaxPlus == "s" then
     print("Back: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "d" then
     print("Turn Right")
    elseif routeBeforeMaxPlus == "spacebar" then
     print("Up: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "shift" then
     print("Down: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "suckUp" then
     print("Suck: Above")
    elseif routeBeforeMaxPlus == "suckDown" then
     print("Suck: Below")
    elseif routeBeforeMaxPlus == "suckFront" then
     print("Suck: Front")
    elseif routeBeforeMaxPlus == "dropUp" then
     print("Drop: Up: Amount of Items: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "dropDown" then
     print("Drop: Down: Amount of Items: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "dropFront" then
     print("Drop: Front: Amount of Items: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "refuel" then
     print("Refuel   Amount of Items: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus == "attack" then
     print("Attack")
    elseif routeBeforeMaxPlus == "select" then
     print("Select Slot: " ..routeBeforeMax)
    elseif routeBeforeMaxPlus == "rw" then
     print("Toggle Redstone Output: Front")
    elseif routeBeforeMaxPlus == "ra" then
     print("Toggle Redstone Output: Left")
    elseif routeBeforeMaxPlus == "rs" then
     print("Toggle Redstone Output: Back")
    elseif routeBeforeMaxPlus == "rd" then
     print("Toggle Redstone Output: Right")
    elseif routeBeforeMaxPlus == "rspacebar" then
     print("Toggle Redstone Output: Above")
    elseif routeBeforeMaxPlus == "rshift" then
     print("Toggle Redstone Output: Below")
    elseif routeBeforeMaxPlus == "wait" then
     print("Wait: " .. routeBeforeMax)
    elseif routeBeforeMaxPlus then
     print("Command: " .. routeBeforeMaxPlus)
    end
   end
  end
  print("")
  print("Any Key -- Next Action")
  print("BACKSPACE -- Delete Last Action")
  sleep(0.2)
  local id, key = os.pullEvent("key")
  if key == 14 then
   if countArray(newroute) > 1 then
    table.remove(newroute)
    local last = table.remove(newroute)
    if last == "rw" or last == "ra" or last == "rs" or last == "rd" or last == "rspacebar" or last == "rshift" then
     toggleRedstone(last)
    end
   end
  elseif key == 1 then
  else
   showScreen = false 
  end
 end
end


-- START ROUTE

function runRoute()
 clearScreen()
 local max = countArray(route)
 while true do
  for j=currentPoint,max,2 do
   makeAction(j,route[j],route[j+1])
   currentStepPoint = 1
  end
  currentPoint = 1
  saveSavepoint(1,1)
 end
 runningRoute = ""
 saveSavepoint(0,0)
end

function selectRoute()
 local showRoutes = true
 local numberroute = 1
 runningRoute = ""
 clearScreen()
 resetRoute()

 if countArray(listOfRoutes) == 0 then
  printCentered("No Routes Set!",5)
  showRoutes = false
  sleep(2)
 end
 
 while showRoutes do
  clearScreen()
  print[[   W -- Next Route
   S -- Last Route
   D & ENTER -- Start Selected Route
   A & BACKSPACE -- Return To Main Menu]]  
  printCentered(numberroute .. "/".. countArray(listOfRoutes), 7)
  printCentered(tostring(listOfRoutes[numberroute]) ,8)
  loadRoute(listOfRoutes[numberroute])
  printCentered("Actions: " .. countArray(route)/2,9)

  local id, key = os.pullEvent("key")
  if key == 208 or key == 31 then
   numberroute = numberroute - 1
  end
  if key == 200 or key == 17 then
   numberroute = numberroute + 1
  end
  if key == 14 or key == 30 then
    runningRoute = ""
    showRoutes = false
  end
  if numberroute == 0 then
   numberroute = countArray(listOfRoutes)
  end
  if numberroute > countArray(listOfRoutes) then
   numberroute = 1
  end
  if key == 28 or key == 32 then
   runningRoute = listOfRoutes[numberroute]
   showRoutes = false
  end
 end
end

function startRoute()
 selectRoute()
 if runningRoute == "" then else
  currentPoint = 1
  currentStepPoint = 1
  runRoute()
 end
end


loadListOfRoutes()
if fs.exists("Savepoint") then
 loadSavepoint()
 if currentPoint > 0 then
  loadRoute(runningRoute)
  runRoute()
  saveSavepoint(0,0)
 end
end
runMenu()
sleep(0.1)