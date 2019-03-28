local modemSide = "top"
local version, versionnumber = "Turtle Trading Station Beta 0.3.0", "0.3.0"
local pw = {6,7,8}
local offerItemName, offerAmount, demandItemName, demandAmount = {},{},{},{}
local offer, demand = {},{}
local welcomeText = ""
local maxChestSlots = 27
local tradesAvailable = 0
local computerID = os.getComputerID()
local turtleID = 1
w,h = term.getSize()

rednet.open(modemSide)

--chest[left|right][horizontal][vertical][name|amount]

--
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

function transfer(i)
 local keynames = {"<",1,2,3,4,5,6,7,8,9,
0,"-","+","backspace","tabulator","q","w","e","r","t",
"y","u","i","o","p"," "," ","enter","left ctrg","a",
"s","d","f","g","h","j","k","l","ü","ä",
"ö","left shift","<","z","x","c","v","b","n","m",
",",".","","right shift","*","alt","spacebar","caps lock","left alt","spacebar",
"right alt","","right ctrg","left","down","right","num lock","","","",
7,8,9,"-",4,5,6,"+",1,2,
3,"","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"/","","","","","","","","","",
"","","","","","","","","","up",
"","","left","","right","","","down","","", 
"right shift","","","","","","","","windows",""
}
 return keynames[i]
end

function countArray(array)
 local x = 0
 for k,v in pairs(array) do
  x = x + 1
 end
 return x
end


--MESSAGE

function sendMessage(sendingmessage)
 sendingmessage = tostring(sendingmessage)
 while true do
  repeat
   rednet.send(turtleID,sendingmessage)
   id, message, distance = rednet.receive(1)
  until type(message) == "string"
  if id == turtleID then
   sleep(0.1)
   return
  end
 end
end
 
function receiveMessage()
 while true do
  local senderChannel, receivedmessage = rednet.receive()
  if senderChannel == turtleID then
   sleep(0.1)
   rednet.send(turtleID,"successful")
   return receivedmessage
  end
 end
end

-- PASSWORT

function checkPasswort(input)
 local nameOne = ""
 local nameTwo = ""
 if countArray(input) >= countArray(pw) then
  for i=1,countArray(pw) do
   nameOne = nameOne .. pw[i]
   nameTwo = nameTwo .. input[(countArray(input)-countArray(pw))+i]
  end
  if nameOne == nameTwo then
   return true
  end
 end
 return false
end

-- SAVE & LOAD

function loadVariables()
 if not fs.exists("ttsVariables") then
  return false
 end
 local amount = 0
 local file = fs.open("ttsVariables","r")
 turtleID = math.floor(tonumber(file.readLine()))
 maxChestSlots = tonumber(file.readLine())
 tradesAvailable = tonumber(file.readLine())
 welcomeText = file.readLine()
 amount = math.floor(tonumber(file.readLine()))
 if amount >= 1 then
  for i=1,amount do
   pw[i] = math.floor(tonumber(file.readLine()))
  end
 end
 amount = math.floor(tonumber(file.readLine()))
 if amount >= 1 then
  for i=1,amount do
   demand[i] = file.readLine()
  end
 end
 amount = math.floor(tonumber(file.readLine()))
 if amount >= 1 then
  for i=1,amount do
   offer[i] = file.readLine()
  end
 end
 file.close()
 return true
end


function saveVariables()
 local file = fs.open("ttsVariables", "w")
 file.writeLine(turtleID)
 file.writeLine(maxChestSlots)
 file.writeLine(tradesAvailable)
 file.writeLine(welcomeText)
 if countArray(pw) > 0 then
  file.writeLine(countArray(pw))
  for i=1, countArray(pw) do
   file.writeLine(pw[i])
  end
 else
  file.writeLine("0")
 end
 if countArray(demand) > 0 then
  file.writeLine(countArray(demand))
  for i=1, countArray(demand) do
   file.writeLine(demand[i])
  end
 else
  file.writeLine("0")
 end
 if countArray(offer) > 0 then
  file.writeLine(countArray(offer))
  for i=1, countArray(offer) do
   file.writeLine(offer[i])
  end
 else
  file.writeLine("0")
 end
 file.close()
