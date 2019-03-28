-- 29.08.2014 by UNOBTANIUM
-- first concept 12.01.2014


os.loadAPI("ocs/apis/sensor")


-- CONSTANTS
local PUFFER = 12
local CLUSTER_MAX_X = 2
local CLUSTER_MAX_Y = 10
local DEFAULD_MAXCAPAZITY = 4096 -- barrel capazity
local SYSTEM_NAME = "storage"
local CHANNEL = 1993
local SAVEFILE = "unobtaniumsorter"
local time = 3

-- GLOBAL VARIABLES
local storage = {	["Pos"]={
						[24]={
							[1]={
								["MaxCapazity"]=4096,["Priority"]=0,["CurrentCapazity"]=64,["Name"]="Stone Bricks:0",
							},
						},
						[27]={
							[4]={
								["MaxCapazity"]=4096,["Priority"]=0,["CurrentCapazity"]=64,["Name"]="Stone:0",
							},
						},
					},
					["Action"]={
					},
					["Name"]={
						["Stone Bricks:0"]={
							["Data"]={
								["DamageValue"]=0,["Priority"]=0,["RawName"]="net.stone bricks",["Name"]="Stone Bricks",
							},
							["Stock"]={
								[1]={
									["CallsIn"]=1,["CallsOut"]=0,["y"]=1,["x"]=24,
								},
							},
						},
						["Stone:0"]={
							["Data"]={
								["DamageValue"]=0,["Priority"]=0,["RawName"]="net.stone",["Name"]="Stone",
							},
							["Stock"]={
								[1]={
									["CallsIn"]=1,["CallsOut"]=0,["y"]=4,["x"]=27,
								},
							},
						},
					},
				}

--local storage = { ["Name"] = {}, ["Pos"] = {}, ["Action"]= {}}
--[[local storage = { 	["Name"]={ 
						["Stone:0"]={ 
							["Data"]={ ["RawName"]="net.stone", ["DamageValue"]=0, ["MaxStack"]=64, ["Name"]="Stone", ["Priority"]=0 },
							["Stock"]={ [1]={ ["x"]=1, ["y"]=27, ["CallsIn"]=0, ["CallsOut"]=0} }
						}, 
						["Dirt:0"]={ 
							["Data"]={ ["RawName"]="net.dirt", ["DamageValue"]=0, ["MaxStack"]=64, ["Name"]="Dirt", ["Priority"]=0 }, 
							["Stock"]={ [1]={ ["x"]=1, ["y"]=30, ["CallsIn"]=0, ["CallsOut"]=0} } 
						} 
					},

					["Pos"]={ 
						[1]={ 
							[27]={ ["Name"]="Stone:0", ["CurrentCapazity"]=0, ["MaxCapazity"]=4096, ["Priority"]=0 }
						}, 
						[4]={ 
							[30]={ ["Name"]="Dirt:0", ["CurrentCapazity"]=0, ["MaxCapazity"]=4096, ["Priority"]=0 }
						}
					},

					["Action"]={} 
				}]]
	-- NAME: Name:DamageValue = ( Data = ( RawName, DamageValue, MaxStack, Name (custom) , Priority (custom) ), Stock = ( x, y, CallsIn, CallsOut) )
	-- POS:	[x][y] = (Priority, MaxCapazity, Name:Value, CurrentCapazity )
local itemlist = {}
local callsIn = 0
local callsOut = 0

-- REDNET
local modem = peripheral.wrap("right")
modem.open(CHANNEL)
local radar = sensor.wrap("top")

-- METHODS
function suckItemsIntoInventory() -- sucks items into the turtle inventory as a puffer to dump out stacks of the same kind of item all at once
	print("sucking Items in")
	turtle.select(1)
	for slot=1,PUFFER do
		if not turtle.suck() then return end
		if turtle.getItemCount(PUFFER) > 0 then return end
	end
end

function obtainItemList() -- creates an array list 'itemlist' of the itemstacks in the inventory and sorts them
	print("obtaining item list")
	local inv = radar.getTargetDetails("0,-1,0")
	local item = inv.Slots
	itemlist = {}
	for slot, data in pairs(item) do
		if not ( data.Name == "empty" ) then 
			local tempData = data
			local name = data.Name .. ":" .. data.DamageValue
			if itemlist[name] == null then
				tempData.Slots = {}
				itemlist[name] = tempData
			end
			table.insert(itemlist[name].Slots, slot)
		end
	end
end

function reserveSpots() -- checks if item exists in databank otherwise it creates a spot for it
	print("reserving spots")
	for name, data in pairs(itemlist) do
		if storage.Name[name] == null then -- create first storage
			local newData = {["Name"]=data.Name, ["RawName"]=data.RawName, ["DamageValue"]=data.DamageValue, ["Priority"]=0}
			storage.Name[name] = { ["Data"]=newData, ["Stock"]={} }
			findFreeStorage(name, newData)
		else -- check if storage is full
			local leftCapazity = 0

			for pos, data_stock in pairs(storage.Name[name].Stock) do
				local data_storage = storage.Pos[data_stock.x][data_stock.y]
				leftCapazity = data_storage.MaxCapazity - data_storage.CurrentCapazity
			end
			local requiredCapazity = 0
			for pos, slot in pairs(data.Slots) do
				requiredCapazity = requiredCapazity + turtle.getItemCount(slot)
			end
			if leftCapazity < requiredCapazity then
				findFreeStorage(name, newData)
			end
		end
	end
