-- MEGA WOODEN PIPE SEGMENT 0.1.0

local speed = 0.5

os.setComputerLabel("MegaPipeAlveary")
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

function run()
 clear()
 local id, message = rednet.receive()
 local m = textutils.unserialize(message)
 if type(m[1]) == "string" and m[1] == "MegaPipeAlveary" then
  if m[2] == "bee" or m[2] == "princess" then
   local beeImage = princess
   if m[2] == "bee" then
    beeImage = bee
   end
   for y=19,4, -1 do
    term.clear()
    paintutils.drawImage(beeImage, 1, y)
    sleep(speed)
   end
   for x=1,-28, -2 do
    term.clear()
    paintutils.drawImage(beeImage, x, 4)
    sleep(speed)
   end
  end
 
  if m[2] == "comb" then
   for y=19,-17, -1 do
    term.clear()
    paintutils.drawImage(comb, 1, y)
    sleep(speed)
    if y == -17 then
     rednet.broadcast(textutils.serialize({"MegaPipeStoneSegment","comb"}))
    end 
   end
  end
 end
end



while true do
 run()
end