end


function loadTrades()
 if not fs.exists("ttsTrades") then
  return false
 end
 loadVariables()
 if tradesAvailable == 0 then return false end
 local file = fs.open("ttsTrades","r")
 for i=1,tradesAvailable do
  offerItemName[i] = file.readLine()
  offerAmount[i] = tonumber(file.readLine())
  demandItemName[i] = file.readLine()
  demandAmount[i] = tonumber(file.readLine())
 end
 file.close()
 return true
end

function saveTrades()
 local file = fs.open("ttsTrades","w")
 for i=1,tradesAvailable do
  file.writeLine(offerItemName[i])
  file.writeLine(offerAmount[i])
  file.writeLine(demandItemName[i])
  file.writeLine(demandAmount[i])
 end
 file.close()
end

-- SINGULAR OR PLURAL

function SorP(amount)
 if amount == 1 then
  return ""
 end
 return "s"
end

-- RUN

function run()
 local running = true
 loadTrades()
 if not loadVariables() then
  Options()
  running = adminMenu()
 end
 while running do
  if countArray(pw) > 0 then
   userMenu()
  else
   Options()
  end
  running = adminMenu()
 end
end

-- SUB ADMIN MENUS



function changeSlots()
 clearScreen()
 printHeader("Change Slot Amount",1)
 printCentered("How many slots does each chest have? (Number)",4)
 local input = tonumber(read())
 if input > 1 then
  maxChestSlots = input
  sendMessage("change slot amount")
  sendMessage(maxChestSlots)
  printReplace("Change the slot amount to: " .. maxChestSlots, 5)
 end
 saveVariables()
end

function Options()
 clearScreen()
 printHeader("Passwort",1)
 printCentered("Tipe a passwort (doesnt get shown)",4)
 printCentered("Save with Enter",5)
 local keypress = {}
 local id, key = 0, 0
 local passwort = ""
 sleep(0.5)
 while true do
  id, key = os.pullEvent("key")
  if key == 28 then
   break
  else
   table.insert(keypress, key)
  end
 end
 if countArray(keypress) > 0 then
  if not next(pw) == nil then
   for k,v in pairs(pw) do
    pw[k] = nil
   end   
  end
  for k,v in pairs(keypress) do
   pw[k] = keypress[k]
   passwort = passwort .. transfer(keypress[k])
  end
 end
 printCentered(passwort,6)
 sleep(0.6)
 clearScreen()
 printHeader("Turtle ID", 1)
 printCentered("Type in the turtle's ID",4)
 printCentered("Otherwise they dont communicate with each other.",6)
 printCentered("Current Turtle ID: " .. turtleID,7)
 printCentered("Computer ID: " .. computerID, 8)
 printCentered("",10)
 sleep(0.5)
 local input = tonumber(read())
 if input then
  input = tonumber(input)
  if input >= 1 and input <= 65555 then
   turtleID = input
  end
 end
 printReplace("Current ID: " .. turtleID,7)
 sleep(0.5)
 clearScreen()
 printHeader("Welcome Text",1)
 printCentered("Write down a text for the customers",3)
 printCentered("Leave it empty if you dont want to change it",4)
 print("")
 local input = read()
 if input == "" then else
 welcomeText = input
 end
 saveVariables()
end

function selectFromAll()
 local name = {}
 if demand[1] == nil then
  return 0
 end
 for i=1,countArray(demand) do
  table.insert(name, 1, demand[i])
 end
 for i=1,countArray(offer) do
  local exists = false
  for j=1,countArray(demand) do
   if offer[i] == name[j] then
    exists = true
   end
  end
  if not exists then
   table.insert(name,1, offer[i])
  end
 end
 
 local names = countArray(name)
 local more = 0
 local selectedItemName = ""
 local choosing = true

 while choosing do
  clearScreen()
  printHeader("Item Names " .. more + 1 .. " to " .. more + 8 ,1)
  for i=1,8 do
   if i+more <= names then
    printCentered(i .. " - " .. name[i+more], i+2)
   end
  end
  if names >= 8+more then
   printCentered("9 - Other items ", 11)
  elseif names <= 8+more and names >= 8 then  
   printCentered("9 - Back to first items", 11)
  end
  printCentered("0 - Back to the menu", 12)

  local id, key = os.pullEvent("key")
  local input = transfer(key)
  
  if input >= 1 and input <= 8 then
   if input+more <= names then
    return name[input+more]
   end
  elseif input == 9 then
   if names >= 8+more then
    more = more + 8
   elseif names <= 8+more and names >= 8 then  
    more = 0
   end
  elseif input == 0 then
   return 0
  end
 end
