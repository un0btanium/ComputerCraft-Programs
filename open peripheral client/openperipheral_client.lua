--0.5.2 by UNOBTANIUM 09.06.2015
local site = {}
local screen = {}
local selected = 1
local selectedObj = 1
local z = 1
local mode = "mainmenu"
local errorText = nil
local w,h = term.getSize()
w = w + 1
local updateInterval = 2
local delay = os.startTimer(0.5)
local colorName = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}
local colorHex = {0xFFFFFF,0xFF8800,0xFF8CFF,0x00FFFF,0xFFF700,0x00FF11,0xF7B5DE,0xBFBFBF,0x65A1D6,0xAF56B3,0x0000FF,0x754302,0x004000,0xFF0000,0x000000}
local rednetSide = {"top","bottom","right","front"}
local b = peripheral.wrap("left")
local net = peripheral.wrap("back")


-- type x y w h {c} {t} unit method {param} {var} minNumber maxNumber fadeout action

-- type text x y c
-- type x y text unit method maxNumber c cMax var param
-- type x y w h cBorder tBorder cBack tBack cOne tOne cTwo tTwo unit method maxNumber var param
-- type x y w h minNumber maxNumber c t fadeout unit method var param
-- type unit method operator limitNumber action
-- type x y w h liquid cBorder tBorder cBack tBack unit method maxNumber var param




-- tank with liquid
-- addLiquid(number x, number y, number width, number height, string liquid)
-- or?
-- addFluid(number x, number y, number width, number height, string liquid) add a box textured like a liquid to the screen
-- addIcon(number x, number y, string id, number meta) add an icom of an item to the screen (height width?)

for i=1, 199 do
 site[i] = {}
 screen[i] = {}
end


function save()
  local file = fs.open("openPeripheralClient","w")
    file.writeLine("OPEN PERIPHERAL CLIENT DATABASE")
    file.writeLine(string.gsub(textutils.serialize(site),"\n%S-",""))
    file.writeLine(string.gsub(textutils.serialize(screen),"\n%S-",""))
    file.writeLine(updateInterval)
    file.writeLine(selected)
  file.close()
end

function buildString(stringBuilder, site)
  stringBuilder = stringBuilder .. "{"
  local added = false
  for i, var in pairs(site) do -- VARIABLE
    added = true
    if type(var) == "string" then
      stringBuilder = stringBuilder .. "\"" .. var .. "\""
    elseif type(var) == "number" then
      stringBuilder = stringBuilder .. var
    elseif type(var) == "boolean" then
      stringBuilder = stringBuilder .. tostring(var)
    elseif type(var) == "table" then
      stringBuilder = buildString(stringBuilder, site[i])
    end
    stringBuilder = stringBuilder .. ","
  end
  if added then
    stringBuilder = stringBuilder:sub(1,stringBuilder:len()-1)
  end
  return stringBuilder .. "}"
end

function load()
  if not fs.exists("openPeripheralClient") then return end
  local file = fs.open("openPeripheralClient","r")
    local firstLine = file.readLine()
    if firstLine == "OPEN PERIPHERAL CLIENT DATABASE" then -- NEWEST since 0.5
      site = textutils.unserialize(file.readLine())
      screen = textutils.unserialize(file.readLine())
      updateInterval = tonumber(file.readLine())
      selected = tonumber(file.readLine())
      file.close()
    elseif firstLine == "OPEN PERIPHERAL CLIENT DATA" then -- since 0.3
      site = textutils.unserialize(file.readLine())
      file.close()
      oldLoad03()
    else -- OLDEST since 0.1
      file.close()
      oldLoad01()
    end
end

-- OLD LOAD

function oldLoad03()
  local newDB = {}
  for i=1,199 do
    newDB[i] = {}
  end

  for siteID, s in pairs(site) do
    for objID, obj in pairs(s) do
      if obj[1] == "text" then
        newDB[siteID][objID] = {type=obj[1],text=obj[2],x=obj[3],y=obj[4],color=obj[5]}
      elseif obj[1] == "box" then
        newDB[siteID][objID] = {type=obj[1],x=obj[2],y=obj[3],w=obj[4],h=obj[5],inner_color=obj[6],inner_transparency=obj[7],border_color=obj[8],border_transparency=obj[9]}
      elseif obj[1] == "number" then
        newDB[siteID][objID] = {type=obj[1],x=obj[2],y=obj[3],text=obj[4],unit=obj[5],method=obj[6],maxNumber=obj[7],text_standardColor=obj[8],text_maxNumberColor=obj[9],arguments=obj[10]}
      elseif obj[1] == "bar" then
        newDB[siteID][objID] = {type=obj[1],x=obj[2],y=obj[3],w=obj[4],h=obj[5],color=obj[6],transparency=obj[7],color2=obj[8],transparency2=obj[9],color3=obj[10],transparency3=obj[11],color4=obj[12],transparency4=obj[13],unit=obj[14],method=obj[15],maxNumber=obj[16], arguments=obj[17]}
      elseif obj[1] == "graphPillar" or obj[1] == "graphPoint" then
        newDB[siteID][objID] = {type=obj[1],x=obj[2],y=obj[3],w=obj[4],h=obj[5],minNumber=obj[6],maxNumber=obj[7],color=obj[8],transparency=obj[9],fadeout=obj[10],unit=obj[11],method=obj[12],arguments=obj[14]}
      elseif obj[1] == "frame" then
        newDB[siteID][objID] = {type=obj[1],frame=obj[2],x=obj[3],y=obj[4]}
      elseif obj[1] == "ALARM" then
        if obj[7] == "TEXT" then
          newDB[siteID][objID] = {type=obj[1] ,unit=obj[2], method=obj[3], arguments=obj[4], operator=obj[5], number=obj[6], action_type=obj[7],action_x=obj[8],action_y=obj[9],action_text=obj[10], action_text_color=obj[11]}
        elseif obj[7] == "ACTIVATION" then
          newDB[siteID][objID] = {type=obj[1] ,unit=obj[2], method=obj[3], arguments=obj[4], operator=obj[5], number=obj[6], action_type=obj[7],action_unit=obj[8],action_method=obj[9],action_arguments=obj[10]}
        elseif obj[7] == "REDNET" then
          newDB[siteID][objID] = {type=obj[1] ,unit=obj[2], method=obj[3], arguments=obj[4], operator=obj[5], number=obj[6], action_type=obj[7],action_text=obj[9]}
        else
          newDB[siteID][objID] = {type=obj[1] ,unit=obj[2], method=obj[3], arguments=obj[4], operator=obj[5], number=obj[6], action_type=obj[7]}
        end
      elseif obj[1] == "CHAT" then
        if obj[3] == "TEXT" then
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3],action_x=obj[4],action_y=obj[5],action_text=obj[6], action_text_color=obj[7]}
        elseif obj[3] == "ACTIVATION" then
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3],action_unit=obj[4],action_method=obj[5],action_arguments=obj[6]}
        elseif obj[3] == "REDNET" then
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3],action_text=obj[5]}
        else
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3]}
        end
      elseif obj[1] == "REDNET" then
        if obj[3] == "TEXT" then
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3],action_x=obj[4],action_y=obj[5],action_text=obj[6], action_text_color=obj[7]}
        elseif obj[3] == "ACTIVATION" then
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3],action_unit=obj[4],action_method=obj[5],action_arguments=obj[6]}
        elseif obj[3] == "REDNET" then
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3],action_text=obj[5]}
        else
          newDB[siteID][objID] = {type=obj[1],text=obj[2],action_type=obj[3]}
        end
      end
    end
  end
  site = newDB
  save()
  load()
end

