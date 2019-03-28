-- VARIABLES

local version = "Planetz Under Gravity Computer Version 0.3.0"
local computerID = os.getComputerID()
local h, w = 19, 51
local playingLevel, playingLevelName = 0, ""
local warpedPlanets, amountPlanets, directionChanges = 0, 0, 0
local space = {}
local planet = {}
local moon = {}
local editorGUI = true
local sideGUI = true
local extendedGUI = false
local selectedSpace = "N"
local fancy = false
local fancyColor = colors.white

-- PRELOAD TABLES

--[planetnumber][x|y|state]
for i=1,10 do
 planet[i] = {}
 moon[i] = {}
 for j=1,3 do
  if j == 3 then
   planet[i][j] = "noDir"
   moon[i][j] = "noDir"
  else
   planet[i][j] = 0
   moon[i][j] = 0
  end
 end
end

for x=1,w do
 space[x] = {}
 for y=1,h do
  space[x][y] = "N"
 end
end

-- DRAW AND CLEAR

function setFancyOr(individualColor)
 if fancy then
  term.setTextColor(fancyColor)
 else
  term.setTextColor(individualColor)
 end
end

function draw(editorMode)
 term.setTextColor(colors.black)
 for x=1,w do
  for y=1,h do
   if space[x][y] == "#" then -- ASTEROID
    paintutils.drawPixel(x, y, colors.gray)
   elseif space[x][y] == "+" then -- INCOMMING ASTEROID
    paintutils.drawPixel(x, y, colors.lightGray)
   elseif space[x][y] == "X" then -- WORM HOLE / GOAL
   paintutils.drawPixel(x, y, colors.orange)
   elseif editorMode and space[x][y] == "P" then -- PLANET (EDITOR)
    paintutils.drawPixel(x, y, colors.lightBlue)
   elseif editorMode and space[x][y] == "M" then -- MOON (EDITOR)
    paintutils.drawPixel(x, y, colors.brown)
   elseif space[x][y] == "O" then -- SUN / DEATH
    paintutils.drawPixel(x, y, colors.red)
   elseif space[x][y] == "A" or space[x][y] == "B" or space[x][y] == "C" then
    paintutils.drawPixel(x,y, colors.yellow)
    if editorMode then
     term.setTextColor(colors.black)
     term.setCursorPos(x,y)
     term.write(space[x][y])
    end
   elseif space[x][y] == "1" or space[x][y] == "2" or space[x][y] == "3" then
    if editorMode then
     paintutils.drawPixel(x, y, colors.lightGray)
     term.setTextColor(colors.white)
     term.setCursorPos(x,y)
     term.write(space[x][y])
    else
     paintutils.drawPixel(x, y, colors.black)
    end
   elseif space[x][y] == "6" or space[x][y] == "7" or space[x][y] == "8" then
    paintutils.drawPixel(x, y, colors.gray)
    if editorMode then
     term.setTextColor(colors.white)
     term.setCursorPos(x,y)
     term.write(space[x][y])
    end
   else
    paintutils.drawPixel(x, y, colors.black)
   end
   for p=1,10 do
    if planet[p][1] == x and planet[p][2] == y then -- PLANET (INGAME)
     paintutils.drawPixel(x, y, colors.lightBlue)
    end
    if moon[p][1] == x and moon[p][2] == y then -- MOON (INGAME)
     paintutils.drawPixel(x, y, colors.brown)
    end
   end
  end
 end
 term.setTextColor(colors.white)
end

function clear()
 term.setBackgroundColor(colors.black)
 term.clear()
 term.setCursorPos(1,1)
end

-- PLANET INFO SET

function setPlanet(p,a,b,c)
 planet[p][1] = a
 planet[p][2] = b
 planet[p][3] = c
end

function setMoon(m,a,b,c)
 moon[m][1] = a
 moon[m][2] = b
 moon[m][3] = c
end

-- SET DIRECTION

function setDirection(newDir)
 for p=1,10 do
  if planet[p][1] > 0 and planet[p][3] == "noDir" then
   planet[p][3] = newDir
  end
  if moon[p][1] > 0 and moon[p][3] == "noDir" then
   moon[p][3] = newDir
  end
 end