end

function getItems()
 local itemname = selectFromAll()
 if type(itemname) == "string" then
  clearScreen()
  printHeader("Getting " .. itemname,1)
  printCentered("Amount items in the chest:", 5)
  printCentered("Receiving information",6)
  sendMessage("get amount item")
  sendMessage(itemname)
  local amount = tonumber(receiveMessage())
  if amount == 0 then
   printReplace("No items left!",6)
   sleep(2)
   return
  end
  printReplace(tostring(amount), 6)
  sleep(0.5)
  printCentered("How many items do you want? (Number)",7)
  printCentered("",8)
  input = tonumber(read())
  printReplace("", 8)
  if input == 0 or input > amount then
   printReplace("Amount is zero or too high!!!",7)
   sleep(2)
   return
  end
  printReplace("Getting your " .. input .. " " .. itemname .. SorP(amount) .. "...",7)
  sendMessage("get items")
  sendMessage(itemname)
  sendMessage(input)
  receiveMessage()
  printReplace("Take the items out of the chest",7)
  sleep(3)
 end
end

function refillChests()
 local itemname = selectFromAll()
 if type(itemname) == "string" then
  clearScreen()
  printHeader("Refill Chest",1)
  printCentered("Place your " .. itemname .. "s into the chest!",4)
  printCentered("Press Enter to continue...",5)
  local id, key = os.pullEvent("key")
  local input = transfer(key)
  if not input == "enter" then
   replaceCentered("Canceled",5)
   sleep(1)
   return
  end
  printReplace("Checking...",5)
  sendMessage("refill")
  sendMessage(itemname)
  local m = receiveMessage()
  printReplace(m,5)
  sleep(3) 
 end
end


-- MENU (ADMIN)

function adminMenu()
 local message = {}
 table.insert(message, 1, "")
 table.insert(message, 2, "Welcome!")
 table.insert(message, 3, "")
 while true do
  clearScreen()
  printHeader("Turtle Trading Station ADMIN",1)
  printHeader("",3)
  printHeader("",5)
  printHeader("",7)
  printHeader("",9)
  printHeader("",11)
  printHeader("",15)
  if maxChestSlots <= 99 then
   printCentered("     1 - Start      |    6 - Slots: " .. maxChestSlots .. "   ",3)
  else
   printCentered("     1 - Start      |    6 - Slots: " .. maxChestSlots .. "  ",3)  
  end
  printCentered("     2 - Add        |    7 - Options     ",5)
  printCentered("     3 - Get        |    8 - Get Info    ",7)
  printCentered("     4 - Refill     |    9 - Help        ",9)
  printReplace("     5 - Refuel     |    0 - Quit        ",11)
  printCentered(message[1],13)
  printCentered(message[2],14)
  printReplace(message[3],15)
  term.setCursorPos(1,18)
  print(computerID .. "              TTS ".. versionnumber .. "            by UNOBTANIUM")
  
  if message[2] == "Receiving information..." then
   table.remove(message, 1)
   table.remove(message, 1)
   table.remove(message, 1)
   sendMessage("information")
   table.insert(message, 1, receiveMessage())
   table.insert(message, 2, receiveMessage())
   table.insert(message, 3, receiveMessage())
  else
   local id, key = os.pullEvent("key")
   local input = transfer(key)
   sleep(0.2)
   if type(input) == "number" then
    if input == 0 then
     return false
    elseif input == 1 then
     return true
    elseif input == 2 then
     newTrade()
     saveVariables()
     saveTrades()
    elseif input == 3 then
     getItems()
     saveTrades()
    elseif input == 4 then
     refillChests()
     saveTrades()
    elseif input == 5 then
     sendMessage("refuel")
    elseif input == 6 then
     changeSlots()
    elseif input == 7 then
     Options()
    elseif input == 8 then
     table.remove(message, 1)
     table.remove(message, 1)
     table.remove(message, 1)
     table.insert(message, 1, "Connecting to turtle")
     table.insert(message, 2, "Receiving information...")
     table.insert(message, 3, "Please wait!")
    elseif input == 9 then
     -- help()
     clearScreen()
     print("If you are having a question, send me a pn or message post in the ComputerCraft forums.")
     print("Google: ComputerCraft Turtle Trading Station")
     print("Press Enter to leave...")
     read()
    end
   end
  end

 end
