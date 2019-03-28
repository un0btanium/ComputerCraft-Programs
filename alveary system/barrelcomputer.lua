local barrel = {}
local state = {false,false,false}

rednet.open("right")

function clear()
 term.clear()
 term.setCursorPos(1,1)
end

function saveVar()
 local file = fs.open("BeeBarrelStorage","w")
 for b=1,3 do
  file.writeLine(barrel[b])
  file.writeLine(state[b])
 end
 file.close()
end

function loadVar()
 if not fs.exists("BeeBarrelStorage") then setVar() return end
 local file = fs.open("BeeBarrelStorage","r")
  for b=1,3 do
   barrel[b] = file.readLine()
   c = file.readLine()
   if c == "true" then
    state[b] = true
   else
    state[b] = false
   end
  end
 file.close()
end

function setVar()
 clear()
 print("Which product is in the left barrel?")
 barrel[3] = read()
 print("Which product is in the middle barrel?")
 barrel[2] = read()
 print("Which product is in the right barrel?")
 barrel[1] = read()
 print("Is this right?")
 print("Y/N")
 while true do
  local event = {os.pullEvent("char")}
  if event[2] == "n" then
   setVar()
   return
  else
   saveVar()
   return
  end
 end
end

function sendFull(b)
 rednet.broadcast(textutils.serialize({"full",barrel[b]}))
 sleep(0.5)
end

function sendNotFull(b)
 rednet.broadcast(textutils.serialize({"notFull", barrel[b]}))
 sleep(0.5)
end


function check()
 print("Left: " .. barrel[3])
 print("Middle: " .. barrel[2])
 print("Right: " .. barrel[1])
 local event = {os.pullEvent("redstone")}
 local b = 0
 local side = ""
 if not state[1] == redstone.getInput("front") then
  b = 1
  side = "front"
 elseif not state[2] == redstone.getInput("left") then
  b = 2
  side = "left"
 elseif not state[3] == redstone.getInput("back") then
  b = 3
  side = "back"
 end
 if b == 0 then
  print("Wrong side!")
  return
 end
 if redstone.getInput(side) then
  sendFull(b)
  state[b] = true
 else
  sendNotFull(b)
  state[b] = false
 end
 saveVar()
end

loadVar()
while true do
 check()
end