end

-- CHECK SPACE

function checkForOutOfSpace(p,isMoon)
 if not isMoon then
  if planet[p][1] == 0 or planet[p][1] == w+1 or planet[p][2] == 0 or planet[p][2] == h+1 then
   return true
  else
   return false
  end
 else
  if moon[p][1] == 0 or moon[p][1] == w+1 or moon[p][2] == 0 or moon[p][2] == h+1 then
   return true
  else
   return false
  end
 end
end

function checkForCollision(p,x,y) -- CHECK FOR HAS MOVED AND DIR SET
 if ( planet[p][1] == x and planet[p][2] == y ) or ( moon[p][1] == x and moon[p][2] == y ) then
  return true
 else
  return false
 end 
end

function checkSpace(x,y,collisionCheck,isMoon)
 for p=1,10 do
  if isMoon then 					--MOON
   if not ( moon[p][3] == "noDir" ) then
    if checkForOutOfSpace(p,true) then
     return "death"
    end
   end
  else 							--PLANET
   if not ( planet[p][3] == "noDir" ) then
    if checkForOutOfSpace(p,false) then
     return "death"
    end
   end
  end
  if collisionCheck and checkForCollision(p,x,y) then 	--BOTH
   return "blocked"
  end
 end
 if space[x][y] == "N" or space[x][y] == "+" then
  return "free"
 elseif space[x][y] == "O" then
  return "death"
 elseif space[x][y] == "X" then
  return "wormhole"
 elseif space[x][y] == "#" or space[x][y] == "6" or space[x][y] == "7" or space[x][y] == "8" then
  return "blocked"
 else 			-- "1" "2" "3"
  return "free"
 end
end

-- CHECK ACTION

function changeSpace(from, to)
 for y=1,h do
  for x=1,w do
   if space[x][y] == from then
    space[x][y] = to
   elseif space[x][y] == to then
    space[x][y] = from
   end
  end
 end
end

function checkForIncomming(p,isMoon)
 if not isMoon then
  if space[planet[p][1]][planet[p][2]] == "+" then
   space[planet[p][1]][planet[p][2]] = "#"
  end
 else
  if space[moon[p][1]][moon[p][2]] == "+" then
   space[moon[p][1]][moon[p][2]] = "#"
  end
 end
end

function checkForGate(p,isMoon)
 if not isMoon then
  if space[planet[p][1]][planet[p][2]] == "A" then
   changeSpace("1","6")
  elseif space[planet[p][1]][planet[p][2]] == "B" then
   changeSpace("2","7")
  elseif space[planet[p][1]][planet[p][2]] == "C" then
   changeSpace("3","8")
  end
 else
  if space[moon[p][1]][moon[p][2]] == "A" then
   changeSpace("1","6")
  elseif space[moon[p][1]][moon[p][2]] == "B" then
   changeSpace("2","7")
  elseif space[moon[p][1]][moon[p][2]] == "C" then
   changeSpace("3","8")
  end
 end
end

-- MOVE PLANETS