end

-- MENU (USER)

function userMenu()
 local keypress = {}
 while true do
  clearScreen()
  printCopyright()
  printHeader("Turtle Trading Station", 1)
  printCentered("Press a number key to navigate", 2)
  printCentered("1 - Demand", 6)
  printCentered("2 - Supply", 7)
  term.setCursorPos(1,10)
  print(welcomeText)
  
  local id, key = os.pullEvent("key")
  table.insert(keypress, key)
  if checkPasswort(keypress) then
   return
  end
  local input = transfer(key)

  if type(input) == "number" then
   if input == 1 then
    local tradenumber = selectDemand()
    if tradenumber > 0 then
     tradeMenu(tradenumber)
    end
   elseif input == 2 then
    local tradenumber = selectOffer()
    if tradenumber > 0 then
     tradeMenu(tradenumber)
    end
   elseif input == 3 then
    newTrade()
   end
  end
 end
end

-- MENU (TRADE)

function tradeMenu(trade)
 sendMessage("trade")
 clearScreen()
 printHeader("Purchase Overview", 1)
 printCentered("You give",4)
 printCentered(demandAmount[trade] .. " " .. demandItemName[trade] .. SorP(demandAmount[trade]),5)
 printCentered("You get",7)
 printCentered(offerAmount[trade] .. " " .. offerItemName[trade] ..SorP(offerAmount[trade]),8)
 printCentered("Place all your " .. demandItemName[trade] .. "s in the chest.",10)
 printCentered("ENTER - Accept the purchase",11)
 printCentered("BACKSPACE - Cancel the purchase", 12)
 local id, key = 0, ""
 local input = ""
 while true do
  id, key = os.pullEvent("key")
  input = transfer(key)
  if type(input) == "string" and input == "enter" then
   sendMessage("trade goes on")
   break
  elseif type(input) == "string" and input == "backspace" then
   sendMessage("trade canceled")
   return
  end
 end

 clearScreen()
 printHeader("Purchase in Final Progress", 1)
 printCentered("Sending purchase information to turtle...", 3)
 sendMessage(offerItemName[trade]) -- Oak Wood
 sendMessage(offerAmount[trade])   -- 8
 sendMessage(demandItemName[trade])-- Iron Ingot
 sendMessage(demandAmount[trade])  -- 1
 printReplace("Sending trade information completed!",3)
 printCentered("Counting all your " .. demandItemName[trade] .. "s...",4)
 local tradeTimes =  tonumber(receiveMessage()) -- trade times
 printReplace("Counting your " .. demandItemName[trade] .. "s completed!",4)
 term.setCursorPos(1,5)
 if tradeTimes == 0 then
  print("No items found in the chest...")
  sleep(3)
  return
 elseif tradeTimes == -1 then
  print("Place the right kind of item in the chest!!!")
  sleep(3)
  return
 elseif tradeTimes == -2 then
  print("Sorry, there are no or not enough " .. offerItemName[trade] .. "s left.")
  sleep(3)
  return
 elseif tradeTimes == -3 then
  print("You didnt placed enough " .. demandItemName[trade] .. " in the chest!")
  sleep(3)
  return
 elseif tradeTimes == -4 then
  print("ERROR: Something messed up! No item found!")
  sleep(3)
  return
 elseif tradeTimes == -5 then
  print("Sorry, this trades has been made too many times. There can be no more " .. demandItemName[trade] .. "s stored.")
  sleep(3)
  return
 elseif tradeTimes == -6 then
  tradeTimes = receiveMessage()
  printCentered("- Purchase goes allmost fine -",5)
 else
  printCentered("- Purchase goes completely fine -",5)
 end
 
 printCentered("You get",6)
 printCentered(tradeTimes*offerAmount[trade] .. " " .. offerItemName[trade] .. SorP(tradeTimes*offerAmount[trade]) .. " for" ,7)
 printCentered(tradeTimes*demandAmount[trade] .. " of your " .. demandItemName[trade] .. SorP(tradeTimes*demandAmount[trade]), 8)
 term.setCursorPos(1,10)
 print("ENTER - Accept the purchase and get the " .. offerItemName[trade] .. SorP(tradeTimes*offerAmount[trade]))
 printCentered("BACKSPACE - Cancel the purchase", 12)
 local id, key = 0, ""
 local input = ""
 while true do
  id, key = os.pullEvent("key")
  input = transfer(key)
  if type(input) == "string" and input == "enter" then
   break
  elseif type(input) == "string" and input == "backspace" then
   sendMessage("trade canceled")
   return
  end
 end
 printReplace("Getting your " .. offerItemName[trade] .. SorP(tradeTimes*offerAmount[trade]),12)
 printReplace("",10)
 printReplace("",11)
 printReplace("",12)
 sendMessage("trade accepted")
 receiveMessage()
 printReplace("That's it! Thank you for your purchase",14)
 sleep(5)
 return
