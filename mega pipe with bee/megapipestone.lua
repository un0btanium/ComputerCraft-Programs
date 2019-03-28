-- MEGA STONE PIPE 0.1.0

local speed = 0.5
os.setComputerLabel("MegaPipeStone")
if not fs.exists("comb") then
 shell.run("pastebin","get","YUrtgM6X","comb")
end
term.clear()
term.setCursorPos(1,1)
 
local comb = paintutils.loadImage("comb")

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
 sleep(speed-0.1)
 if type(m[1]) == "string" and m[1] == "MegaPipeStone" then
  if m[2] == "comb" then
   for y=19,-17, -1 do
    term.clear()
    paintutils.drawImage(comb, 1, y)
    sleep(speed)
   end
  end
 end
end


while true do
 run()
end