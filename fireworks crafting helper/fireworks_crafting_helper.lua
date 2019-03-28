-- Fireworks Crafting Helper by UNOBTANIUM
-- VERSION 1.0.0

local w, h = term.getSize()
local fancy = term.isColor and term.isColor()
local color = {"white","orange","magenta","light blue", "yellow","lime","pink","gray","light gray","cyan","purple","blue","brown","green","red","black"}
local colorName = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}
local dye = {"bonemeal","orange dye","magenta dye","light blue dye", "dandelion yellow","lime dye ","pink dye","gray dye","light gray dye","cyan dye","purple dye","blue dye","cocoa bean","cactus green","rose red","ink sac"}
local ingredient = {"bone from skeleton","red rose + dandelion yellow","purple dye + pink dye","lapis lazuli + bone meal", "yellow dandelion (flower)","cactus green + bone meal ","rose red + bone meal","ink sac + bonemeal","ink sac + 2 bone meal","lapis lazuli + cactus green","rose red + lapis lazuli","lapis lazuli","cocoa plant on jungle trees","cactus (furnace)","rose (flower)","squid"}

function clear()
 term.clear()
 term.setCursorPos(1,1)
end

function clearLine(y)
 term.setCursorPos(1,y)
 term.clearLine()
end

function printHeader(text,y)
 centered(text,y)
 centered(string.rep("-", w), y+1)
end