function move()
 for p=1,10 do
  local relX, relY = 0, 0
  if planet[p][1] > 0 and not (planet[p][3] == "noDir") then
   if planet[p][3] == "up" then
    relY = -1
   elseif planet[p][3] == "right" then
    relX = 1
   elseif planet[p][3] == "down" then
    relY = 1
   elseif planet[p][3] == "left" then
    relX = -1
   end
   local newSpace = checkSpace(planet[p][1]+relX,planet[p][2]+relY,true,false)
   if newSpace == "free" then
    checkForIncomming(p,false)
    setPlanet(p,planet[p][1]+relX,planet[p][2]+relY,planet[p][3])
    checkForGate(p,false)
    if checkSpace(planet[p][1]+relX,planet[p][2]+relY,false,false) == "blocked" then
     planet[p][3] = "noDir"
    end
   elseif newSpace == "blocked" then
    planet[p][3] = "noDir"
   elseif newSpace == "death" then
    setPlanet(p,0,0,"noDir")
   elseif newSpace == "wormhole" then
    setPlanet(p,0,0,"noDir")
    warpedPlanets = warpedPlanets + 1
   end
   relX, relY = 0, 0
  end
  if moon[p][1] > 0 and not (moon[p][3] == "noDir") then
   if moon[p][3] == "up" then
    relY = -1
   elseif moon[p][3] == "right" then
    relX = 1
   elseif moon[p][3] == "down" then
    relY = 1
   elseif moon[p][3] == "left" then
    relX = -1
   end
   local newSpace = checkSpace(moon[p][1]+relX,moon[p][2]+relY,true,true)
   if newSpace == "free" then
    checkForIncomming(p,true)
    setMoon(p,moon[p][1]+relX,moon[p][2]+relY,moon[p][3])
    checkForGate(p,true)
    if checkSpace(moon[p][1]+relX,moon[p][2]+relY,false,true) == "blocked" then
     moon[p][3] = "noDir"
    end
   elseif newSpace == "blocked" then
    moon[p][3] = "noDir"
   elseif newSpace == "death" then
    setMoon(p,0,0,"noDir")
   elseif newSpace == "wormhole" then
    setMoon(p,0,0,"noDir")
   end
  end
 end
end


-- ESC MENU

function escMenu()
 for x=15,34 do
  for y=3,15 do
   if fancy then
    paintutils.drawPixel(x,y, fancyColor)
   else
    paintutils.drawPixel(x,y, colors.white)
   end
  end
 end
 for x=16,33 do
  for y=4,14 do
   paintutils.drawPixel(x, y, colors.black)
  end
 end
 setFancyOr(colors.white)
 centered("CONTINUE",5)
 centered("RESTART",9)
 centered("EXIT",13)
 sleep(0.1)
 local event = { os.pullEvent("mouse_click") }
 if event[4] >= 1 and event[4] <= 7 then
  return "continue"
 elseif event[4] >= 8 and event[4] <= 11 then
  return "restart"
 elseif event[4] >= 12 and event[4] <= h then
  return "exit"
 end
end

-- PLAY

function play()
 clear()
 local neededTime = 0 -- CHANGE IF LOAD AND SAFE AVAILABLE
 local firstHit = true
 directionChanges = 0 
 warpedPlanets = 0
 draw(false)
 local changeDir
 local delay
 local toDo
 while amountPlanets > warpedPlanets do
  changeDir = true
  toDo = true
  local direction = ""
  local event = { os.pullEvent() }
  if event[1] == "timer" then
   move()
   draw(false)
   neededTime = neededTime + 0.15
   delay = os.startTimer(0.15)
  elseif event[1] == "mouse_click" then
   if event[4] >= 1 and event[4] <= 7 then
    direction = "up"
   elseif event[3] >= w-16 and event[3] <= w+1 then
    direction = "right"
   elseif event[4] >= 12 and event[4] <= h+1 then
    direction = "down"
   elseif event[3] >= 1 and event[3] <= 17 then
    direction = "left"
   else
    if not firstHit then
     local event = { os.pullEvent("timer") }
    end
    local esc = escMenu()
    if esc == "exit" then
     return false
    elseif esc == "continue" then
     changeDir = false
     toDo = false
     if not firstHit then
      delay = os.startTimer(0.15)
     end
     draw(false)
    elseif esc == "restart" then
     loadLevel(playingLevel)
     changeDir, firstHit, toDo, neededTime, directionChanges, warpedPlanets = false, true, false, 0, 0, 0
     draw(false)
    end
   end
    if toDo and firstHit then
     firstHit = not firstHit
     delay = os.startTimer(0.15)
     move()
     draw(false)
    end
   if changeDir then
    directionChanges = directionChanges + 1
    setDirection(direction)
   end
  end
 end
 if amountPlanets == warpedPlanets then
  clear()
  setFancyOr(colors.white)
  centered(playingLevelName,5)
  centered("Gravity Modifications:",7)
  centered(tostring(directionChanges), 9)
  centered("Time:",12)
  centered(tostring(neededTime), 14)
  local event = { os.pullEvent("mouse_click") }
  playingLevel, playingLevelName = 0, ""
 end
 return true
