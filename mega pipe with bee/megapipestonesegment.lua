-- MEGA WOODEN PIPE SEGMENT 0.1.0

local speed = 0.5

os.setComputerLabel("MegaPipeStoneSegment")
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
 local id, message = rednet.receive()
 local m = textutils.unserialize(message)
 sleep(speed-0.1)
 if type(m[1]) == "string" and m[1] == "MegaPipeStoneSegment" then
  if m[2] == "comb" then
   for y=12,-14, -1 do
    term.clear()
    paintutils.drawImage(comb, 1, y)
    sleep(speed)
    if y == -6 then
     rednet.broadcast(textutils.serialize({"MegaPipeStone","comb"}))
    end 
   end
  end
 end
end



while true do
 run()
end