end

-- SELECT OFFER

function selectOffer()
 local offers = countArray(offer)
 local more = 0
 local selectedOfferName = ""
 local choosing = true

 while choosing do
  clearScreen()
  printHeader("Supplies " .. more+1 .. " to " .. more+8,1)
  for i=1,8 do
   if i+more <= offers then
    printCentered(i .. " - " .. offer[i+more], i+2)
   end
  end
  if offers >= 8+more then
   printCentered("9 - Other supplies ", 11)
  elseif offers <= 8+more and offers >= 8 then  
   printCentered("9 - Back to first supplies", 11)
  end
  printCentered("0 - Back to the menu", 12)

  local id, key = os.pullEvent("key")
  local input = transfer(key)
  
  if type(input) == "number" then
   if input >= 1 and input <= 8 then
    if input+more <= offers then
     selectedOfferName = offer[input+more]
     choosing = false
    end
   elseif input == 9 then
    if offers >= 8+more then
     more = more + 8
    elseif offers <= 8+more and offers >= 8 then  
     more = 0
    end
   elseif input == 0 then
    return 0
   end
  end
 end
 
 clearScreen()
 local fittingTrades = {}
 for i=1,tradesAvailable do
  if offerItemName[i] == selectedOfferName then
   table.insert(fittingTrades, 1, i)
  end
 end

 choosing = true
 more = 0
 local amountFittingTrades = countArray(fittingTrades)
 while choosing do
  clearScreen()
  printHeader("Demands for " .. selectedOfferName .. " " .. more+1 .. " to " .. more+8,1)
  for i=1,8 do
   if i+more <= amountFittingTrades then
    printCentered(i .. " - Get " .. offerAmount[fittingTrades[i+more]] .. " " .. offerItemName[fittingTrades[i+more]] .. " for " .. demandAmount[fittingTrades[i+more]] .. " " .. demandItemName[fittingTrades[i+more]] , i+2)
   end
  end
  if amountFittingTrades >= 8+more then
   printCentered("9 - Other fitting trades ", 11)
  elseif amountFittingTrades <= 8+more and amountFittingTrades >= 8 then  
   printCentered("9 - Back to first trades", 11)
  end
  printCentered("0 - Back to the menu", 12)

  local id, key = os.pullEvent("key")
  local input = transfer(key)
  
  if type(input) == "number" then
   if input >= 1 and input <= 8 then
    if input+more <= amountFittingTrades then
     return fittingTrades[input+more]
    end
   elseif input == 9 then
    if amountFittingTrades >= 8+more then
     more = more + 8
    elseif amountFittingTrades <= 8+more and amountFittingTrades >= 8 then  
     more = 0
    end
   elseif input == 0 then
    return 0
   end
  end
 end