function oldLoad01()
 if not fs.exists("openPeripheralClient") then return end
 local file = fs.open("openPeripheralClient","r")
  for i=1,198 do
   local amountObj = tonumber(file.readLine())
   for k=1,amountObj do
    local amountVars = tonumber(file.readLine())
    local typ = file.readLine()
    site[i][k] = {}
    site[i][k][1] = typ
    for m=2,amountVars do
     if typ == "text" then
      if m == 2 then
       site[i][k][m] = file.readLine()
      else
       site[i][k][m] = tonumber(file.readLine())
      end
     elseif typ == "box" then
       site[i][k][m] = tonumber(file.readLine())
     elseif typ == "number" then
      if m == 2 or m == 3 or m >= 7 then
       site[i][k][m] = tonumber(file.readLine())
      else
       site[i][k][m] = file.readLine()
      end
     elseif typ == "bar" then
      if (m >= 2 and m <=13) or m == 16 then
       site[i][k][m] = tonumber(file.readLine())
      else
       site[i][k][m] = file.readLine()
      end
     elseif typ == "graphPillar" or typ == "graphPoint" then
      if m >= 2 and m <= 9 then
       site[i][k][m] = tonumber(file.readLine())
      elseif m == 10 then
       if file.readLine() == "true" then
        site[i][k][m] = true
       else
        site[i][k][m] = false        
       end
      elseif m == 11 or m == 12 then
       site[i][k][m] = file.readLine()
      else
       local amount = tonumber(file.readLine())
       site[i][k][m] = {}
       for a=1,amount do
        site[i][k][m][a] = tonumber(file.readLine())
       end
      end
     elseif typ == "frame" then
       site[i][k][m] = tonumber(file.readLine())
     end
    end
   end
   save()
   load()
  end

 file.close()
end

function clear(color)
 color = color or colors.black
 term.setBackgroundColor(color)
 term.clear()
 term.setCursorPos(1,1)
end

function countArray(a)
 local amount = 0
 for k,v in pairs(a) do
  amount = amount + 1
 end
 return amount
end

function write(text,x,y,c)
 c = c or colors.white
 term.setCursorPos(x,y)
 term.setTextColor(c)
 term.write(text)
end

