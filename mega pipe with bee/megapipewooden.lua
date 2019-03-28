-- MEGA WOODEN PIPE 0.1.0

local speed = 0.5
local routine = 180
local timeRemaining = 10


os.setComputerLabel("MegaPipeWooden")
if not fs.exists("bee") then
 shell.run("pastebin","get","7geFYhut","bee")
end
if not fs.exists("princess") then
 shell.run("pastebin","get","5GLf6ZCB","princess")
end
if not fs.exists("comb") then
 shell.run("pastebin","get","YUrtgM6X","comb")
end
term.clear()
term.setCursorPos(1,1)

local bee = paintutils.loadImage("bee")
local comb = paintutils.loadImage("comb")
local princess = paintutils.loadImage("princess")

rednet.open("top")

local monitor = peripheral.wrap("back")
term.redirect(monitor)


function clear()
 term.clear()
 term.setCursorPos(1,1)
end


function saveTime()
 local file = fs.open("MegaPipeTime", "w")
  file.writeLine(timeRemaining)
 file.close()
end

function loadTime()
 if not fs.exists("MegaPipeTime") then timeRemaining = 10 return end
 local file = fs.open("MegaPipeTime", "r")
  timeRemaining = tonumber(file.readLine())
 file.close()
end



function run()
 if timeRemaining > 0 then
  timeRemaining = timeRemaining - 1
  sleep(1)
  saveTime()
  return
 end

 timeRemaining = routine/2
 saveTime()
 local amountBees = math.ceil(math.random()*3)
 local amountItems = math.floor(math.random()*3)

 for i=1,amountBees do
  local beeImage = princess
  if i>1 then
   beeImage = bee
  end 
  for x=-30, 1, 2 do
   term.clear()
   paintutils.drawImage(beeImage, x, 4)
   sleep(speed)
  end

  for y=4,-14, -1 do
   term.clear()
   paintutils.drawImage(beeImage, 1, y)
   sleep(speed)
   if y == -6 then
    if i == 1 then
     rednet.broadcast(textutils.serialize({"MegaPipeWoodenSegment","princess"}))
    else
     rednet.broadcast(textutils.serialize({"MegaPipeWoodenSegment","bee"}))
    end
   end
  end
  sleep(3)
 end

 for i=1,amountItems do
  for x=-30, 1, 2 do
   term.clear()
   paintutils.drawImage(comb, x, 4)
   sleep(speed)
  end

  for y=4,-14, -1 do
   term.clear()
   paintutils.drawImage(comb, 1, y)
   sleep(speed)
   if y == -6 then
    rednet.broadcast(textutils.serialize({"MegaPipeWoodenSegment","comb"}))
   end 
  end
  sleep(3)
 end
 timeRemaining = routine
 saveTime()
end





loadTime()
while true do
 run()
end