-- VERSION 0.3.1 by unobtanium
local alveary = {}
local product = {}
local selectedHeight = 1
local autoShutdown = true
local mode = "turnOnOrOff"
local colorNumber = 2
local temporaryAlveary = {}
local colorName = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}

rednet.open("back")
local monitor = peripheral.wrap("right")
term.redirect(monitor)

-- product[productname] = amount
-- alveary[height][x][y][BeeType|Number|Product|Color|Mode]
for h = 1,3 do
 alveary[h] = {}
 for x= 1,4 do
  alveary[h][x] = {}
  for y=1,4 do
   alveary[h][x][y] = {}
   for var=1,5 do
    if var == 2 or var == 5 then
     alveary[h][x][y][var] = 0
    elseif var == 4 then
     alveary[h][x][y][var] = colors.white
    else
     alveary[h][x][y][var] = "NONE"
    end
   end
  end
 end
end

function saveVar()
 local file = fs.open("beeSystemVariables","w")
 file.writeLine(tostring(autoShutdown))
 file.writeLine(colorNumber)
 for x = 1,4 do
  for y= 1,4 do
   for h=1,3 do
    for var=1,5 do
     file.writeLine(alveary[h][x][y][var])
    end
   end
  end
 end
 for k,v in pairs(product) do
  file.writeLine(k)
  file.writeLine(v)
 end
 file.close()
end
 
function loadVar()
 if not fs.exists("beeSystemVariables") then return end
 local file = fs.open("beeSystemVariables","r")
 autoShutdown = file.readLine()
 colorNumber = tonumber(file.readLine())
 for x = 1,4 do
  for y= 1,4 do
   for h=1,3 do
    for var=1,5 do
     if var == 2 or var == 4 or var == 5 then
      alveary[h][x][y][var] = tonumber(file.readLine())
     else
      alveary[h][x][y][var] = file.readLine()
     end
    end
   end
  end
 end
 local k = file.readLine()
 while k do
  v = tonumber(file.readLine())
  product[k] = v
  k = file.readLine()
 end
 file.close()
end