function centered(text,y,c)
 c = c or colors.white
 term.setCursorPos(math.ceil(w/2)-math.ceil(#tostring(text)/2)+1,y)
 if fancy then
  if c == colors.black then
   term.setBackgroundColor(colors.white)
  end
  term.setTextColor(c)
 end
 term.write(tostring(text))
 if fancy then
  term.setBackgroundColor(colors.black)
 end
end

function left(text,x,y,c)
 c = c or colors.white
 term.setCursorPos(x,y)
 if fancy then
  if c == colors.black then
   term.setBackgroundColor(colors.white)
  end
  term.setTextColor(c)
 end
 term.write(text)
 if fancy then
  term.setBackgroundColor(colors.black)
 end
end

function drop(slot)
 slot = slot or 0
 for i=1,16 do
  if turtle.getItemCount(i) > 0 and not i == slot then
   turtle.select(i)
   turtle.drop()
  end
 end
end




function mainMenu()
 while true do
  clear()
  printHeader("FIREWORKS CRAFTING HELPER",1)
  centered("Navigate with your keyboard keys", 4)
  left("S - Create Firework Star", 7, 7)
  left("R - Create Rocket", 7, 9)
  left("Q - Exit", 7, 11)
  term.setCursorPos(w-13,h)
  term.write("by UNOBTANIUM")
  local event = {os.pullEvent("char")}
  if event[2] == "s" then
   createStar()
  elseif event[2] == "r" then
   drop()
   createRocket()
  elseif event[2] == "q" then
   clear()
   term.write(os.version())
   term.setCursorPos(1,2)
   return
  end
 end
end

function placeInv(var)
 if var <= 3 then slot = var
 elseif var == 4 then slot = 5
 elseif var == 5 then slot = 6
 elseif var == 6 then slot = 7
 elseif var == 7 then slot = 9
 elseif var == 8 then slot = 10
 elseif var == 9 then slot = 11
 end
 turtle.select(slot)
 while true do
  sleep(0.1)
  if turtle.getItemCount(slot) > 0 then
   break
  end
 end
end

function info()
 centered("First line says which item you have",3)
 centered("to place into the selected slot.",4)
 centered("The second line explains, where",5)
 centered("you get the item from.",6)
end

function countArray(a)
 local amount = 0
 for k,v in pairs(a) do
  amount = amount + 1
 end
 return amount
end

function createStar()
 local slot = 3
 clear()
 printHeader("CREATING FIREWORK STAR",1)
 printHeader("SELECT SHAPE",3)
 left("W - Small Ball", 7, 7)
 left("A - Large Ball", 7, 8)
 left("S - Star-shaped", 7, 9)
 left("D - Burst", 7, 10)
 left("C - Creeper Shaped", 7, 11)
 local shapeName = "Shape: Small Ball"
 local shape = 0
 while true do
  local event = {os.pullEvent("char")}
  if event[2] == "w" then
   slot = slot - 1
   break
  elseif event[2] == "a" then
   shapeName = "Shape: Large Ball"
   shape = 1
   break
  elseif event[2] == "s" then
   shapeName = "Shape: Star"
   shape = 2
   break
  elseif event[2] == "d" then
   shapeName = "Shape: Burst"
   shape = 3
   break
  elseif event[2] == "c" then
   shapeName = "Shape: Creeper Face"
   shape = 4
   break
  end
 end

 clear()
 printHeader("CREATING FIREWORK STAR",1)
 printHeader("SELECT EFFECT (optional)",3)
 left("W - No effect", 10, 7)
 left("A - Trail", 10, 9)
 left("S - Twinkle", 10, 11)
 local effect = 0
 local effectName = "No Effect"
 while true do
  local event = {os.pullEvent("char")}
  if event[2] == "w" then
   slot = slot - 1
   break
  elseif event[2] == "a" then
   effectName = "Effect: Trail"
   effect = 1
   break
  elseif event[2] == "s" then
   effectName = "Effect: Twinkle"
   effect = 2
   break
  end
 end

 clear()
 local number = 1
 local counter = 1
 local selectedColors = {}
 printHeader("CREATING FIREWORK STAR",1)
 left("Q - Back to the main menu", 10, 13)
 while true do
  clearLine(2)
  if counter+slot < 9 then
   printHeader("SELECT " .. counter .. ". COLOR",2)
  else
   printHeader("REACHED MAXIMUM COLOR AMOUNT",2)
  end
  centered("<(A)                         (D)>",5)
  centered(color[number], 5, colorName[number])
  if slot+counter <= 9 then
   left("W - Add color", 10, 10)
  else
   clearLine(10)
  end
  local x,y = 9,7
  local str = {}
  local length = {}
  local colori = {}
  clearLine(7) clearLine(8) clearLine(9)
  for k,v in pairs(selectedColors) do
   table.insert(str,k,color[v]..", ")
   table.insert(length,k,#str[k])
   table.insert(colori,k,colorName[v])
  end
  left("Colors:",1,7)
  for i=1, countArray(selectedColors) do
   if x+length[i] > 39 then y = y + 1 x = 1 end
   term.setCursorPos(x,y)
   left(str[i],x,y,colori[i])
   x = x + length[i]
  end
  if counter >= 2 then
   left("S - No more color", 10, 11)
   left("R - Delete last color",10,12)
  else
   clearLine(11)
  end
  local event = {os.pullEvent("char")}
  if event[2] == "w" and slot+counter <= 9 then
   table.insert(selectedColors, countArray(selectedColors)+1, number)
   counter = counter + 1
  elseif event[2] == "s" and counter >= 2 then
   break
  elseif event[2] == "r" and counter >= 2 then
   table.remove(selectedColors)
   counter = counter - 1
  elseif event[2] == "q" then
   return
  elseif event[2] == "d" then
   number = number + 1
  elseif event[2] == "a" then
   number = number - 1
  end
  if number <= 0 then
   number = 16
  elseif number >= 17 then
   number = 1
  end
 end

 clear()
 printHeader("CREATING FIREWORK STAR",1)
 printHeader("SELECT FADE COLOR (optional)",3)
 left("W - Select", 10, 11)
 left("S - No fade color!!!", 10 ,12) 
 local fadeColor = 1
 while true do
  centered("<(A)                         (D)>",8)
  centered(color[fadeColor], 8,colorName[fadeColor])
  local event = {os.pullEvent("char")}
  if event[2] == "w" then
   break
  elseif event[2] == "s" then
   fadeColor = 0
   break
  elseif event[2] == "d" then
   fadeColor = fadeColor + 1
  elseif event[2] == "a" then
   fadeColor = fadeColor - 1
  end
  if fadeColor <= 0 then
   fadeColor = 16
  elseif fadeColor >= 17 then
   fadeColor = 1
  end
 end

 drop()
 while true do
  clear()
  printHeader("CREATING FIREWORK STAR",1)
  printHeader("FINAL OVERVIEW",2)
  local str = {}
  local length = {}
  local colori = {}
  local x,y = 14,5
  for k,v in pairs(selectedColors) do
   table.insert(str,k,color[v]..", ")
   table.insert(length,k,#str[k])
   table.insert(colori,k,colorName[v])
  end
  left("Colors: ",6,5)
  for i=1, countArray(selectedColors) do
   if x+length[i] > 39 then y = y + 1 x = 1 end
   term.setCursorPos(x,y)
   left(str[i],x,y,colori[i])
   x = x + length[i]
   if y >= 8 then term.setCursorPos(35,y-1) term.write(" ect.") break end
  end
  if fadeColor == 0 then
   left("No Fade Color",6,y+1)
  else
   left("Fade Color:",6,y+1)
   left(color[fadeColor],18,y+1,colorName[fadeColor])
  end
  left(shapeName,6,y+2)
  left(effectName,6,y+3)
  
  left("W - Craft", 10, y+4)
  left("S - Back To The Main Menu", 10 , y+5)
  while true do
   local event = {os.pullEvent("char")}
   if event[2] == "w" then
    break
   elseif event[2] == "s" then
    return
   end
  end
  clear()
  printHeader("CREATING FIREWORK STAR",1)
  info()
  centered("Gunpowder",8)
  centered("Creeper (Mob)",9)
  placeInv(1)
  clearLine(8) clearLine(9)
  for k,v in pairs(selectedColors) do
   centered(dye[v],8)
   centered(ingredient[v],9)
   placeInv(k+1)
   clearLine(8) clearLine(9)
  end
  if shape > 0 then
   if shape == 1 then
    centered("Fire Charge",8)
    centered("Blaze Powder + Coal + Gun Powder",9)
   elseif shape == 2 then
    centered("Gold Nugget",8)
    centered("Gold Ingot",9)
   elseif shape == 3 then
    centered("Feather",8)
    centered("Chicken",9)
   elseif shape == 4 then
    centered("Any Head",8)
    centered("From Mobs (Wither Skelet)",9)
   end
   placeInv(countArray(selectedColors)+2)
   clearLine(8) clearLine(9)
  end
  if effect > 0  then
   if effect == 1 then
    centered("Diamond",8)
    centered("Underground/Mining",9)
   elseif effect == 2 then
    centered("Glowstone Dust",8)
    centered("Glowstone from the Nether",9)
   end
   placeInv(countArray(selectedColors)+3)
   clearLine(8) clearLine(9)
  end
  turtle.select(16)
  clear()
  printHeader("CREATING FIREWORK STAR",1)
  centered("Hit any key to create the star(s)!",8)
  os.pullEvent("char")
  if not turtle.craft() then
   clear()
   centered("Something went wrong!",5)
   sleep(1.6)
   return
  end
  if fadeColor > 0 then
   clear()
   drop(16)
   turtle.select(16)
   turtle.transferTo(1)
   printHeader("CREATING FIREWORK STAR",1)
   info()
   centered(dye[fadeColor],8)
   centered(ingredient[fadeColor],9)
   placeInv(2)
   clearLine(8) clearLine(9)
   turtle.select(16)
   clear()
   printHeader("CREATING FIREWORK STAR",1)
   centered("Hit any key to create the star(s)!",8)
   os.pullEvent("char")
   turtle.craft()
  end
  clear()
  centered("FINISHED",5)
  centered("Take out your firework star(s)!",6)
  left("W - Create Again",10,7)
  left("S - Back To The Main Menu",10,8)
  sleep(0.5)
  while true do
   local event = {os.pullEvent("char")}
   if event[2] == "w" then
    break
   elseif event[2] == "s" then
    return
   end
  end
 end
end

function increaseSlot(s)
 s = s + 1
 if s == 4 or s == 8 then
  s = s + 1
 end
 return s
end

function createRocket()
 clear()
 printHeader("CREATING ROCKET",1)
 info()
 centered("Paper",8)
 centered("Sugar Cane",9)
 placeInv(1)
 clearLine(8) clearLine(9) clearLine(3) clearLine(4) clearLine(5) clearLine(6)
 centered("Flight Height:",5)
 centered("A - ~16 blocks",6)
 centered("S - ~28 blocks",7)
 centered("D - ~48 blocks",8)
 local slots = 1
 while true do
  local event = {os.pullEvent("char")}
  if event[2] == "a" then
   slots = 2
   break
  elseif event[2] == "s" then
   slots = 3
   break
  elseif event[2] == "d" then
   slots = 4
   break
  end
 end
 clearLine(5) clearLine(6) clearLine(7) clearLine(8)
 info()
 centered("Gunpowder",8)
 centered("Creeper (Mob)",9)
 for i=2,slots do
  if i == 4 then i = 5 end
  placeInv(i)
 end
 clearLine(8) clearLine(9) clearLine(3) clearLine(4) clearLine(5) clearLine(6)
 centered("Place your firework stars",6)
 centered("into the selected slot.",7)
 centered("Hold any key if you dont want",8)
 centered("to add any more firework stars.",9)
 local slot = slots + 1
 if slot == 4 then slot = 5 end
  local delay = os.startTimer(0.11)
 while true do
  turtle.select(slot)
  local event = {os.pullEvent()}
  if event[1] == "timer" then
   if turtle.getItemCount(slot) > 0 then
    slot = increaseSlot(slot)
    if slot == 12 then break end
   end
   delay = os.startTimer(0.11)
  elseif event[1] == "key" then
   break
  end
 end
 turtle.select(16)
 clear()
 if not turtle.craft() then
  centered("Something went wrong!",5)
  sleep(1.7)
  return
 end
 centered("FINISHED",5)
 centered("Take out your rocket(s)!",6)
 left("W - Create Again",10, 7)
 left("S - Back To The Main Menu",10,8)
 sleep(0.5)
 while true do
  local event = {os.pullEvent("char")}
  if event[2] == "w" then
   createRocket()
   return
  elseif event[2] == "s" then
   return
  end
 end
end



-- ERROR CHECK

clear()
if not turtle then
 print(os.version())
 print("You have to use a crafty turtle!")
 return
end
local ok, val = pcall(turtle.craft)
if not ok then
 print(os.version())
 print("You have to use a crafty turtle!")
 return
end

-- RUN

mainMenu()