end




-- EDITOR GUI

function drawTwo(x,y,c)
 paintutils.drawPixel(x, y, c)
 paintutils.drawPixel(x+1, y, c)
end

function drawTwoText(x,y,str,ct,cb)
 term.setTextColor(ct)
 term.setBackgroundColor(cb)
 term.setCursorPos(x,y)
 term.write(str .. str)
end

function drawEditorGUI()
 if editorGUI then
  for x=1,w do
   paintutils.drawPixel(x, 1, colors.white)
  end
  setFancyOr(colors.black)
  term.setCursorPos(1,1)
  term.write("CLOSE")
  drawTwo(7,1,colors.black)
  drawTwo(10,1,colors.gray)
  drawTwo(13,1,colors.lightBlue)
  drawTwo(16,1,colors.lightGray)
  drawTwo(19,1,colors.orange)
  drawTwo(22,1,colors.red)
  drawTwo(25,1,colors.brown)
  paintutils.drawPixel(24, 1, colors.white)
  term.setCursorPos(w-3,1)
  term.write("EXIT")
  if extendedGUI then
   term.setCursorPos(w-13,1)
   term.write("LESS")
   for x=1,w do
    paintutils.drawPixel(x, 2, colors.white)
   end
   drawTwoText(4,2,"A",colors.black,colors.yellow)
   drawTwoText(7,2,"B",colors.black,colors.yellow)
   drawTwoText(10,2,"C",colors.black,colors.yellow)
   drawTwoText(13,2,"1",colors.white,colors.lightGray)
   drawTwoText(16,2,"2",colors.white,colors.lightGray)
   drawTwoText(19,2,"3",colors.white,colors.lightGray)
   drawTwoText(22,2,"6",colors.white,colors.gray)
   drawTwoText(25,2,"7",colors.white,colors.gray)
   drawTwoText(28,2,"8",colors.white,colors.gray)
   setFancyOr(colors.black)
   term.setBackgroundColor(colors.white)
  else
   term.setCursorPos(w-13,1)
   term.write("MORE")
   setFancyOr(colors.black)
   term.setBackgroundColor(colors.white)
  end
  term.setCursorPos(w-8,1)
  term.write("SAVE")
  setFancyOr(colors.white)
 else
  if sideGUI then
   term.setCursorPos(1,1)
  else
   term.setCursorPos(5,1)
  end
  setFancyOr(colors.white)
  term.write("GUI")
 end
end

-- CHECK GUI

function checkEditorGUI(xPos,yPos)
 term.setCursorPos(1,1)
 if editorGUI then
  if yPos == 1 then
   if xPos >= 1 and xPos <= 5 then
    editorGUI = false
   elseif xPos == 7 or xPos == 8 then
    selectedSpace = "N"
   elseif xPos == 10 or xPos == 11 then
    selectedSpace = "#"
   elseif xPos == 13 or xPos == 14 then
    selectedSpace = "P"
   elseif xPos == 16 or xPos == 17 then
    selectedSpace = "+"
   elseif xPos == 19 or xPos == 20 then
    selectedSpace = "X"
   elseif xPos == 22 or xPos == 23 then
    selectedSpace = "O"
   elseif xPos == 25 or xPos == 26 then
    selectedSpace = "M"
   elseif xPos >= w-13 and xPos <= w-10 then
    extendedGUI = not extendedGUI
   elseif xPos >= w-8 and xPos <= w-5 then
    return "save"
   elseif xPos >= w-3 then
    return "exit"
   end
   return "true"
  elseif extendedGUI and yPos == 2 then
   if xPos == 4 or xPos == 5 then
    selectedSpace = "A"
   elseif xPos == 7 or xPos == 8 then
    selectedSpace = "B"
   elseif xPos == 10 or xPos == 11 then
    selectedSpace = "C"
   elseif xPos == 13 or xPos == 14 then
    selectedSpace = "1"
   elseif xPos == 16 or xPos == 17 then
    selectedSpace = "2"
   elseif xPos == 19 or xPos == 20 then
    selectedSpace = "3"
   elseif xPos == 22 or xPos == 23 then
    selectedSpace = "6"
   elseif xPos == 25 or xPos == 26 then
    selectedSpace = "7"
   elseif xPos == 28 or xPos == 29 then
    selectedSpace = "8"
   end
   return "true"
  end
 elseif not editorGUI and yPos == 1 then
  if sideGUI and xPos <= 3 then
   editorGUI = true
   sideGUI = not sideGUI
   sleep(0.1)
   return "true"
  elseif not sideGUI and xPos >= 5 and xPos <= 7 then
   editorGUI = true
   sideGUI = not sideGUI
   sleep(0.1)
   return "true"
  end 
 end
 return "false"