function centeredAt(text,x,y,c)
 term.setTextColor(c)
 term.setCursorPos(x - #text/2, y)
 term.write(text)
end

-- ADD

function addAlveary(x,y)
 clear()
 term.setCursorPos(1,12)
 term.write("What do you want to do?")
 term.setCursorPos(1,14)
 if alveary[selectedHeight][x][y][2] == 0 then
  term.write("ADD      QUIT")
 else
  term.write("CHANGE   QUIT   DELETE   SWITCH")
 end
 while true do
  local event = {os.pullEvent("monitor_touch")}
  if event[4] == 14 then
   if event[3] >= 1 and event[3] <= 6 then
    break
   elseif event[3] >= 10 and event[3] <= 13 then
    return
   elseif alveary[selectedHeight][x][y][2] > 0 and event[3] >= 17 and event[3] <= 22 then
    clear()
    term.setCursorPos(1,12)
    term.write("Do you really want to delete this alveary slot?")
    term.setCursorPos(1,14)
    term.write("YES")
    term.setCursorPos(1,15)
    term.write("NO")
    sleep(0.1)
    while true do
     local e = {os.pullEvent("monitor_touch")}
     if e[4] == 14 then
      alveary[selectedHeight][x][y] = {"NONE",0,"NONE",colors.white,0}
      return
     elseif e[4] == 15 then
      return
     end
    end
   elseif alveary[selectedHeight][x][y][2] > 0 and event[3] >= 26 and event[3] <= 31 then
    temporaryAlveary = {selectedHeight, x, y}
    mode = "switch"
    return
   end
  end
 end
 term.clear()
 term.setCursorPos(16,13)
 term.write("Tipe into the computer screen!")
 repeat
  term.restore()
  local w, h = term.getSize()
 until w == 51 and h == 19
 term.setBackgroundColor(colors.black)
 clear()
 term.setTextColor(colors.white)
 term.setCursorPos(1,1)
 term.write("Enter the name of the bee type in the alveary:")
 term.setCursorPos(1,2)
 local newName = read()
 term.setCursorPos(1,3)
 term.write("Enter the individual number of " .. newName)
 term.setCursorPos(1,4)
 local newNumber = tonumber(read())
 term.setCursorPos(1,5)
 print("Enter the name of the product, which gets produced by this bee:")
 term.setCursorPos(1,7)
 local newProduct = read()
 term.setCursorPos(1,8)
 print("Select a color for this bee (click it)")
 for c=1,14 do
  term.setBackgroundColor(colorName[c])
  term.setCursorPos(2*c-1,10)
  term.write("  ")
  term.setCursorPos(2*c-1,11)
  term.write("  ")
 end
 term.setBackgroundColor(colors.black)
 local newColor = colors.white
 while true do
  local event = {os.pullEvent("mouse_click")}
  if event[4] == 10 or event[4] == 11 and event[3] <= 28 then
   newColor = colorName[math.ceil(event[3]/2)]
   break
  end
 end
 term.setCursorPos(1,13)
 term.setTextColor(newColor)
 term.write("Do you want to add this alveary to your list? (click it)")
 term.setCursorPos(1,14)
 term.write("YES")
 term.setCursorPos(1,15)
 term.write("NO")
 while true do
  local event = {os.pullEvent("mouse_click")}
  if event[4] == 14 then
   clear()
   term.redirect(monitor)
   alveary[selectedHeight][x][y] = {newName, newNumber, newProduct, newColor, 0}
   if type(product[newProduct]) == "nil" then
    product[newProduct] = 0
   end
   saveVar()
   return
  elseif event[4] == 15 then
   clear()
   term.redirect(monitor)
   return
  end
 end
end

-- DRAW

function clear()
 term.clear()
 term.setCursorPos(1,1)
end

function draw()
 -- BUTTONS
 term.clear()
 term.setBackgroundColor(colorName[colorNumber])
 for y=1,29 do
  term.setCursorPos(1,y)
  term.write("     ")
 end
 for button=1,3 do
  local color = colors.black
  if button == selectedHeight then
   color = colors.lime
  end
  term.setBackgroundColor(color)
  term.setCursorPos(1,5*button-4)
  term.write("    ")
  term.setCursorPos(1,5*button)
  term.write("    ")
  for y=5*button-3, 5*button-1 do
   term.setCursorPos(4,y)
   term.write(" ")
  end
 end
 local color = colors.black
 if mode == "add" then
  color = colors.lime
 elseif mode == "switch" then
  color = colors.red
 end
 term.setBackgroundColor(color)
 term.setCursorPos(1,17)
 term.write("    ")
 term.setCursorPos(1,21)
 term.write("    ")
 for y=18,20  do
  term.setCursorPos(4,y)
  term.write(" ")
 end
 local color = colors.black
 if autoShutdown then
  color = colors.lime
 end
 term.setBackgroundColor(color)
 term.setCursorPos(1,22)
 term.write("    ")
 term.setCursorPos(1,26)
 term.write("    ")
 for y=23,25  do
  term.setCursorPos(4,y)
  term.write(" ")
 end
 if colorNumber == 15 then
  term.setTextColor(colors.white)
 else
  term.setTextColor(colors.black)
 end
 term.setBackgroundColor(colorName[colorNumber])
 term.setCursorPos(2,3)
 term.write("A")
 term.setCursorPos(2,8)
 term.write("B")
 term.setCursorPos(2,13)
 term.write("C")
 term.setCursorPos(2,19)
 term.write("+")
 term.setCursorPos(2,24)
 term.write("A")
 
-- ALVEARIES
 term.setBackgroundColor(colors.black)
 for x=1,4 do
  for y=1,4 do
   if alveary[selectedHeight][x][y][2] == 0 and (mode == "add" or mode == "switch") then
    centeredAt("NONE", x*13, y*6-2, colors.white)
   end
   if alveary[selectedHeight][x][y][2] > 0 then
    centeredAt(tostring(alveary[selectedHeight][x][y][1] .. " " .. alveary[selectedHeight][x][y][2]) , x*13, y*6-2, alveary[selectedHeight][x][y][4])
    if alveary[selectedHeight][x][y][5] == 1 then
     centeredAt("ON", x*13, y*6-1, colors.lime)
    else
     centeredAt("OFF", x*13, y*6-1, colors.red)
    end
    if product[alveary[selectedHeight][x][y][3]] == 1 then
     centeredAt("FULL", x*13, y*6, colors.red)
    end
   end
  end
 end
 term.setTextColor(colors.white)
end


-- CHECK TOUCH

function checkForAlvearySlot(xPos,yPos)
 local var = {0,0}
 for i=1,4 do
  for j=1,4 do
   if xPos >= (13*i)-5 and xPos <= (13*i)+5 and yPos >= (6*j)-3 and yPos <= (6*j) then
    if mode == "add" or mode == "switch" or alveary[selectedHeight][i][j][2] > 0 then
     var[1], var[2] = i,j
     break
    end
   end
  end
 end
 return var
end

function checkTouch()
 saveVar()
 local event = { os.pullEvent() }
 if event[1] == "monitor_touch" then
  local xPos, yPos = event[3], event[4]
  if xPos <= 4 then
   if yPos >= 1 and yPos <= 5 then
    selectedHeight = 1
   elseif yPos >= 6 and yPos <= 10 then
    selectedHeight = 2
   elseif yPos >= 11 and yPos <= 15 then
    selectedHeight = 3
   elseif yPos >= 17 and yPos <= 21 then
    if mode == "turnOnOrOff" then
     mode = "add"
    else
     mode = "turnOnOrOff"
    end
   elseif yPos >= 22 and yPos <= 26 then
    autoShutdown = not autoShutdown
   end
  elseif xPos == 5 then
   colorNumber = colorNumber + 1
   if colorNumber == 16 then
    colorNumber = 1
   end
  else
   local var = checkForAlvearySlot(xPos,yPos)
   local x,y = var[1], var[2]
   if x > 0 then
    if mode == "turnOnOrOff" then
     if alveary[selectedHeight][x][y][5] == 1 then
      alveary[selectedHeight][x][y][5] = 0
      rednet.broadcast(textutils.serialize({"TurnOff", alveary[selectedHeight][x][y][1], alveary[selectedHeight][x][y][2] }))
     elseif alveary[selectedHeight][x][y][5] == 0 then
      alveary[selectedHeight][x][y][5] = 1
      rednet.broadcast(textutils.serialize({"TurnOn", alveary[selectedHeight][x][y][1], alveary[selectedHeight][x][y][2] }))
     end
     sleep(0.1)
    elseif mode == "add" then
     addAlveary(x,y)
    elseif mode == "switch" then
     local temp = alveary[selectedHeight][x][y]
     alveary[selectedHeight][x][y] = alveary[temporaryAlveary[1]][temporaryAlveary[2]][temporaryAlveary[3]]
     alveary[temporaryAlveary[1]][temporaryAlveary[2]][temporaryAlveary[3]] = temp
     mode = "add"
    end
   end
  end
 elseif event[1] == "rednet_message" then
  local message = textutils.unserialize(event[3])
  if type(message[1]) == "string" and message[1] == "full" then
   local selectedAlveary = {}
   local times = 0
   for h=1,3 do
    for x=1,4 do
     for y=1,4 do
      if alveary[h][x][y][3] == message[2] then
       table.insert(selectedAlveary, 1, {h,x,y})
       times = times + 1
      end
     end
    end
   end
   if times == 0 then return end
   for k,v in pairs(selectedAlveary) do
    product[alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][3]] = 1
    if autoShutdown then
     alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][5] = 0
      rednet.broadcast(textutils.serialize({"TurnOff", alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][1], alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][2] }))
    end  
   end
  elseif type(message[1]) == "string" and message[1] == "notFull" then
   local selectedAlveary = {}
   local times = 0
   for h=1,3 do
    for x=1,4 do
     for y=1,4 do
      if alveary[h][x][y][3] == message[2] then
       table.insert(selectedAlveary, 1, {h,x,y})
       times = times + 1
      end
     end
    end
   end
   if times == 0 then return end
   for k,v in pairs(selectedAlveary) do
    product[alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][3]] = 0
    if autoShutdown then
     alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][5] = 1
      rednet.broadcast(textutils.serialize({"TurnOn", alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][1], alveary[selectedAlveary[k][1]][selectedAlveary[k][2]][selectedAlveary[k][3]][2] }))
    end  
   end 
  end
 end
end


-- RUN

loadVar()
while true do
 draw()
 checkTouch()
end