end

function sortItemsIntoStorage()
	print("sort items into storage")
	for name, data in pairs(itemlist) do
		local running = true
		while running do
			local pos = findInputStock(name)
			local x = storage.Name[name].Stock[pos].x
			local y = storage.Name[name].Stock[pos].y
			local cluster_x = math.floor((x-1)/3)
			local cluster_y = math.floor((y-1)/3)
			local storage_x = ((x-1)%3)+1
			local storage_y = ((y-1)%3)+1
			print(cluster_x .. " " .. cluster_y .. " " .. storage_x .. " " .. storage_y)
			local storageData = storage.Pos[x][y]
			print(textutils.serialize(data))
			storage.Name[name].Stock[pos].CallsIn = storage.Name[name].Stock[pos].CallsIn + 1
			modem.transmit(CHANNEL, CHANNEL, textutils.serialize({SYSTEM_NAME, "sorter", "0:0", "transport", {cluster_x, cluster_y, storage_x, storage_y}}))
			for pos, slot in pairs(data.Slots) do
				local itemCount = turtle.getItemCount(slot)
				if itemCount > 0 then
					turtle.select(slot)
					local itemsFree = storageData.MaxCapazity-storageData.CurrentCapazity
					if itemCount > (itemsFree) then
						turtle.dropDown(itemsFree)
						storageData.CurrentCapazity = storageData.CurrentCapazity + itemsFree
						running = true
						break
					else
						turtle.dropDown()
						storageData.CurrentCapazity = storageData.CurrentCapazity + itemCount
						running = false
					end
				end
			end
			waitForInput(time)
		end
	end
end










function findInputStock(name)
	local priority = -100
	local pos = 0
	local counter = 1
	for num, stock in pairs(storage.Name[name].Stock) do
		local data = storage.Pos[stock.x][stock.y]
		if data.Priority >= priority and data.MaxCapazity > data.CurrentCapazity then
			priority = data.Priority
			pos = counter
		end
		counter = counter + 1
	end
	return pos
end


function waitForInput(seconds) -- waits and receives messages
	modem.transmit(1993, 1993, textutils.serialize({SYSTEM_NAME, "sorter", "all", "readytoreceive"}))
	local delay = os.startTimer(seconds)
	while true do
		local e = { os.pullEvent()}
		if e[1] == "modem_message" and checkMessageProtocol(e) then
			local message = textutils.unserialize(e[5])
			if message[4] == "changeitemname" then 
				changeItemName(message[5])
			elseif message[4] == "switchstorage" then
				switchStorage(message[5].x1, message[5].y1, message[5].x2, message[5].y2)
			end -- TODO changePriority, getItem, auto-defrag, setStorage, pause/resume
		elseif e[1] == "timer" and e[2] == delay then
			return
		end
	end
end

function checkMessageProtocol(e) -- checks if the message is meant for this storage system
	local message = textutils.unserialize(e[5])
	if e[3] == CHANNEL and type(message) == "table" and message[1] == SYSTEM_NAME and ( message[3] == "all" or message[3] == "sorter" ) then
		return true
	else
		return false
	end
end

function changeItemName(data) -- changes the custom name for the item id (Name = name:damagevalue, newName=newName)
	if not (storage.Name[data.Name] == null) then
		storage.Name[data.Name].Name = data.NewName
	end
end




function findFreeStorage(name, data) -- finds a free spot for the material (checks priority status)
	for X=0, CLUSTER_MAX_X-1 do
		for Y=0, CLUSTER_MAX_Y-1 do
			for x=1,3 do
				for y=1,3 do
					if storage.Pos[X*3+x] == null or storage.Pos[X*3+x][Y*3+y] == null then -- not used yet
						if storage.Pos[X*3+x] == null then
							storage.Pos[X*3+x] = {}
						end
						local dataPos = { ["Name"] = name, ["Priority"] = data.Priority, ["MaxCapazity"] = DEFAULD_MAXCAPAZITY, ["CurrentCapazity"] = 0 }
						table.insert(storage.Pos[X*3+x], Y*3+y, dataPos)
						local dataStock = {["x"]=X*3+x, ["y"]=Y*3+y, ["CallsIn"]=0, ["CallsOut"]=0}
						table.insert(storage.Name[name].Stock, dataStock)
						return
					elseif storage.Pos[X*3+x][Y*3+y].Name == null and storage.Pos[X*3+x][Y*3+y].Priority <= data.Priority then -- allready used or set with Priority
						storage.Pos[X*3+x][Y*3+y].Name = name
						storage.Pos[X*3+x][Y*3+y].CurrentCapazity = 0
						local dataStock = {["x"]=X*3+x, ["y"]=Y*3+y, ["CallsIn"]=0, ["CallsOut"]=0}
						table.insert(storage.Name[name].Stock, dataStock)
						return
					end
				end
			end
		end
	end
	--TODO everything full throw error message