end


-- CREATE OR CHANGE LEVEL

function levelEditor()
 selectedSpace = "#"
 editorGUI = false
 sideGUI = true
 extendedGUI = false
 for p=1,10 do
  if planet[p][1] > 0 then
   space[planet[p][1]][planet[p][2]] = "P"
   setPlanet(p,0,0,"noDir")
  end
  if moon[p][1] > 0 then
   space[moon[p][1]][moon[p][2]] = "M"
   setMoon(p,0,0,"noDir")
  end
 end
 while true do
  draw(true)
  drawEditorGUI()
  local event = { os.pullEvent("mouse_click") }
  local GUIinteraction = checkEditorGUI(event[3],event[4])
  if GUIinteraction == "false" then
   space[event[3]][event[4]] = selectedSpace
  elseif GUIinteraction == "save" then
   if saveLevel() then return end
  elseif GUIinteraction == "exit" then
   return false
  end
 end
end


-- LEVEL SELECT 										-- HERE

function pastebinImport()
 local levelnumber = 0
 for i=1,1000 do
  if not fs.exists("PUGC_"..i) then
   levelnumber = i
   break
  end
 end
 clear()
 setFancyOr(colors.white)
 centered("Paste pastebin link:",5)
 term.setCursorPos(10,8)
 local link = read()
 local accualLink = ""
 if #link == 8 then
  accualLink = link
 elseif #link == 21 then
  accualLink = link:sub(14,21)
 elseif #link == 28 then
  accualLink = link:sub(21,28)
 else
  centered("No Pastebin link", 11)
  sleep(2)
  return
 end
 centered("Getting Level...", 11)
 term.setCursorPos(1,14)
 shell.run("pastebin","get",accualLink,"PUGC_" .. levelnumber)
 centered("Finished", 17)
 sleep(1.5)
end


function resetPlayfield()
 for i=1,10 do
  for j=1,3 do
   if j == 3 then
    planet[i][j] = "noDir"
    moon[i][j] = "noDir"
   else
    planet[i][j] = 0
    moon[i][j] = 0
   end
  end
 end

 for x=1,w do
  for y=1,h do
   space[x][y] = "N"
  end
 end
end

function saveLevel()
 clear()
 local goals = 0
 local planets = 0
 local moons = 0
 for x=1,w do
  for y=1,h do
   if space[x][y] == "X" then
    goals = goals + 1
   elseif space[x][y] == "P" then
    planets = planets + 1
   elseif space[x][y] == "M" then
    moons = moons + 1
   end
  end
 end
 
 if goals == 0 or planets == 0 or planets > 10 or moons > 10 then
  term.write("No goal or planet found or too many planets or moons! Maximal 10!")
  sleep(2)
  return false
 end

 local levelName = ""
 repeat
  term.write("Name your level: ")
  levelName = read()
 until #levelName > 0

 local levelnumber = 0
 for i=1,1000 do
  if not fs.exists("PUGC_"..i) then
   levelnumber = i
   break
  end
 end

 local file = fs.open("PUGC_"..levelnumber , "w")
 file.writeLine(levelName)
 file.writeLine(planets) 
 for y=1, h do
  for x=1,w do
   if x == w then
    file.writeLine(space[x][y])
   else
    file.write(space[x][y])
   end
  end
 end
 file.close()
 return true