function centered(text,y,c)
 c = c or colors.white
 term.setCursorPos(w/2-math.ceil(#tostring(text)/2),y)
 term.setTextColor(c)
 term.write(tostring(text))
end

function fill(text,y)
 centered(string.rep(tostring(text), w), y)
end

function setColors(text,background)
 background = background or colors.lightGray
 term.setTextColor(text)
 term.setBackgroundColor(background)
end

function drawArrows(y)
  write("<",14,y)
  write(">",36,y)
end

-- CHECK ALARM AND ACTIVATIONS

function checkAlarm(chatCommand, rednetMessage) -- DONE 1
  chatCommand = chatCommand or ""
  rednetMessage = rednetMessage or ""
  local number = 0
  for objID, obj in pairs(site[199]) do
    if obj.type == "ALARM" then   -- ALARM
      number = table.remove(screen[199][objID]["values"], 1)
      if type(number) == "number" then -- ERROR
        if obj.operator == "=" and number == obj.number then
          makeAction(obj, objID)
        elseif obj.operator == ">" and number > obj.number then
          makeAction(obj, objID)
        elseif obj.operator == "<"and number < obj.number then
          makeAction(obj, objID)
        end
      end
    elseif not (chatCommand == "") and obj.type == "CHAT" and obj.text == chatCommand then  -- CHAT
      makeAction(obj, objID)
    elseif not (rednetMessage == "") and obj.type == "REDNET" and obj.text == rednetMessage then -- REDNET
      makeAction(obj, objID)
    end
  end
end

function makeAction(obj, objID)
  if obj.action_type == "TEXT" then
    drawText(199, objID, 0, 0)
  elseif obj.action_type == "ACTIVATION" then
    if net.isPresentRemote(obj.action_unit) and obj.action_method ~= "NONE" and type(obj.action_arguments) == "table" then
      if countArray(obj.action_arguments) >= 1 then
        local noErr,res = pcall( net.callRemote, obj.action_unit, obj.action_method, unpack(obj.action_arguments))
        if not noErr then
          if errorText == nil then
            errorText = {"ERROR!!! ALARM'N'ACTION CALLING WITH ARGUMENTS! Object: " .. objID, "ORIGINAL ERROR MESSAGE: ".. res}
          end
        end
      else
        local noErr,res = pcall( net.callRemote, obj.action_unit, obj.action_method, unpack(obj.action_arguments))
        if not noErr then
          if errorText == nil then
            errorText = {"ERROR!!! ALARM'N'ACTION CALLING WITHOUT ARGUMENTS! Object: " .. objID, "ORIGINAL ERROR MESSAGE: ".. res}
          end
        end
      end
    end
  elseif obj.action_type == "REDNET" then
    rednet.broadcast(obj.action_text)
  end
end




-- ON SCREEN OBJECT DRAWING

-- type text x y c
function drawText(siteID, objID, relX, relY)
  local obj = site[siteID][objID]
  if obj.type == "text" then
    local var = b.addText(obj.x+relY,obj.y+relY,obj.text,colorHex[obj.text_color])
    setZDimension(var)
  elseif obj.action_type == "TEXT" then
    local var = b.addText(obj.action_x+relX,obj.action_y+relY,obj.action_text,colorHex[obj.action_text_color])
    setZDimension(var)
  end
end

-- type x y w h cOne tOne cTwo tTwo
function drawBox(siteID, objID, relX, relY)
  local obj = site[siteID][objID]
  local cOne = colorHex[obj.inner_color]
  local cTwo = colorHex[obj.border_color]
  local var1 = b.addBox(obj.x+relX,obj.y+relY,obj.w,2,cTwo,obj.border_transparency)
  setZDimension(var1)
  local var2 = b.addBox(obj.x+relX,obj.y+2+relY,2,obj.h-4,cTwo,obj.border_transparency)
  setZDimension(var2)
  local var3 = b.addBox(obj.x+relX,obj.y+relY+obj.h-2,obj.w,2,cTwo,obj.border_transparency)
  setZDimension(var3)
  local var4 = b.addBox(obj.x+relX+obj.w-2,obj.y+relY+2,2,obj.h-4,cTwo,obj.border_transparency)
  setZDimension(var4)
  local var5 = b.addBox(obj.x+relX+2,obj.y+relY+2,obj.w-4,obj.h-4,cOne,obj.inner_transparency)
  setZDimension(var5)
end

-- type x y text unit method maxNumber c cMax
function drawNumber(siteID, objID, relX, relY)
  local obj = site[siteID][objID]
  local c = colorHex[obj.text_standardColor]
  local cMax = colorHex[obj.text_maxNumberColor]
  local number = table.remove(screen[siteID][objID]["values"], 1)
  if (type(number) == "table") then
      number = "ERROR table"
  end
  local lengthText = ((#tostring(obj.text)) + 2)*6
  local lengthNumber = (#(tostring(number)))*6
  local maxLength = (#(tostring(obj.maxNumber)))*6
  if type(number) == "string" or (type(number) == "number" and number == maxNumber) then
    local var1 = b.addText(obj.x+relX,obj.y+relY,obj.text .. ":",c)
    setZDimension(var1)
    local var2 = b.addText(obj.x+relX+lengthText,obj.y+relY,tostring(number),cMax)
    setZDimension(var2)
    local var3 = b.addText(obj.x+relX+lengthText+(#(tostring(number)))*6,obj.y+relY, " / " .. obj.maxNumber, c)
    setZDimension(var3)
  else
    local var1 =  b.addText(obj.x+relX,obj.y+relY, obj.text .. ":", c )
    setZDimension(var1)
    local var2 =  b.addText(obj.x+relX+lengthText+(maxLength-lengthNumber),obj.y+relY, tostring(number) .. " / " .. obj.maxNumber,c)
    setZDimension(var2)
  end
end

-- type x y w h cBorder tBorder cBack tBack cOne tOne cTwo tTwo unit method maxNumber
function drawBar(siteID, objID, relX, relY)
  local obj = site[siteID][objID]
  local cBorder = colorHex[obj.color3]
  local cBack = colorHex[obj.color4]
  local cOne = colorHex[obj.color]
  local cTwo = colorHex[obj.color2]
  local tBorder = obj.transparency3
  local tBack = obj.transparency4
  local tOne = obj.transparency
  local tTwo = obj.transparency2
  local var1 = b.addBox(obj.x+relX+2,obj.y+relY+2,obj.w-4,obj.h-4,cBack,tBack)
  setZDimension(var1)
  local var2 = b.addBox(obj.x+relX,obj.y+relY,obj.w,2,cBorder,tBorder)
  setZDimension(var2)
  local var3 = b.addBox(obj.x+relX,obj.y+relY+obj.h-2,obj.w,2,cBorder,tBorder)
  setZDimension(var3)
  local var4 = b.addBox(obj.x+relX,obj.y+relY+2,2,obj.h-4,cBorder,tBorder)
  setZDimension(var4)
  local var5 = b.addBox(obj.x+relX+obj.w-2,obj.y+relY+2,2,obj.h-4,cBorder,tBorder)
  setZDimension(var5)
  local number = table.remove(screen[siteID][objID]["values"], 1)
  if type(number) == "number" then
    local box = b.addGradientBox(obj.x+relX+2,obj.y+relY+2,math.ceil((number/obj.maxNumber)*(obj.w-4)),obj.h-4,cOne,tOne,cTwo,tTwo,2)
    z = z + 1
    setZDimension(box)
  end
end

-- type x y w h minNumber maxNumber c t fadeout unit method var
function drawGraph(siteID, objID, rX, rY)
  local obj = site[siteID][objID]
  local var = screen[siteID][objID]["values"]
  table.remove(screen[siteID][objID]["values"], math.ceil(obj.w+2/2))
  local t = obj.transparency
  local decrease = obj.transparency/20
  local c = colorHex[obj.color]
  for relX=2,obj.w,2 do
    if obj.fadeout and relX >= obj.w-20 and t > 0.05 then
      t = t - decrease
    end
    if obj.type == "graphPillar" then
      if type(var[relX/2]) == "number" then
        if var[relX/2] > obj.minNumber then
          local box = b.addBox(obj.x+rX+relX-2,obj.y+rY+(obj.h-1-(math.ceil((var[relX/2]/(obj.maxNumber))*obj.h))),2,(math.ceil((var[relX/2]/(obj.maxNumber))*obj.h)),c,t)
          setZDimension(box)
        else
          local box = b.addBox(obj.x+rX+relX-2,obj.y+rY+obj.h-2,2,1,c,t)
          setZDimension(box)
        end
      else
        local box = b.addBox(obj.x+rX+relX-2,obj.y+rY+obj.h-2,2,1,c,t)
        setZDimension(box)
      end
    else
      if type(var[relX/2]) == "number" then
        if var[relX/2] > obj.minNumber then
          local box = b.addBox(obj.x+rX+relX-2,obj.y+rY+(obj.h-1-((math.ceil((var[relX/2]/(obj.maxNumber))*obj.h)))),2,2,c,t)
          setZDimension(box)
          local box = b.addBox(obj.x+rX+relX-2,obj.y+rY+obj.h-1,2,1,c,t)
          setZDimension(box)
        else
          local box = b.addBox(obj.x+rX+relX-2,obj.y+rY+obj.h-1,2,1,c,t)
          setZDimension(box)
        end
      else
        local box = b.addBox(obj.x+rX+relX-2,obj.y+rY+obj.h-1,2,1,c,t)
        setZDimension(box)
      end
    end
  end
end

function drawTank(siteID, objID, relX, relY)
  local obj = site[siteID][objID]
  local cBorder = colorHex[obj.cBorder]
  local cBack = colorHex[obj.cBack]
  local tBorder = obj.tBorder
  local tBack = obj.tBack
  local var1 = b.addBox(obj.x+relX+2,obj.y+relY+2,obj.w-4,obj.h-4,cBack,tBack)
  setZDimension(var1)
  local var2 = b.addBox(obj.x+relX,obj.y+relY,obj.w,2,cBorder,tBorder)
  setZDimension(var2)
  local var3 = b.addBox(obj.x+relX,obj.y+relY+obj.h-2,obj.w,2,cBorder,tBorder)
  setZDimension(var3)
  local var4 = b.addBox(obj.x+relX,obj.y+relY+2,2,obj.h-4,cBorder,tBorder)
  setZDimension(var4)
  local var5 = b.addBox(obj.x+relX+obj.w-2,obj.y+relY+2,2,obj.h-4,cBorder,tBorder)
  setZDimension(var5)
  local number = table.remove(screen[siteID][objID]["values"], 1)
  if type(number) == "number" then
    local relH = obj.h-math.ceil((number/obj.maxNumber)*obj.h)
    local box = b.addLiquid(obj.x+relX+2,obj.y+relH+relY+2,obj.w-4,obj.h-relH-4, obj.liquid)
    z = z + 1
    setZDimension(box)
  end
end

function setZDimension(obj)
  local wtf = ( obj.setZ and obj.setZ(z) ) or ( obj.setZIndex and obj.setZIndex(z) )
  z = z + 1
end



-- ON SCREEN DRAWING MAIN METHODS




function drawSite(doUpdate)
  doUpdate = doUpdate or true
  if (doUpdate) then
    update()
  end
  if selected == 0 then return end
  z = 1
  b.clear()
  for i=1,4 do
    innerDraw(0,0,selected,i)
  end
  checkAlarm()
  b.sync()
  save()
end



function update() -- DONE 1
  for siteID, selectedSite in pairs(site) do -- SITE
    for objID, obj in pairs(selectedSite) do  -- OBJECT
      if siteID == selected or ( obj.type == "graphPillar" or obj.type == "graphPoint" or obj.type == "ALARM" or obj.type == "CHAT" or obj.type == "REDNET") then -- JUST NEEDED INFORMATION.
        if obj.unit ~= nil and obj.method ~= nil then
          callMethod(siteID, objID, obj, "unit", "method", "arguments","values")
        end
        if obj.action_type ~= "ACTIVATION" and obj.action_unit ~= nil and obj.action_method ~= nil then
          callMethod(siteID, objID, obj, "action_unit", "action_method", "action_arguments", "action_values")
        end
      end
    end
  end
end

function callMethod(siteID, objID, obj, unit_pos, method_pos, arguments_pos, values_pos) -- DONE 1
  if screen[siteID][objID] == nil then
      screen[siteID][objID] = {}
      screen[siteID][objID]["values"] = {}
      screen[siteID][objID]["action_values"] = {}
      screen[siteID][objID]["objects"] = {}
    end
  if net.isPresentRemote(obj[unit_pos]) and obj[method_pos] ~= "NONE" then
    if type(obj[arguments_pos]) ~= "table" then 
      table.insert(screen[siteID][objID]["values"], 1, "ERROR")
      table.insert(screen[siteID][objID]["action_values"], 1, "ERROR")
      return
    end
    if countArray(obj[arguments_pos]) == 0 then
      local noError, value = pcall( net.callRemote, obj[unit_pos], obj[method_pos] )
      if noError and (type(value) == "number" or type(value) == "string" or type(value) == "boolean") then
        table.insert(screen[siteID][objID][values_pos], 1, value)
      elseif errorText == nil then
        table.insert(screen[siteID][objID][values_pos], 1, "ERROR")
        if siteID <= 99 then siteID = "Site: " .. siteID
        elseif siteID <= 198 then siteID = "Frame: " .. siteID-99
        else siteID = "ALARM'N'ACTION"
        end
        if type(value) == "table" then
          value = "(Original Error code was a table. Unable to print.)"
        end
        errorText = {"ERROR! ".. siteID .. "  Object: " .. objID .. "  Unit: " .. obj[unit_pos] .. "  Method: " .. obj[method_pos] .. "  No arguments!", "Original Error Code: " .. tostring(value)}
      end
    else
      local noError, value = pcall( net.callRemote, obj[unit_pos], obj[method_pos], unpack(obj[arguments_pos]) )
      if noError and (type(value) == "number" or type(value) == "string" or type(value) == "boolean") then
        table.insert(screen[siteID][objID][values_pos], 1, value)
      elseif errorText == nil then
        table.insert(screen[siteID][objID][values_pos], 1, "ERROR")
        if siteID <= 99 then siteID = "Site: " .. siteID
        elseif siteID <= 198 then siteID = "Frame: " .. siteID-99
        else siteID = "ALARM'N'ACTION"
        end
        if type(value) == "table" then
          value = "(Original Error code was a table. Unable to print.)"
        end
        errorText = {"ERROR! ".. siteID .. "  Object: " .. objID .. "  Unit: " .. obj[unit_pos] .. "  Method: " .. obj[method_pos] .. "  Arguments: " .. countArray(obj[arguments_pos]), "Original Error Code: " .. tostring(value)}
      end
    end
  elseif countArray(screen[siteID][objID]["values"]) == 0 or countArray(screen[siteID][objID]["action_values"]) then
    table.insert(screen[siteID][objID]["values"], 1, "ERROR")
    table.insert(screen[siteID][objID]["action_values"], 1, "ERROR")
  end
end


function innerDraw(relX, relY, s, layer) -- DONE 1
  if layer == 4 then -- ERROR
    if type(errorText) == "table" then
      local length = #errorText[1]
      if #errorText[1] < #errorText[2] then
        length = #errorText[2]
      end
      local box1 = b.addBox(0,0,math.ceil(length*5.3),28,colorHex[1],1)
      setZDimension(box1)
      local box2 = b.addBox(0,28,1+math.ceil(length*5.3),2,colorHex[14],1)
      setZDimension(box2)
      local box3 = b.addBox(math.ceil(length*5.3),0,2,29,colorHex[14],1)
      setZDimension(box3)
      local var1 = b.addText(5,5,errorText[1],colorHex[14])
      setZDimension(var1)
      local var2 = b.addText(5,15, errorText[2],colorHex[14])
      setZDimension(var2)
      errorText = nil
    end
  end

  for objID, obj in pairs(site[s]) do
    if obj.type == "frame" then
      innerDraw(obj.x, obj.y, obj.frame, layer)
    elseif layer == 1 then -- BOX
      if obj.type == "box" then
        drawBox(s, objID, relX, relY)
      end
    elseif layer == 2 then -- NUMBER, BAR, GRAPH
      if obj.type == "number" then
        drawNumber(s, objID, relX, relY)
      elseif obj.type == "bar" then
        drawBar(s, objID, relX, relY)
      elseif obj.type == "graphPillar" or obj.type == "graphPoint" then
        drawGraph(s, objID, relX, relY)
      elseif obj.type == "tank" then
        drawTank(s, objID, relX, relY)
      end      
    elseif layer == 3 then -- TEXT
      if obj.type == "text" or obj.action_type == "TEXT" then
        drawText(s, objID, relX, relY)
      end
    end
  end
end



-- MENU FUNCTIONS

function betterRead(x,y,numberOnly,pos,clickX) -- DONE 1
  local previousMode = mode
  local selectedSite = selected
  mode = "betterRead"
  term.setTextColor(colors.lightGray)
  term.setCursorBlink(true)
  local s
  if clickX < x then
    s = ""
  else
    s = tostring(site[selected][selectedObj][pos])
  end


  while true do
    term.setCursorPos(x,y)
    term.write( string.rep(' ', w - x + 1) )
    term.setCursorPos(x,y)
    if s:len()+x < w then
      term.write(s)
    else
      term.write(s:sub( s:len() - (w-x-2)))
    end
    local e = { os.pullEvent() }
    if e[1] == "mouse_click" then
      mode = "back"
    elseif e[1] == "char" then
      s = s .. e[2]
    elseif e[1] == "key" then
      if e[2] == keys.enter then
        mode = "back"
      elseif e[2] == keys.backspace then
        s = s:sub( 1, s:len() - 1 )
      end
    else
      checkEvent(e, false)
    end
    if mode == "back" then
      mode = previousMode
      break
    elseif not (mode == "betterRead") then
      break
    end
  end

  term.setTextColor(colors.white)
  if numberOnly then
    s = tonumber(s)
    if s then
      site[selectedSite][selectedObj][pos] = s
    end
  else
    site[selectedSite][selectedObj][pos] = s
  end
  term.setCursorBlink(false)
end


function drawColor(color,y) -- DONE 1
  drawArrows(y)
  term.setBackgroundColor(colorName[color])
  centered("   ",y)
  term.setBackgroundColor(colors.black)
end

function drawTransparent(transparency,y) -- DONE 1
  drawArrows(y)
  centered(transparency, y)
end


function changeColor(x, color) -- DONE 1
  if x < 25 then
    site[selected][selectedObj][color] = site[selected][selectedObj][color] - 1
  else
    site[selected][selectedObj][color] = site[selected][selectedObj][color] + 1
  end
  if site[selected][selectedObj][color] <= 0 then
    site[selected][selectedObj][color] = 15
  elseif site[selected][selectedObj][color] >= 16 then
    site[selected][selectedObj][color] = 1
  end
end

function changeTransparence(x, transparency) -- DONE 1
  if x < 25 then
    site[selected][selectedObj][transparency] = site[selected][selectedObj][transparency] - 0.1
  else
    site[selected][selectedObj][transparency] = site[selected][selectedObj][transparency] + 0.1
  end
  if site[selected][selectedObj][transparency] < 0 then
    site[selected][selectedObj][transparency] = 1
  elseif site[selected][selectedObj][transparency] > 1 then
    site[selected][selectedObj][transparency] = 0
  end
end



-- QUATERNARY MENUS

function menuArguments(unit_pos, method_pos, arguments_pos, amount, args, advancedMethodsSupport) -- DONE 1
  local previousMode = mode
  mode = "arguments"

  local param = site[selected][selectedObj][arguments_pos]
  if advancedMethodsSupport then
    for i=1, amount do
      if args[i]["type"] == "NUMBER" and param[i] == nil then
        param[i] = i
      elseif param[i] == nil then
        param[i] = "Argument" .. i
      end
    end
  end


  while true do
    -- DRAW
    amount = countArray(param)
    clear()
    centered("ENTER ARGUMENTS FOR METHOD " .. site[selected][selectedObj][method_pos], 1)
    fill("-", 2)
    centered("APPLY", 15)
    for i=1, amount do
      write("ARG ".. i ..": " .. param[i],11,3+i)
    end
    if not advancedMethodsSupport and amount <= 10 then
      centered("ADD NEW MANUAL ARGUMENT", 16)
    end
    if not advancedMethodsSupport and amount > 0 then
      centered("DELETE LAST ARGUMENT", 17)
    end

    -- EVENT
    local event = { os.pullEvent() }
    if checkEvent(event) then
      x,y = event[3], event[4]
      if y >= 4 and y <= amount+3 then
        site[selected][selectedObj][arguments_pos] = param[y-3]
        if advancedMethodsSupport then
          if args[y-3]["type"] == "NUMBER" then
            betterRead(18,y,true,arguments_pos,x)
          else
            betterRead(18,y,false,arguments_pos,x)
          end
        else -- not advancedMethodsSupport
          betterRead(18,y,false,arguments_pos,x)
          local tempVar = tonumber(site[selected][selectedObj][arguments_pos])
          if tempVar then
            site[selected][selectedObj][arguments_pos] = tempVar
          end
        end
        param[y-3] = site[selected][selectedObj][arguments_pos]
      elseif not advancedMethodsSupport and amount <= 10 and y == 16 then
        param[amount+1] = "Manual Argument" .. amount+1
      elseif not advancedMethodsSupport and amount > 0 and y == 17 then
        param[amount] = nil
      elseif y == 15 then
        mode = "back"
      end
    end

    -- BACK TO MENU
    if mode == "back" then
      mode = previousMode
      break
    elseif not (mode == "arguments") then
      break
    end
  end
  site[selected][selectedObj][arguments_pos] = param
  save()
end






-- TERTIARY MENUS

function menuUnit(unit_pos, method_pos, arguments_pos) -- DONE 1
  clear()
  local list = net.getNamesRemote()
  if countArray(list) == 0 then
    centered("NOTHING ATTACHED TO THE NETWORK!",9)
    while true do 
      local event = {os.pullEvent()}
      if event[1] == "timer" and event[2] == delay then
        drawSite()
        delay = os.startTimer(updateInterval)
      else
        return "NONE"
      end
    end
  end

  local selectedUnit = 1
  for k,v in pairs(list) do
    selectedUnit = selectedUnit + 1
    if advancedMethodsSupport and v["name"] == site[selected][selectedObj][unit_pos] then
      break
    elseif not advancedMethodsSupport and v == site[selected][selectedObj][unit_pos] then
      break
    end
  end
  selectedUnit = selectedUnit - 1

  selectedUnit = 1
  local previousMode = mode
  mode = "unit"
  while true do
    -- DRAW
    clear()
    centered("SELECT A UNIT",1)
    fill("-",2)
    centered("SELECT",14)
    fill(" ",9)
    drawArrows(9)
    centered(list[selectedUnit],9)

    -- EVENT
    local event = { os.pullEvent() }
    if checkEvent(event) then
      x,y = event[3], event[4]
      if y >= 8 and y <= 10 then
        if x <= 25 then
          selectedUnit = selectedUnit - 1
        else
          selectedUnit = selectedUnit + 1
        end
        if selectedUnit == 0 then
          selectedUnit = countArray(list)
        elseif selectedUnit > countArray(list) then
          selectedUnit = 1
        end
      elseif y == 14 then
        mode = "back"
      end
    end

    -- BACK TO MENU
    if mode == "back" then
      mode = previousMode
      break
    elseif not (mode == "unit") then
      break
    end
  end
  site[selected][selectedObj][unit_pos] = list[selectedUnit]
  site[selected][selectedObj][method_pos] = "NONE"
  site[selected][selectedObj][arguments_pos] = {}
end




function menuMethod(method_pos, unit_pos, arguments_pos, allReturnTypes) -- DONE 1
  local unit = site[selected][selectedObj][unit_pos]
  allReturnTypes = allReturnTypes or false
  clear()
  if not net.isPresentRemote(unit) then
    return "NONE"
  end

  -- methods available?
  local basicMethods = net.getMethodsRemote(unit)
  if basicMethods ~= nil and countArray(basicMethods) == 0 then
    centered("NO METHOD FOUND!",9)
    while true do
      local event = {os.pullEvent()}
      if event[1] == "timer" and event[2] == delay then
        drawSite()
        delay = os.startTimer(updateInterval)
      else
        break
      end 
    end
    return "NONE"
  end
 
-- advanced or normal support? (fixed by blunty666)
  local advancedMethodsSupport = false
  local unitType = "NONE"
  local advancedMethodsList = {}
  for k,v in pairs(basicMethods) do
    if v == "getAdvancedMethodsData" then
       advancedMethodsSupport = true
       unitType = net.getTypeRemote(unit)
       advancedMethodsList = net.callRemote(unit, "getAdvancedMethodsData")
       break
    end
  end

  --[[ get advanced methods if possible
  local list = {}
  if advancedMethodsSupport then
    for k,v in pairs(advancedMethodsList) do
      if allReturnTypes or ( v["returnType"] ~= nil and v["returnType"] ) or ( v["returnTypes"][1] == "number" ) then
        table.insert(list, 1, v)
      end
    end
  else
    list = net.getMethodsRemote(unit)
  end]]


-- get advanced methods if possible (fixed by blunty666)
  local list = {}
  if advancedMethodsSupport then
    for k,v in pairs(advancedMethodsList) do
      if allReturnTypes or ( v["returnType"] ~= nil and v["returnType"] ) or ( v["returnTypes"][1] == "number" ) then
        v.name = k
        table.insert(list, 1, v)
      end
    end
  else
    list = net.getMethodsRemote(unit)
  end




  -- still methods with number as return value available?
  if advancedMethodsSupport and (list == nil or countArray(list) == 0) then
    centered("NO METHOD FOUND!",9)
    while true do
      local event = {os.pullEvent()}
      if event[1] == "timer" and event[2] == delay then
        drawSite()
        delay = os.startTimer(updateInterval)
      else
        break
      end 
    end
    return "NONE"
  end




  -- selection of the method
  local method = 1
  for k,v in pairs(list) do
    method = method + 1
    if advancedMethodsSupport and v["name"] == site[selected][selectedObj][method_pos] then
      break
    elseif not advancedMethodsSupport and v == site[selected][selectedObj][method_pos] then
      break
    end
  end
  method = method - 1

  local previousMode = mode
  local previousSelected = selected
  mode = "method"
  while true do
    -- DRAW
    clear()
    centered("SELECT A METHOD FROM " .. unit ,1)
    fill("-",2)
    centered("SELECT",16)
    local methodName = "UNKNOWN"
    local methodDescription = "UNKNOWN! No Advanced Methods Support available!"
    local methodReturnType = "UNKNOWN"
    local methodArgumentamount = 1337
    local methodArgs = {}
    if advancedMethodsSupport then
      local counter = 1
      for k, v in pairs(list) do
        if counter == method then
          methodName = v["name"]
          methodDescription = v["description"]
          methodReturnType = v["returnType"] or v["returnTypes"][1] or "nil"
          methodArgumentamount = countArray(v["args"]) or 0
          methodArgs = v["args"] or {}
          break
        end
        counter = counter + 1
      end
    else
      methodDescription = "UNKNOWN! No Advanced Methods Support available!"
      methodReturnType = "UNKNOWN"
      methodArgumentamount = 0
      methodName = list[method]
    end

  
    fill(" ",6)
    drawArrows(6)
    centered(methodName, 6)
    term.setCursorPos(1,8)
    print(" Description: " .. methodDescription)
    print(" Returns: " .. methodReturnType)
    print(" Arguments: " .. methodArgumentamount)
    if advancedMethodsSupport and methodArgumentamount >= 1 then
      centered("SET OR CHANGE ARGUMENTS", 15)
    elseif not advancedMethodsSupport then
      centered("SET OR CHANGE ARGUMENTS (OWN RISK)", 15)
    end
    -- EVENT
    local event = { os.pullEvent() }
    if checkEvent(event) then
      site[selected][selectedObj][method_pos] = methodName
      x,y = event[3], event[4]
      if y >= 5 and y <= 8 then
        site[selected][selectedObj][arguments_pos] = {}
        screen[selected][selectedObj][arguments_pos] = {}
        if x <= 25 then
          method = method - 1
        else
          method = method + 1
        end
        if method == 0 then
          method = countArray(list)
        elseif method > countArray(list) then
          method = 1
        end
      elseif advancedMethodsSupport and methodArgumentamount >= 1 and y == 15 then
        menuArguments(unit_pos, method_pos, arguments_pos, methodArgumentamount, methodArgs, true)
      elseif not advancedMethodsSupport and y == 15 then
        menuArguments(unit_pos, method_pos, arguments_pos, countArray(site[selected][selectedObj][arguments_pos]), methodArgs, false)
      elseif y == 16 then
        mode = "back"
      end
    end

    -- BACK TO MENU
    if mode == "back" then
      mode = previousMode
      break
    elseif not (mode == "method") then
      break
    end
  end
end


-- SECONDARY MENUS

function menuSiteOrFrame(setMode) -- DONE 1
  mode = setMode
  local selectedFrame = 100
  if mode == "site" then
    selected = 1
  else
    selected = 100
  end
  selectedObj = 1
  while true do
    -- DRAW
    clear()
    drawArrows(1)
    if mode == "site" then
     centered("SITE " .. selected ,1)
    elseif mode == "frame" then
     centered("FRAME " .. selected-99 ,1)
    end
    fill("-",2)
    local obj = site[selected][selectedObj]
    if type(obj) == "table" then
      centered(selectedObj.. " - " .. obj.type , 3)
    else
     centered(selectedObj , 3)
    end
    drawArrows(3)
    fill("-",4)
    write("BACK",48,1)
    if type(obj) == "table" then    -- object exists
      write("DELETE",1,1)
      if obj.type == "text" then    -- TEXT
        write("TEXT: " .. obj.text,10,7)
        write("X:    " .. obj.x,10,9)
        write("Y:    " .. obj.y,10,11)
        drawColor(obj.text_color,13)
      elseif obj.type == "box" then   -- BOX
        write("X:      " .. obj.x,10,5)
        write("Y:      " .. obj.y,10,6)
        write("WIDTH:  " .. obj.w,10,7)
        write("HEIGHT: " .. obj.h,10,8)
        drawColor(obj.border_color,9)
        drawTransparent(obj.border_transparency,10)
        drawColor(obj.inner_color,11)
        drawTransparent(obj.inner_transparency,12)
      elseif obj.type == "number" then  -- NUMBER
        write("X:      "..obj.x,10,5)
        write("Y:      "..obj.y,10,6)
        write("TEXT:   "..obj.text,10,7)
        write("UNIT:   "..obj.unit,10,8)
        write("METHOD: "..obj.method,10,9)
        write("MAX:    "..obj.maxNumber,10,10)
        drawColor(obj.text_standardColor,11)
        drawColor(obj.text_maxNumberColor,12)
      elseif obj.type == "bar" then   -- BAR
        write("X:      "..obj.x,10,5)
        write("Y:      "..obj.y,10,6)
        write("WIDTH:  "..obj.w,10,7)
        write("HEIGHT: "..obj.h,10,8)
        write("UNIT:   "..obj.unit,10,9)
        write("METHOD: "..obj.method,29,9)
        write("MAX:    "..obj.maxNumber,10,10)
        drawColor(obj.color,11)
        drawTransparent(obj.transparency,12)
        drawColor(obj.color2,13)
        drawTransparent(obj.transparency2,14)
        drawColor(obj.color3,15)
        drawTransparent(obj.transparency3,16)
        drawColor(obj.color4,17)
        drawTransparent(obj.transparency4,18)
        write("ADD AUTO TEXT", 10, 19)
      elseif obj.type == "graphPillar" or obj.type == "graphPoint" then     
        -- GRAPHS
        write("X:       "..obj.x,10,5)
        write("Y:       "..obj.y,10,6)
        write("WIDTH:   "..obj.w,10,7)
        write("HEIGHT:  "..obj.h,10,8)
        write("UNIT:    "..obj.unit,10,9)
        write("METHOD:  "..obj.method,10,10)
        write("MIN:     "..obj.minNumber,10,11)
        write("MAX:     "..obj.maxNumber,10,12)
        drawColor(obj.color,13)
        drawTransparent(obj.transparency,14)
        write("FADEOUT: "..tostring(obj.fadeout),10,15)
        write("TYPE:   " ..obj.type,10,16)
        write("ADD AUTO BOX", 10, 17)
      elseif obj.type == "frame" then -- FRAME
        centered(obj.frame-99,5)
        drawArrows(5)
        fill("-",6)
        write("X: "..obj.x,10,8)
        write("Y: "..obj.y,10,10)
      elseif obj.type == "tank" then -- TANK
        write("X:      "..obj.x,10,5)
        write("Y:      "..obj.y,10,6)
        write("WIDTH:  "..obj.w,10,7)
        write("HEIGHT: "..obj.h,10,8)
        write("UNIT:   "..obj.unit,10,9)
        write("METHOD: "..obj.method,10,10)
        write("MAX:    "..obj.maxNumber,10,11)
        write("LIQUID: "..obj.liquid,10,12)
        drawColor(obj.cBorder,13)
        drawTransparent(obj.tBorder,14)
        drawColor(obj.cBack,15)
        drawTransparent(obj.tBack,16)
      end
    else  --create new object
      write("TEXT",20,6)
      write("BOX",20,7)
      write("NUMBER",20,8)
      write("BAR",20,9)
      write("GRAPH (PILLAR)",20,10)
      write("GRAPH (POINT)",20,11)
      write("TANK",20,12)
      if mode == "site" then
        write("FRAME",20,13)
      end
    end

    -- EVENT
    local event = { os.pullEvent() }
    if checkEvent(event) then
      x, y = event[3], event[4]
      if y == 1 and x >= w-4 then
        mode = "mainmenu"
      elseif type(site[selected][selectedObj]) == "table" and y == 1 and x <=6 then
        site[selected][selectedObj] = nil
        if selectedObj >= 2 then
          selectedObj = selectedObj - 1
        end
      elseif y == 1 then
        selectedObj = 1
        if x < 25 then
          selected = selected - 1
        else
          selected = selected + 1
        end
        if mode == "site" then
          if selected <= 0 then
            selected = 99
          elseif selected >= 100 then
            selected = 1
          end
        elseif mode == "frame" then
          if selected <= 99 then
            selected = 198
          elseif selected >= 199 then
            selected = 100
          end
        end
      elseif y >= 2 and y <= 4 then
        if x < 25 then
          selectedObj = selectedObj - 1
        else
          selectedObj = selectedObj + 1
        end
        if selectedObj == 0 then
          selectedObj = 1
        end
      elseif type(site[selected][selectedObj]) == "table" then
        if site[selected][selectedObj].type == "text" then
          if y == 7 then
            betterRead(16,y,false,"text",x)
          elseif y == 9 then
            betterRead(16,y,true,"x",x)
          elseif y == 11 then
            betterRead(16,y,true,"y",x)
          elseif y == 13 then
            changeColor(x,"text_color")
          end
        elseif site[selected][selectedObj].type == "box" then
          if y == 5 then
            betterRead(18,y,true,"x",x)
          elseif y == 6 then
            betterRead(18,y,true,"y",x)
          elseif y == 7 then
            betterRead(18,y,true,"w",x)
          elseif y == 8 then
            betterRead(18,y,true,"h",x)
          elseif y == 9 then
            changeColor(x,"border_color")
          elseif y == 10 then
            changeTransparence(x,"border_transparency")
          elseif y == 11 then
            changeColor(x,"inner_color")
          elseif y == 12 then
            changeTransparence(x,"inner_transparency")
          end
        elseif site[selected][selectedObj].type == "number" then
          if y == 5 then
           betterRead(18,y,true,"x",x)
          elseif y == 6 then
            betterRead(18,y,true,"y",x)
          elseif y == 7 then
            betterRead(18,y,false,"text",x)
          elseif y == 8 then
            menuUnit("unit","method","arguments")
          elseif y == 9 then
            if x < 18 then
              menuMethod("method","unit","arguments",true)
            else
              menuMethod("method","unit","arguments",false)
            end
          elseif y == 10 then
            betterRead(18,y,true,"maxNumber",x)
          elseif y == 11 then
            changeColor(x,"text_standardColor")
          elseif y == 12 then
            changeColor(x,"text_maxNumberColor")
          end
        elseif site[selected][selectedObj].type == "bar" then
          if y == 5 then
            betterRead(18,y,true,"x",x)
          elseif y == 6 then
            betterRead(18,y,true,"y",x)
          elseif y == 7 then
            betterRead(18,y,true,"w",x)
          elseif y == 8 then
            betterRead(18,y,true,"h",x)
          elseif y == 9 then
            if x < 28 then
              menuUnit("unit","method","arguments")
            else
              if x < 18 then
              menuMethod("method","unit","arguments",true)
            else
              menuMethod("method","unit","arguments",false)
            end
          end
          elseif y == 10 then
            betterRead(18,y,true,"maxNumber",x)
          elseif y == 11 then
            changeColor(x,"color")
          elseif y == 12 then
            changeTransparence(x,"transparency")
          elseif y == 13 then
            changeColor(x,"color2")
          elseif y == 14 then
            changeTransparence(x,"transparency2")
          elseif y == 15 then
            changeColor(x,"color3")
          elseif y == 16 then
            changeTransparence(x,"transparency3")
          elseif y == 17 then
            changeColor(x,"color4")
          elseif y == 18 then
            changeTransparence(x,"transparency4")
          elseif y == 19 then
            local bar = site[selected][selectedObj]
            local textProperties = {type="text",text="YOUR TEXT",x=bar.x-59,y=bar.y+4,text_color=bar.color}
            table.insert(site[selected], selectedObj+1, textProperties )
            selectedObj = selectedObj+1

            betterRead(25,y,false,"text",50)
            site[selected][selectedObj].x = bar.x - 10 - math.floor(5.5 * #site[selected][selectedObj].text) 
          end
        elseif site[selected][selectedObj].type == "graphPillar" or site[selected][selectedObj].type == "graphPoint" then
          if y == 5 then
            betterRead(19,y,true,"x",x)
          elseif y == 6 then
            betterRead(19,y,true,"y",x)
          elseif y == 7 then
            betterRead(19,y,true,"w",x)
          elseif y == 8 then
            betterRead(19,y,true,"h",x)
          elseif y == 9 then
            menuUnit("unit","method","arguments")
          elseif y == 10 then
            if x < 18 then
              menuMethod("method","unit","arguments",true)
            else
              menuMethod("method","unit","arguments",false)
            end
          elseif y == 11 then
            betterRead(19,y,true,"minNumber",x)
          elseif y == 12 then
            betterRead(19,y,true,"maxNumber",x)
          elseif y == 13 then
            changeColor(x,"color")
          elseif y == 14 then
            changeTransparence(x,"transparency")
          elseif y == 15 then
            site[selected][selectedObj].fadeout = not site[selected][selectedObj].fadeout
          elseif y == 16 then
            if site[selected][selectedObj].type == "graphPoint" then
              site[selected][selectedObj].type = "graphPillar"
            elseif site[selected][selectedObj].type == "graphPillar" then
              site[selected][selectedObj].type = "graphPoint"
            end
          elseif y == 17 then
            local g = site[selected][selectedObj]
            local boxProperties = {type="box", x=g.x-4, y=g.y-6, w=g.w+8, h=g.h+10, inner_color=1, inner_transparency=0.4, border_color=g.color, border_transparency=0.9}
            table.insert(site[selected], selectedObj+1, boxProperties )
            selectedObj = selectedObj+1
          end
        elseif site[selected][selectedObj].type == "tank" then
          if y == 5 then
            betterRead(18,y,true,"x",x)
          elseif y == 6 then
            betterRead(18,y,true,"y",x)
          elseif y == 7 then
            betterRead(18,y,true,"w",x)
          elseif y == 8 then
            betterRead(18,y,true,"h",x)
          elseif y == 9 then
            menuUnit("unit","method","arguments")
          elseif y == 10 then
            if x < 18 then
              menuMethod("method","unit","arguments",true)
            else
              menuMethod("method","unit","arguments",false)
            end
          elseif y == 11 then
            betterRead(18,y,true,"maxNumber",x)
          elseif y == 12 then
            betterRead(18,y,false,"liquid",x)
          elseif y == 13 then
            changeColor(x,"cBorder")
          elseif y == 14 then
            changeTransparence(x,"tBorder")
          elseif y == 15 then
            changeColor(x,"cBack")
          elseif y == 16 then
            changeTransparence(x,"tBack")
          end
        elseif site[selected][selectedObj].type == "frame" then
          if y == 5 then
            if x < 25 then
              site[selected][selectedObj].frame = site[selected][selectedObj].frame - 1
            else
              site[selected][selectedObj].frame = site[selected][selectedObj].frame + 1
            end
            if site[selected][selectedObj].frame == 99 then
              site[selected][selectedObj].frame = 198
            elseif site[selected][selectedObj].frame == 199 then
              site[selected][selectedObj].frame = 100
            end
          elseif y == 8 then
            betterRead(13,y,true,"x",x)
          elseif y == 10 then
            betterRead(13,y,true,"y",x)
          end
        end
      else        -- CREATE
        if y == 6 then
          site[selected][selectedObj] = {type="text",text="UNOBTANIUM",x=1,y=1,text_color=1}
        elseif y == 7 then
          site[selected][selectedObj] = {type="box",x=1,y=1,w=10,h=10,inner_color=1,inner_transparency=0.4,border_color=15,border_transparency=1}
        elseif y == 8 then
          site[selected][selectedObj] = {type="number",x=1,y=1,text="UNOBTANIUM",unit="NONE",method="NONE",maxNumber=1337,text_standardColor=1,text_maxNumberColor=14,arguments={}}
        elseif y == 9 then
          site[selected][selectedObj] = {type="bar",x=1,y=1,w=40,h=15,color=1,transparency=1,color2=2,transparency2=1,color3=3,transparency3=1,color4=4,transparency4=1,unit="NONE",method="NONE",maxNumber=1337, arguments={}}
        elseif y == 10 then
          site[selected][selectedObj] = {type="graphPillar",x=1,y=1,w=100,h=40,minNumber=0,maxNumber=1337,color=1,transparency=1,fadeout=false,unit="NONE",method="NONE",arguments={}}
        elseif y == 11 then
          site[selected][selectedObj] = {type="graphPoint",x=1,y=1,w=100,h=40,minNumber=0,maxNumber=1337,color=1,transparency=1,fadeout=false,unit="NONE",method="NONE",arguments={}}
        elseif y == 12 then
          site[selected][selectedObj] = {type="tank",x=1,y=1,w=15,h=40,cBorder=1,tBorder=1,cBack=2,tBack=1,unit="NONE",method="NONE",maxNumber=1337, liquid="water", arguments={}}
        elseif y == 13 and mode == "site" then
          site[selected][selectedObj] = {type="frame",frame=100,x=0,y=0}
        end
      end
    end

    -- BACK TO MENU
    if not (mode == "site" or mode == "frame") then
      break
    end
  end
end



function menuAlarm() -- DONE 1
  mode = "alarm"
  local previousSelected = selected
  selected = 199
  selectedObj = 1
  while true do
    local obj = site[199][selectedObj]
    -- DRAW
    clear()
    b.clear()
    centered("ALARM'N'ACTION", 1)
    fill("-",2)
    if type(site[199][selectedObj]) == "table" then
      centered(selectedObj .. " - " .. obj.type, 3)
    else
      centered(selectedObj, 3)
    end
    drawArrows(3)
    fill("-",4)
    write("BACK", 48, 1)
    local relY = 0
    if type(obj) == "table" and obj.type == "ALARM" then
      write("DELETE", 1, 1)
      write("UNIT:      "..obj.unit, 10, 6)
      write("METHOD:    "..obj.method, 10, 7)
      write("NUMBER:    "..obj.operator .. " " .. obj.number, 10, 8)
      write("ACTION:    "..obj.action_type, 10, 9)
      relY = 2
    elseif type(obj) == "table" and obj.type == "CHAT" then
      write("DELETE", 1, 1)
      write("COMMAND: $$"..obj.text, 10, 6)
      write("ACTION:    "..obj.action_type, 10, 7)
    elseif type(obj) == "table" and obj.type == "REDNET" then
      write("DELETE", 1, 1)
      write("MESSAGE:   "..obj.text, 10, 6)
      write("ACTION:    "..obj.action_type, 10, 7)
    else
      write("ALARM", 10, 9)
      write("CHAT", 10, 10)
      write("REDNET", 10 , 11)
    end

    if type(obj) == "table" then
      if obj.action_type == "TEXT" then
        write("| X:       "..obj.action_x, 10, 8+relY)
        write("| Y:       "..obj.action_y, 10, 9+relY)
        write("| TEXT:    "..obj.action_text, 10, 10+relY)
        drawColor(obj.action_text_color, 11+relY)
      elseif obj.action_type == "ACTIVATION" then
        write("| UNIT:    "..obj.action_unit, 10, 8+relY)
        write("| METHOD:  "..obj.action_method, 10, 9+relY)
      elseif obj.action_type == "REDNET" then
        write("| MESSAGE: "..obj.action_text, 10, 8+relY)
      end
    end

    -- EVENT
    local event = { os.pullEvent() }
    if checkEvent(event) then
      x, y = event[3], event[4]
      if y == 1 and x <= 6 and type(site[199][selectedObj]) == "table" then
        site[199][selectedObj] = nil
        if selectedObj >= 2 then
          selectedObj = selectedObj - 1
        end
      elseif y == 1 and x >= 48 then
        save()
        selected = previousSelected
        selectedObj = 1
        mode = "mainmenu"
      elseif y == 3 or y == 4 then
        if x > 25 then
          selectedObj = selectedObj + 1
        elseif selectedObj > 1 then
          selectedObj = selectedObj - 1
        end
      elseif type(site[199][selectedObj]) == "table" and site[199][selectedObj].type == "ALARM" then -- ALARM
        if y == 6 then
          menuUnit("unit","method","arguments")
        elseif y == 7 then
          if x < 20 then
            menuMethod("method", "unit","arguments",true)
          else
            menuMethod("method", "unit","arguments",false)
          end
        elseif y == 8 and x >=19 and x <= 21 then
          if site[199][selectedObj].operator == "=" then
            site[199][selectedObj].operator = ">"
          elseif site[199][selectedObj].operator == ">" then
            site[199][selectedObj].operator = "<"
          elseif site[199][selectedObj].operator == "<" then
            site[199][selectedObj].operator = "="
          end
        elseif y == 8 then
          betterRead(23,y,true,"number",x)
        elseif y == 9 then
          setAction()
        elseif site[199][selectedObj].action_type == "TEXT" then -- ALARM: TEXT
          if y == 10 then
            betterRead(21,y,true,"action_x",x)
          elseif y == 11 then
            betterRead(21,y,true,"action_y",x)
          elseif y == 12 then
            betterRead(21,y,false,"action_text",x)
          elseif y == 13 then
            changeColor(x,"action_text_color")
          end
        elseif site[199][selectedObj].action_type == "ACTIVATION" then -- ALARM: ACTIVATION
          if y == 10 then
            menuUnit("action_unit","action_method","action_arguments")
          elseif y == 11 then
            if x < 20 then
              menuMethod("action_method", "action_unit", "action_arguments", true)
            else
              menuMethod("action_method", "action_unit", "action_arguments",false)
            end
          end
        elseif site[199][selectedObj].action_type == "REDNET" then -- ALARM: REDNET
          if y == 10 then
            betterRead(21,y,false,"action_text",x)
          end
        end

      elseif type(site[199][selectedObj]) == "table" and ( site[199][selectedObj].type == "CHAT" or site[199][selectedObj].type == "REDNET") then -- CHAT AND REDNET
        if y == 6 then
          betterRead(21,y,false,"text",x)
        elseif y == 7 then
          setAction()
        elseif site[199][selectedObj].action_type == "TEXT" then -- ALARM: TEXT
          if y == 8 then
            betterRead(21,y,true,"action_x",x)
          elseif y == 9 then
            betterRead(21,y,true,"action_y",x)
          elseif y == 10 then
            betterRead(21,y,false,"action_text",x)
          elseif y == 11 then
            changeColor(x,"action_text_color")
          end
        elseif site[199][selectedObj].action_type == "ACTIVATION" then -- ALARM: ACTIVATION
          if y == 8 then
            menuUnit("action_unit","action_method","action_arguments")
          elseif y == 9 then
            if x < 20 then
              menuMethod("action_method", "action_unit","action_arguments",true)
            else
              menuMethod("action_method", "action_unit", "action_arguments",false)
            end
          end
        elseif site[199][selectedObj].action_type == "REDNET" then -- ALARM: REDNET
          if y == 8 then
            betterRead(21,y,false,"action_text",x)
          end
        end

      else -- CREATE NEW
        site[199][selectedObj] = {}
        if y == 9 then
          site[199][selectedObj] = {type="ALARM" ,unit="NONE", method="NONE", arguments={}, operator="=", number=42, action_type="NONE"}
        elseif y == 10 then
          site[199][selectedObj] = {type="CHAT",text="NONE",action_type="NONE"}
        elseif y == 11 then
          site[199][selectedObj] = {type="REDNET",text="NONE",action_type="NONE"}
        end
      end
    end

    -- BACK TO MENU
    if not (mode == "alarm") then
      selected = previousSelected
      break
    end
  end
end

function setAction() -- DONE 1
  if site[199][selectedObj].action_type == "NONE" then
    site[199][selectedObj].action_type = "TEXT"
    site[199][selectedObj].action_x = 1
    site[199][selectedObj].action_y = 1
    site[199][selectedObj].action_text = "UNOBTANIUM"
    site[199][selectedObj].action_text_color = 1
  elseif site[199][selectedObj].action_type == "TEXT" then
    site[199][selectedObj].action_type = "ACTIVATION"
    site[199][selectedObj].action_unit = "NONE"
    site[199][selectedObj].action_method = "NONE"
    site[199][selectedObj].action_arguments = {}
    site[199][selectedObj].action_text_color = nil
    site[199][selectedObj].action_text = nil
    site[199][selectedObj].action_x = nil
    site[199][selectedObj].action_y = nil
  elseif site[199][selectedObj].action_type == "ACTIVATION" then
    site[199][selectedObj].action_type = "REDNET"
    site[199][selectedObj].action_text = "UNOBTANIUM"
    site[199][selectedObj].action_unit = nil
    site[199][selectedObj].action_method = nil
    site[199][selectedObj].action_arguments = nil
  elseif site[199][selectedObj].action_type == "REDNET" then
    site[199][selectedObj].action_type = "NONE"
    site[199][selectedObj].action_text = nil
  end
end



-- PRIMARY MENUS

function mainMenu() -- DONE 1
  mode = "mainmenu"
  while true do
    for _, side in pairs(rednetSide) do
      if peripheral.getType(side) == "modem" then
        rednet.open(side)
      end
    end
    
    -- DRAW
    clear()
    centered("CLIENT FOR OPENPERIPERAL'S GLASSES", 1)
    fill("-", 2)
    write("by UNOBTANIUM", w-13, h)
    write("Site",20,6)
    write("Frame",20,8)
    write("Alarm'n'Action",20,10)
    write("Quit",20,13)
    write("<   " .. updateInterval .. "   >",2, h)

    -- EVENT
    local event = { os.pullEvent() }
    if checkEvent(event) then
      x, y = event[3], event[4]
      if y == 6 then
        menuSiteOrFrame("site")
      elseif y == 8 then
        menuSiteOrFrame("frame")
      elseif y == 10 then
        menuAlarm()
      elseif y == 13 then
        save()
        b.clear()
        mode = "quit"
      elseif y == h then
        if x <= 3 then
          updateInterval = updateInterval / 2
        elseif x >=10 and x <= 12 and updateInterval < 16 then
          updateInterval = updateInterval * 2
        end
        if updateInterval < 0.5 then
          updateInterval = 0.5
        end
      end
    end

    if mode == "quit" then
      break
    end
  end
end



-- EVENT HANDLING

function checkEvent(event, justUpdate, charAndKeyEvent)
  charAndKeyEvent = charAndKeyEvent or false
  justUpdate = justUpdate or false
  if event[1] == "timer" and event[2] == delay then
    if justUpdate then
      update()
    else
      drawSite()
    end
    delay = os.startTimer(updateInterval)

  elseif event[1] == "mouse_click" or (charAndKeyEvent and ( event[1] == "char" or event[1] == "key" )) then
    return true

  elseif event[1] == "glasses_chat_command" then
    mode = "mainmenu"
    checkAlarm(event[5])
    if event[5] == "clear" or event[5] == "" then
      b.clear()
      b.sync()
      selected = 0
    elseif event[5] == "sync" then
      b.clear()
      local var = b.addText(10, 10, "Sync!", colorHex[14])
      setZDimension(var)
      b.sync()
      sleep(updateInterval)
      delay = os.startTimer(0.2)

    else
      for i=1,99 do
        if event[5] == "site"..i then
          selected = i
          drawSite(false)
          break
        end
      end
    end

  elseif event[1] == "rednet_message" then
    checkAlarm("", tostring(event[3]))
  end

  return false
end


-- START

load()
mainMenu()
clear()