end

function freeStorage(x,y) -- deletes all data of the spot
	if storage.Pos[x][y] == null then return end
	local name = storage.Pos[x][y].Name
	storage.Pos[x][y].Name = null
	storage.Pos[x][y].CurrentCapazity = 0
	for pos, storageData in pairs(storage.Name[name].Stock) do
		if storageData.x == x and storageData.y == y then
			table.remove(storage.Name[name].Stock, pos)
			break
		end
	end
end

function switchStorage(x1, y1, x2, y2) -- adds an action to the queue for switching two storage spots
	if storage.Pos[x1][y1] == null then
		if storage.Pos[x2][y2] == null then
			return
		elseif storage.Pos[x2][y2].Name == null then
			return
		else
			local name2 = storage.Pos[x2][y2].Name
			table.insert(storage.Action, {["Command"]="switch", ["First"]={{["x"]=x2, ["y"]=y2, ["Name"]=name2} , ["Second"]={["x"]=x1, ["y"]=y1, ["Name"]=null} }})
		end
	elseif storage.Pos[x1][y1].Name == null then
		if storage.Pos[x2][y2] == null then
			return
		elseif storage.Pos[x2][y2].Name == null then
			return
		else
			local name2 = storage.Pos[x2][y2].Name
			table.insert(storage.Action, {["Command"]="switch", ["First"]={{["x"]=x2, ["y"]=y2, ["Name"]=name2} , ["Second"]={["x"]=x1, ["y"]=y1, ["Name"]=null} }})
		end
	else
		if storage.Pos[x2][y2] == null then
			local name1 = storage.Pos[x1][y1].Name
			table.insert(storage.Action, {["Command"]="switch", ["First"]={{["x"]=x1, ["y"]=y1, ["Name"]=name1} , ["Second"]={["x"]=x2, ["y"]=y2, ["Name"]=null} }})
		elseif storage.Pos[x2][y2].Name == null then
			local name1 = storage.Pos[x1][y1].Name
			table.insert(storage.Action, {["Command"]="switch", ["First"]={{["x"]=x1, ["y"]=y1, ["Name"]=name1} , ["Second"]={["x"]=x2, ["y"]=y2, ["Name"]=null} }})
		else
			local name1 = storage.Pos[x1][y1].Name
			local name2 = storage.Pos[x2][y2].Name

			--[[local pos1 = getSpot(name1, x1, y1)
			local pos2 = getSpot(name2, x2, y2)
			storage.Name[name1].Stock[pos1].x = x2
			storage.Name[name1].Stock[pos1].y = y2
			storage.Name[name2].Stock[pos2].x = x1
			storage.Name[name2].Stock[pos2].y = y1
			--TODO storage.Pos.Name
			]]
			table.insert(storage.Action, {["Command"]="switch", ["First"]={{["x"]=x1, ["y"]=y1, ["Name"]=name1} , ["Second"]={["x"]=x2, ["y"]=y2, ["Name"]=name2} }})
		end
		
	end
end

function getSpot(name, x, y)
	for p, spot in pairs(storage.Name[name].Stock) do
		if spot.x == x and spot.y == y then
			return p
		end
	end
end





function startSortingRoutine()
	term.clear()
	term.setCursorPos(1, 1)
	print(textutils.serialize(storage.Name))
	turtle.select(1)
	if turtle.getItemCount(1) == 0 and not turtle.suck() then return false end
	suckItemsIntoInventory()
	obtainItemList()
	reserveSpots()
	sortItemsIntoStorage()
	save()
	return true
end





-- SAVE AND LOAD

function save()
	local file = fs.open(SAVEFILE, "w")
		file.writeLine(SYSTEM_NAME)
		file.writeLine(CHANNEL)
		file.writeLine(CLUSTER_MAX_X)
		file.writeLine(CLUSTER_MAX_Y)
		file.writeLine(DEFAULD_MAXCAPAZITY)
		file.writeLine(PUFFER)
		file.writeLine(callsIn)
		file.writeLine(callsOut)
		file.writeLine(textutils.serialize(storage))
	file.close()
end

function load()
	if fs.exists("rom/" .. os.getComputerID() .. "/"..SAVEFILE) then
		local file = fs.open(SAVEFILE, "r")
				local file = fs.open(SAVEFILE, "w")
				SYSTEM_NAME = file.readLine()
				CHANNEL = tonumber(file.readLine())
				CLUSTER_MAX_X = tonumber(file.readLine())
				CLUSTER_MAX_Y = tonumber(file.readLine())
				DEFAULD_MAXCAPAZITY = tonumber(file.readLine())
				PUFFER = tonumber(file.readLine())
				callsIn = tonumber(file.readLine())
				callsOut = tonumber(file.readLine())
				storage = textutils.unserialize(file.readLine())
		file.close()
	end
end


-- RUN
load()
while true do
	if not startSortingRoutine() then
		print("no items found! waiting...")
		waitForInput(5) --15
	end
end