end



-- SELECT DEMAND

function selectDemand()
 local demands = countArray(demand)
 local more = 0
 local selectedDemandName = ""
 local choosing = true

 while choosing do
  clearScreen()
  printHeader("Demands " .. more+1 .. " to " .. more+8,1)
  for i=1,8 do
   if i+more <= demands then
    printCentered(i .. " - " .. demand[i+more], i+2)
   end
  end
  if demands >= 8+more then
   printCentered("9 - Other demands ", 11)
  elseif demands <= 8+more and demands >= 8 then  
   printCentered("9 - Back to first demands", 11)
  end
  printCentered("0 - Back to the menu", 12)

  local id, key = os.pullEvent("key")
  local input = transfer(key)

  if type(input) == "number" then  
   if input >= 1 and input <= 8 then
    if input+more <= demands then
     selectedDemandName = demand[input+more]
     choosing = false
    end
   elseif input == 9 then
    if demands >= 8+more then
     more = more + 8
    elseif demands <= 8+more and demands >= 8 then  
     more = 0
    end
   elseif input == 0 then
    return 0
   end
  end
 end

 clearScreen()
 local fittingTrades = {}
 for i=1,tradesAvailable do
  if demandItemName[i] == selectedDemandName then
   table.insert(fittingTrades, i)
  end
 end

 choosing = true
 more = 0
 local amountFittingTrades = countArray(fittingTrades)
 while choosing do
  clearScreen()
  printHeader("Supplies for " .. selectedDemandName .. " " .. more+1 .. " to " .. more+8,1)
  for i=1,8 do
   if i+more <= amountFittingTrades then
    printCentered(i .. " - Get " .. offerAmount[fittingTrades[i+more]] .. " " .. offerItemName[fittingTrades[i+more]] .. " for " .. demandAmount[fittingTrades[i+more]] .. " " .. demandItemName[fittingTrades[i+more]] , i+2)
   end
  end
  if amountFittingTrades >= 8+more then
   printCentered("9 - Other fitting trades ", 11)
  elseif amountFittingTrades <= 8+more and amountFittingTrades >= 8 then  
   printCentered("9 - Back to first trades", 11)
  end
  printCentered("0 - Back to the menu", 12)

  local id, key = os.pullEvent("key")
  local input = transfer(key)

  if type(input) == "number" then  
   if input >= 1 and input <= 8 then
    if input+more <= amountFittingTrades then
     return fittingTrades[input+more]
    end
   elseif input == 9 then
    if amountFittingTrades >= 8+more then
     more = more + 8
    elseif amountFittingTrades <= 8+more and amountFittingTrades >= 8 then  
     more = 0
    end
   elseif input == 0 then
    return 0
   end
  end
 end
end



-- CREATE NEW TRADE

