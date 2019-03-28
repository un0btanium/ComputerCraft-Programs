local version = "Turtle Trading Station Beta 0.3.0"
local working = false
local trade = 0
local maxChestSlots = 27
local turtleID = os.getComputerID()
local computerID = 1
local chest = {}
w,h = term.getSize()
-- chest[left|right][Name|Amount][x][y]
for a=1,2 do
 chest[a] = {}
 for b=1,2 do
  chest[a][b] = {}
  for c=1,4 do
   chest[a][b][c] = {}
   for d=1,4 do
    if b == 1 then
     chest[a][b][c][d] = "ttsEmpty"
    else
     chest[a][b][c][d] = -1
    end
   end
  end
 end
end

rednet.open("right")


function printCentered(str, ypos)
 term.setCursorPos(w/2 - #str/2, ypos)
 term.write(str)
end
 
function printCopyright()
 local str = "by UNOBTANIUM"
 term.setCursorPos(w-#str, h)
 term.write(str)
end
 
function printHeader(title, line)
 printCentered(title, line)
 printCentered(string.rep("-", w), line+1)
end

function printReplace(str,line)
 printCentered(string.rep(" ", w), line)
 printCentered(str, line)
end

function clearScreen()
 term.clear()
 term.setCursorPos(1,1)
 term.clear()
end

local function transfer(i)
 if i == 2 then
  return 1
 elseif i == 3 then
  return 2
 elseif i == 4 then
  return 3
 elseif i == 5 then
  return 4
 elseif i == 6 then
  return 5
 elseif i == 7 then
  return 6
 elseif i == 8 then
  return 7
 elseif i == 9 then
  return 8
 elseif i == 9 then
  return 9
 elseif i == 10 then
  return 0
 elseif i == 17 then
  return "w"
 elseif i == 30 then
  return "a"
 elseif i == 31 then
  return "s"
 elseif i == 32 then
  return "d"
 elseif i == 28 then
  return "enter"
 elseif i == 14 then
  return "backspace"
 else
  return ""
 end
end

function countArray(array)
 local x = 0
 for k,v in pairs(array) do
  x = x + 1
 end
 return x
end

function countItems(first, last)
 local amount = 0
 for i=first,last do
  amount = amount + turtle.getItemCount(i)
 end
 return amount
end

function suckDownSlots(first, last)
 for i=first,last do
  if turtle.getItemCount(i) == 0 then
   turtle.select(i)
   turtle.suckDown()
  end
 end
end

function suckSlots(first, last)
 for i=first,last do
  if turtle.getItemCount(i) == 0 then
   turtle.select(i)
   turtle.suck()
  end
 end
end

function dropDownSlots(first, last)
 for i=first,last do
  if turtle.getItemCount(i) > 0 then
   turtle.select(i)
   turtle.dropDown()
  end
 end
end

function dropSlots(first, last)
 for i=first,last do
  if turtle.getItemCount(i) > 0 then
   turtle.select(i)
   turtle.drop()
  end
 end
end


--MESSAGE

function sendMessage(sendingmessage)
 sendingmessage = tostring(sendingmessage)
 while true do
  repeat
   rednet.send(computerID,sendingmessage)
   senderChannel, message, distance = rednet.receive(1)
  until type(message) == "string"
  if senderChannel == computerID then
   sleep(0.1)
   return
  end
 end
end
 
function receiveMessage()
 while true do
  local senderChannel, receivedmessage = rednet.receive() 
  if senderChannel == computerID then
   sleep(0.1)
   rednet.send(computerID,"successful")
   return receivedmessage
  end
 end
end

function sendSuccess()
 rednet.send(turtleID,"successful")
end


-- SAVE & LOAD

function loadVariables()
 if not fs.exists("ttsVariables") then
  return false
 end
 local file = fs.open("ttsVariables","r")
 computerID = tonumber(file.readLine())
 maxChestSlots = tonumber(file.readLine())
 working = file.readLine()
 for a=1,2 do
  for b=1,2 do
   for c=1,4 do
    for d=1,4 do
     if b == 1 then
      chest[a][b][c][d] = file.readLine()
     else
      chest[a][b][c][d] = tonumber(file.readLine())
     end
    end
   end
  end
 end
 file.close()
 return true
end


function saveVariables()
 local file = fs.open("ttsVariables", "w")
 file.writeLine(computerID)
 file.writeLine(maxChestSlots)
 file.writeLine(working)
 for a=1,2 do
  for b=1,2 do
   for c=1,4 do
    for d=1,4 do
     file.writeLine(chest[a][b][c][d])
    end
   end
  end
 end
 file.close()
end

-- MOVEMENT

function moveToChest(side,x,y,action,slot,amount)
 if action == "suck" or action == "drop" then
  moveCoord(0,x-1,y-1,side)
  if action == "suck" then
   turtle.select(slot)
   turtle.suck()
   turtle.drop((0-amount)+turtle.getItemCount(slot))
   chest[side][2][x][y] = chest[side][2][x][y] - amount
  else
   turtle.select(slot)
   turtle.drop(amount)
   chest[side][2][x][y] = chest[side][2][x][y] + amount
  end
  moveCoord(side,-(x-1),-(y-1),0)
 elseif action == "get" then
  local amountitems = 0
  while amount > 0 do
   moveCoord(0,x-1,y-1,side)
   suckSlots(1,16)
   amountitems = countItems(1,16)
   while amountitems > amount do
    local selectedslot = 1
    while turtle.getItemCount(selectedslot) == 0 do
     selectedslot = selectedslot + 1
    end
    turtle.select(selectedslot)
    local amountDrop = 0
    if (amountitems - turtle.getItemCount(selectedslot)) >= amount then
     amountDrop = turtle.getItemCount(selectedslot)
    else
     for i=1, turtle.getItemCount(selectedslot) do
      if amountitems-i == amount then
       amountDrop = i
       break
      end
     end
    end
    turtle.drop(amountDrop)
    amountitems = amountitems - amountDrop   
   end
   moveCoord(side,-(x-1),-(y-1),0)
   amount = amount - countItems(1,16)
   dropSlots(1,16)
  end
 elseif action == "store" then
  while amount > 0 do
   print(amount .. "   " .. math.floor(amount/64))
   suckDownSlots(1,16)
   moveCoord(0,x-1,y-1,side)
   print("Moving to chest to store...")
   amount = amount - countItems(1,16)
   dropSlots(1,16)
   moveCoord(side,-(x-1),-(y-1),0)
   print("Moving to base...")
  end
  print(amount .. "   " .. math.floor(amount/64))
  print("Finished!")
  sleep(1)
 end
end


function moveCoord(side,x,y,sideend)
 if side == 1 then
  turtle.turnLeft()
 elseif side == 2 then
  turtle.turnRight()
 end
 if x > 0 then
  for i=1,x do
   while not turtle.back() do sleep(1) end
  end
 elseif x < 0 then
  x = -x
  for i=1,x do
   while not turtle.forward() do sleep(1) end
  end 
 end

 if y > 0 then
  for i=1,y do
   while not turtle.up() do sleep(1) end
  end
 elseif y < 0 then
  y = -y
  for i=1,y do
   while not turtle.down() do sleep(1) end
  end 
 end

 if sideend == 1 then
  turtle.turnRight()
 elseif sideend == 2 then
  turtle.turnLeft()
 end
end

-- TRADE

function dropUntilNothingIsLeft()
 dropSlots(2,16)
 turtle.select(2)
 repeat
  turtle.drop()
 until not turtle.suckDown()
 
end

function trade()
 local offerItemName = receiveMessage()
 local amountOffer = tonumber(receiveMessage())
 local demandItemName = receiveMessage()
 local amountDemand = tonumber(receiveMessage())
 local side = 0
 local chestX = 0
 local chestY = 0
 local Oside = 0
 local OchestX = 0
 local OchestY = 0
 local timesOffer = 0
 local timesDemand = 0
 local insertDemand = 0

 for a=1,2 do
  for c=1,4 do
   for d=1,4 do
    if chest[a][1][c][d] == demandItemName and side == 0 then
     side = a
     chestX = c
     chestY = d
    end
   end
  end
 end

 for a=1,2 do
  for c=1,4 do
   for d=1,4 do
    if chest[a][1][c][d] == offerItemName and Oside == 0 then
     Oside = a
     OchestX = c
     OchestY = d
    end
   end
  end
 end

 if side == 0 or Oside == 0 then --error: no name found
  sendMessage(-4)
  return
 end

 timesOffer = math.floor(chest[Oside][2][OchestX][OchestY] / amountOffer)

 if chest[side][1][chestX][chestY] == 0 or timesOffer == 0 then --no items left to trade with
  sendMessage(-2)
  return
 end

 turtle.select(2)
 if not turtle.suck() then
  sendMessage(0)
  return
 end

 moveToChest(side,chestX,chestY,"suck",1,1)
 local lastSlot = 17
 local currentSlot = 2
 turtle.select(currentSlot)
 if not turtle.compareTo(1) then
  lastSlot = lastSlot - 1
  turtle.transferTo(lastSlot)
 else
  currentSlot = 3
  turtle.select(currentSlot)
 end

 while turtle.suck() do
  if not turtle.compareTo(1) then
   lastSlot = lastSlot - 1
   turtle.select(currentSlot)
   turtle.transferTo(lastSlot)
  end
  if lastSlot == 10 then
   sendMessage(-1)
   dropUntilNothingIsLeft()
   moveToChest(side,chestX,chestY,"drop",1,1)
   return
  end
  if lastSlot - 1 == currentSlot then
   insertDemand = insertDemand + countItems(2,currentSlot)
   dropDownSlots(2,currentSlot)
   currentSlot = 2
  else
   currentSlot = currentSlot + 1
  end
  turtle.select(currentSlot)
 end

 if lastSlot <= 16 then
  dropSlots(lastSlot,16)
 end
 insertDemand = insertDemand + countItems(2,lastSlot-1)
 
 if insertDemand == 0 then
  sendMessage(0)
  moveToChest(side,chestX,chestY,"drop",1,1)
  return
 end
 
 timesDemand = math.floor(insertDemand / amountDemand)
 local tradeTimes = 0

 local allmost = false

 if timesDemand == 0 then
  sendMessage(-3)
  dropUntilNothingIsLeft()
  moveToChest(side,chestX,chestY,"drop",1,1)
  return
 elseif timesDemand <= timesOffer then
  tradeTimes = timesDemand
 elseif timesDemand > timesOffer then
  allmost = true
  tradeTimes = timesOffer
 end

 while (chest[side][2][chestX][chestY] + (tradeTimes * amountDemand)) > (64*maxChestSlots) and tradeTimes >= 1 do
  tradeTimes = tradeTimes - 1
  allmost = true
 end

 if tradeTimes == 0 then
  sendMessage(-5)
  dropUntilNothingIsLeft()
  moveToChest(side,chestX,chestY,"drop",1,1)
  return
 end

 if allmost then
  sendMessage(-6)
 end
 sendMessage(tradeTimes)

 if receiveMessage() == "trade canceled"  then
  dropUntilNothingIsLeft()
  moveToChest(side,chestX,chestY,"drop",1,1)
  return
 end

 dropDownSlots(1,16)

 local leftover = insertDemand - (tradeTimes*amountDemand)
 turtle.select(1)
 print("Leftover: " .. leftover)
 local slotamount = 0
 while leftover > 0 do
  turtle.suckDown()
  slotamount = turtle.getItemCount(1)
  if slotamount <= leftover then
   turtle.drop()
   leftover = leftover - slotamount
  else
   for i=1,slotamount do
    if (leftover - i) == 0 then
     turtle.drop(i)
     turtle.dropDown()
     leftover = leftover - i
     break
    end
   end
  end
 end

 moveToChest(Oside,OchestX,OchestY,"get",0,(tradeTimes*amountOffer))
 chest[Oside][2][OchestX][OchestY] = chest[Oside][2][OchestX][OchestY] - (tradeTimes*amountOffer)
 sendMessage("finished")
 chest[side][2][chestX][chestY] = chest[side][2][chestX][chestY] + (tradeTimes*amountDemand) + 1
 moveToChest(side,chestX,chestY,"store",0,(tradeTimes*amountDemand) + 1)
end

-- NEW ITEM

function addNewItem()
 turtle.select(1)
 turtle.suck()
 if turtle.getItemCount(1) == 0 then
  sendMessage("Place a freaking item in the chest!!!")
  return
 elseif turtle.getItemCount(1) >= 2 then
  sendMessage("Just one item...")
  turtle.drop()
  return
 end
 
 local side = 0
 local chestX = 0
 local chestY = 0
 for c=1,4 do
  for d=1,4 do
   for a=1,2 do
    if chest[a][1][c][d] == "ttsEmpty" and side == 0 then
     side = a
     chestX = c
     chestY = d
    end
   end
  end
 end

 if side == 0 then
  sendMessage("All chests are full!")
  turtle.drop()	
  return
 end
 
 sendMessage("successful")
 local name = receiveMessage()
 chest[side][1][chestX][chestY] = name
 moveToChest(side,chestX,chestY,"drop",1,1)
end

-- GET INFO

function getInfo()
 if turtle.getFuelLevel() < 500 then
  sendMessage("Please refuel your turtle!")
  sendMessage("Fuel Level: " .. turtle.getFuelLevel())
  sendMessage(" ")
  return
 end
 for c=1,4 do
  for d=1,4 do
   for a=1,2 do
    if chest[a][2][c][d] >= 0 then
     if chest[a][2][c][d] < 16 then
      sendMessage("There are just " .. chest[a][2][c][d] .. " " .. chest[a][1][c][d] .. "s left.")
      sendMessage("Please refill the chest, otherwise this item")
      sendMessage("wont be available for any trades")
      return
     elseif chest[a][2][c][d] == 0 then
      sendMessage("There are no " .. chest[a][1][c][d] .. "s left.")
      sendMessage("Please refill the chest, otherwise this item")
      sendMessage("wont be available for any trades")
      return
     elseif chest[a][2][c][d] == maxChestSlots*64 or chest[a][2][c][d] == maxChestSlots*16 then
      sendMessage("The " .. chest[a][1][c][d] .. " chest might be full!")
      sendMessage("Items in it: " .. chest[a][2][c][d])
      sendMessage("Take some items out if possible.")
      return
     end
    end
   end
  end
 end
 sendMessage("Turtle is fine!")
 sendMessage(" ")
 sendMessage(" ")
end

-- GET AMOUNT ITEM

function getAmountItem()
 local name = receiveMessage()
 local amount = -1
 for c=1,4 do
  for d=1,4 do
   for a=1,2 do
    if chest[a][1][c][d] == name and amount == -1 then
     amount = chest[a][2][c][d]
    end
   end
  end
 end
 return amount
end

-- GET ITEMS

function getItems()
 local name = receiveMessage()
 local amount = tonumber(receiveMessage())
 local side = 0
 local X = 0
 local Y = 0
 for c=1,4 do
  for d=1,4 do
   for a=1,2 do
    if chest[a][1][c][d] == name and side == 0 then
     side = a
     X = c
     Y = d
    end
   end
  end
 end
 if side == 0 then
  sendMessage("No items found!")
  return
 end
 chest[side][2][X][Y] = chest[side][2][X][Y] - amount
 moveToChest(side,X,Y,"get",0,amount)
 sendMessage(" ")
end

--REFILL CHEST

function refill()
 local name = receiveMessage()
 print("Refilling " .. name .. " chest!")
 local side = 0
 local chestX = 0
 local chestY = 0
 for c=1,4 do
  for d=1,4 do
   for a=1,2 do
    if chest[a][1][c][d] == name and side == 0 then
     side = a
     chestX = c
     chestY = d
    end
   end
  end
 end

 if side == 0 then
  sendMessage("No items found!")
  return
 end

 print("Moving to chest...")
 moveToChest(side,chestX,chestY,"suck",1,1)
 local currentSlot = 2
 local lastSlot = 17
 local insertDemand = 0
 turtle.select(currentSlot)
 while turtle.suck() do
  if not turtle.compareTo(1) then
   lastSlot = lastSlot - 1
   turtle.select(currentSlot)
   turtle.transferTo(lastSlot)
  end
  if lastSlot == 10 then
   sendMessage("Give me the right kind of item!!!")
   dropUntilNothingIsLeft()
   moveToChest(side,chestX,chestY,"drop",1,1)
   return
  end
  if lastSlot -1 == currentSlot then
   insertDemand = insertDemand + countItems(2,currentSlot)
   dropDownSlots(2,currentSlot)
   currentSlot = 2
  else
   currentSlot = currentSlot + 1
  end
  turtle.select(currentSlot)
 end
 print("Finished comparing.")
 if lastSlot <= 16 then
  dropSlots(lastSlot,16)
 end
 insertDemand = insertDemand + countItems(2,15)
 
 if insertDemand == 0 then
  sendMessage("There are no items in the chest!!!")
  moveToChest(side,chestX,chestY,"drop",1,1)
  return
 end

 turtle.select(1)
 turtle.dropDown()

 sendMessage("Placing items in the chest...")
 chest[side][2][chestX][chestY] = chest[side][2][chestX][chestY] + insertDemand + 1
 moveToChest(side,chestX,chestY,"store",0,insertDemand + 1)
end


-- WAITING MENU


function run()
 clearScreen()
 if not loadVariables() then
  print("The turtle's ID is: " .. turtleID)
  print("Enter the computer ID: ")
  sleep(0.5)
  computerID = tonumber(read())
  saveVariables()
 end
 while true do
  clearScreen()
  print("Waiting for message...")
  print("Turtle ID: " .. turtleID)
  print("Fuel Level: " .. turtle.getFuelLevel())
  saveVariables()
  local message = receiveMessage()
 
  if message == "indicator item" then
   addNewItem()
  elseif message == "trade" then
   if receiveMessage() == "trade goes on" then
    trade()
   end
  elseif message == "information" then
   getInfo()
  elseif message == "refuel" then
   turtle.select(1)
   while turtle.suck() do
    turtle.refuel()
   end
   dropSlots(1,16)
  elseif message == "change slot amount" then
   maxChestSlots = tonumber(receiveMessage())
  elseif message == "refill" then
   refill()
  elseif message == "get amount item" then
   local amount = getAmountItem()
   print("sendingMessage")
   sendMessage(amount)
  elseif message == "get items" then
   getItems()
  end
 end
end




run()