end


function loadLevel(levelName)
 resetPlayfield()

 local planetnumber = 1
 local moonnumber = 1
 local file = fs.open("PUGC_"..levelName,"r")
 levelName = file.readLine()
 amountPlanets = tonumber(file.readLine())
 for y=1, h do
  local row = file.readLine()
  for x = 1, w do
   local typeSpace = row:sub(x,x)
   if typeSpace == "P" then
    setPlanet(planetnumber,x,y,"noDir")
    planetnumber = planetnumber + 1
   elseif typeSpace == "M" then
    setMoon(moonnumber,x,y,"noDir")
    moonnumber = moonnumber + 1
   else
    space[x][y] = typeSpace
   end
  end
 end
 file.close()
end

function deleteLevel()
 fs.delete("PUGC_" .. playingLevel)
 resetPlayfield()
end


function selectLevel(editorMode, header)
 local level = {}
 for i=1,1000 do
  if fs.exists("PUGC_" .. i) then
   local file = fs.open("PUGC_"..i ,"r")
   table.insert(level, 1, { [1]=file.readLine(), [2]=i })
   file.close()
  end
 end

 local actions = 0
 for k,v in pairs(level) do
  actions = actions + 1
 end
 if actions == 0 then
  if editorMode then
   resetPlayfield()
   return true
  else
   return false
  end
 end

 local more = 0
 while true do
  clear()
  setFancyOr(colors.white)
  centered(header .. ": Level " .. more+1 .. " to " .. more+10, 1)
  local maxLevelShown = 10
  if actions-more < 10 then
   maxLevelShown = actions-more
  end
  for l=1,maxLevelShown do
   centered(level[l+more][1],l+3)
  end
  if actions-more > 10 then
   centered("More level",16)
  elseif more > 0 then
   centered("Back to the first level",16)
  end
  if editorMode then
   centered("Create a new level",17)
  end
  centered("Back to the menu",18)
  
  local event = { os.pullEvent("mouse_click") }
  if event[4] >= 4 and event[4] <= maxLevelShown+3 then
   if type(level[event[4]-3+more][1]) == "string" then
    loadLevel(level[event[4]-3+more][2])
    playingLevel = level[event[4]-3+more][2]
    playingLevelName = level[event[4]-3+more][1]
    return true
   end
  elseif event[4] == 16 then
   if actions-more > 10 then
    more = more + 10
   elseif more > 0 then
    more = 0
   end
  elseif editorMode and event[4] == 17 then
   resetPlayfield()
   return true
  elseif event[4] == 18 then
   return false
  end  
 end
end

-- MAIN MENU

function centered(str, line)
 term.setCursorPos(w/2 - #str/2, line)
 term.write(str)
end


function main()
 clear()
 term.setTextColor(fancyColor)
 centered(version,1)
 centered("PLAY",4)
 centered("EDITOR",7)
 centered("ADD", 10)
 centered("DELETE",13)
 centered("QUIT",16)
 centered("by UNOBTANIUM",19)
 term.setTextColor(colors.white)
 local event = { os.pullEvent("mouse_click") }
 if event[4] >= 3 and event[4] <= 5 then
  if selectLevel(false, "Play") then
   again = play()
  end
 elseif event[4] >= 6 and event[4] <= 8 then
  if selectLevel(true, "Editor") then
   levelEditor()
  end
 elseif event[4] >= 9 and event[4] <= 11 then
  pastebinImport()
 elseif event[4] >= 12 and event[4] <= 14 then
  if selectLevel(false, "Delete") then
   deleteLevel()
  end
 elseif event[4] >= 15 and event[4] <= 16 then
  clear()
  return false
 elseif event[4] == 19 then
  if fancy then
   fancyColor = colors.white
  else
   fancyColor = colors.orange
  end
  fancy = not fancy
 end
 return true
end


-- RUN

if not term.isColor() then print("Use an advanced computer and monitor!") sleep(2) term.clearScreen() term.setCursorPos(1,1) return end
while main() do end
clear()