function newTrade()
 clearScreen()
 local demands = countArray(demand)
 local more = 0
 local selectedDemandName = ""
 local selectedOfferName = ""
 local selectedAmountDemand = 0
 local selectedAmountOffer = 0
 local choosing = true

 while choosing do
  clearScreen()
  printHeader("Create new purchase: Select demand", 1)
  for i=1,6 do
   if i+more <= demands then
    printCentered(i .. " - " .. demand[i],i+2)
   end
  end
  printCentered("8 - New demand", 10)
  if demands >= 6+more then
   printCentered("9 - Other demands ", 11)
  elseif demands <= 6+more and demands >= 6 then  
   printCentered("9 - Back to first demands", 11)
  end

  printCentered("0 - Back to the menu", 12)

  local id, key = os.pullEvent("key")
  local input = transfer(key)

  if type(input) == "number" then  
   if input >= 1 and input <= 6 then
    if input+more <= demands then
     selectedDemandName = demand[input+more]
     choosing = false
    end
   elseif input == 8 then
    clearScreen()
    print("Which item do you want from the customers? (Name/Singular) (Demand)")
    print("")
    sleep(0.2)
    selectedDemandName = read()
    choosing = false
   elseif input == 9 then
    if demands >= 6+more then
     more = more + 6
    elseif demands <= 6+more and demands >= 6 then  
     more = 0
    end
   elseif input == 0 then
    return 0
   end
  end
 end

 clearScreen()
 print("Which item do you give the customers for " .. selectedDemandName .. "(s)? (Name/Singular) (Supply)")
 print("")
 sleep(0.2)
 selectedOfferName = read()
 
 clearScreen()
 print("How many " .. selectedDemandName .."(s) do you want? (Number) (Demand)")
 print("")
 selectedAmountDemand = tonumber(read())

 clearScreen()
 print("How many " .. selectedOfferName .. "(s) do you give for the " .. selectedAmountDemand .. " " .. selectedDemandName .. "? (Number/Singular) (Supply)")
 print("")
 selectedAmountOffer = tonumber(read())

 clearScreen()
 printHeader("Add new purchase",1)
 printCentered("You get",5)
 printCentered(selectedAmountDemand .. " " .. selectedDemandName .. SorP(selectedAmountDemand) .. " for", 6)
 printCentered(selectedAmountOffer .. " " .. selectedOfferName .. SorP(selectedAmountOffer), 7)
 printCentered("ENTER - Add the purchase",11)
 printCentered("BACKSPACE - Back to the menu", 12)
 local id, key = 0, ""
 local input = ""
 while true do
  id, key = os.pullEvent("key")
  input = transfer(key)
  if type(input) == "string" and input == "enter" then
   break
  elseif type(input) == "string" and input == "backspace" then
   return
  end
 end

 local exists = false
 for i=1,countArray(demand) do
  if demand[i] == selectedDemandName then
   exists = true
  end
 end
 if not exists then
  table.insert(demand,selectedDemandName)
  for i=1,countArray(offer) do
   if offer[i] == selectedDemandName then
    exists = true
   end
  end
  if not exists then
   local competentUser = false
   clearScreen()
   while not competentUser do
    print("Place one item of ".. selectedDemandName .." into the chest and press Enter... (Indicator Item) (Demand)")
    local id, key = os.pullEvent("key")
    local input = transfer(key)
    if input == "enter" then
     sendMessage("indicator item")
     local message = receiveMessage()
     if message == "successful" then
      sendMessage(selectedDemandName)
      competentUser = true
     else
      clearScreen()
      print(message)
     end
    end
   end
  end
 end

 exists = false
 for i=1,countArray(offer) do
  if offer[i] == selectedOfferName then
   exists = true
  end
 end
 if not exists then
  table.insert(offer,selectedOfferName)
  for i=1,countArray(demand) do
   if demand[i] == selectedOfferName then
    exists = true
   end
  end
  if not exists then
   local competentUser = false
   clearScreen()
   while not competentUser do
    print("Place one item of ".. selectedOfferName .." into the chest and press Enter... (Indicator Item) (Supply)")
    local id, key = os.pullEvent("key")
    local input = transfer(key)
    if input == "enter" then
     sendMessage("indicator item")
     local message = receiveMessage()
     if message == "successful" then
      sendMessage(selectedOfferName)
      competentUser = true
     else
      clearScreen()
      print(message)
      if message == "All chests are full!" then
       sleep(2)
       return
      end
     end
    end
   end
  end
 end 

 clearScreen()
 printCentered("Adding new purchase...", 6)
 table.insert(offerItemName, 1,selectedOfferName)
 table.insert(offerAmount, 1,selectedAmountOffer)
 table.insert(demandItemName, 1,selectedDemandName)
 table.insert(demandAmount, 1,selectedAmountDemand)
 tradesAvailable = tradesAvailable + 1
 saveVariables()
 saveTrades()
 printCentered("Finished!", 7)
 sleep(0.5)
 clearScreen()
end

-- TTS

run()