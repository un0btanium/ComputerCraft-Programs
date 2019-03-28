-- 01.09.2014 by UNOBTANIUM
-- first concept 12.01.2014


-- CONSTANTS
local SYSTEM_NAME = "storage"
local CHANNEL = 1993
local CLUSTER_X = 0
local CLUSTER_Y = 0
local SKYDIRECTION = 3 -- 1 NORTH, 2 EAST, 3 SOUTH, 4 WEST
local SAVEFILE = "storage"
local info = {}
local haveToSend = false

-- VARIABLES
local state_distribution = 1
local state = {1,1,1}

local newState_distribution = "through"
local newState = {"through","through","through"}

-- STATES
local STATE_DISTRIBUTION_NORTH = {"through","back","sort"}
local STATE_DISTRIBUTION_EAST = {"sort","back","through"}
local STATE_DISTRIBUTION_SOUTH = {"back","through","sort"}
local STATE_DISTRIBUTION_WEST = {"sort","through","back"}
local STATE_DISTRIBUTION = {STATE_DISTRIBUTION_NORTH, STATE_DISTRIBUTION_EAST, STATE_DISTRIBUTION_SOUTH, STATE_DISTRIBUTION_WEST}

local STATE_STORAGE_NORTH = {"second","third","first","back","through"}
local STATE_STORAGE_EAST = {"second","back","through","first","third"}
local STATE_STORAGE_SOUTH = {"second","first","third","through","back"}
local STATE_STORAGE_WEST = {"second","through","back","third","first"}
local STATE_STORAGE = { STATE_STORAGE_NORTH, STATE_STORAGE_EAST, STATE_STORAGE_SOUTH, STATE_STORAGE_WEST}


-- REDNET
local modem = peripheral.wrap("back")
modem.open(CHANNEL)


-- METHODS


function waitForInput() -- waits for rednet/modem input
	save()
	local e = { os.pullEvent() }
	if e[1] == "modem_message" and checkMessageProtocol(e) then
		local message = textutils.unserialize(e[5])
		local pos = message[5]
		if message[4] == "transport" and checkPosition(pos[1], pos[2]) then
			print("Computer ID: " .. os.getComputerID())
			print("Cluster pos: " .. CLUSTER_X .. ":" .. CLUSTER_Y)
			print("States before: " .. STATE_STORAGE[SKYDIRECTION][state[1]] .. " " ..STATE_STORAGE[SKYDIRECTION][state[2]] .. " " ..STATE_STORAGE[SKYDIRECTION][state[3]]  .. " " .. STATE_DISTRIBUTION[SKYDIRECTION][state_distribution])
			haveToSend = true
			getNewStates(pos[1], pos[2], pos[3], pos[4])
			changeStates()
			sendMessage(pos[1], pos[2], pos[3], pos[4])
			print("States after:" .. STATE_STORAGE[SKYDIRECTION][state[1]] .. " " ..STATE_STORAGE[SKYDIRECTION][state[2]] .. " " ..STATE_STORAGE[SKYDIRECTION][state[3]] .. " " .. STATE_DISTRIBUTION[SKYDIRECTION][state_distribution])
		end -- TODO reset defauld states
	end
end

function checkMessageProtocol(e) -- checks if the message is meant for this storage system
	local message = textutils.unserialize(e[5])
	if e[3] == CHANNEL and type(message) == "table" and message[1] == SYSTEM_NAME and ( message[3] == "all" or message[3] == "distributionnodes" or message[3] == (CLUSTER_X .. ":" .. CLUSTER_Y) ) then
		return true
	else
		return false
	end
end

function checkPosition(x,y) -- checks if message is ment for this cluster
	print(type(x))
	if ( (CLUSTER_X == 0 and CLUSTER_Y <= y) or (CLUSTER_Y == y and CLUSTER_X <= x) ) then
		return true
	else
		return false
	end
end

function getNewStates(cluster_x, cluster_y, spot_x, spot_y) -- sets the new state of the iron pipes by its position
	print("position of item " .. cluster_x .. " " ..  cluster_y .. " " .. spot_x .. " " .. spot_y)
	if CLUSTER_X == 0 then
		if CLUSTER_Y == cluster_y then
			newState_distribution = "sort"
		else
			newState_distribution = "through"
		end
	end

	newState = {"through", "through","through"}
	local word = {"first", "second", "third"}
	if CLUSTER_Y == cluster_y then
		newState[spot_x] = word[spot_y]
	end
	print("change states to " .. newState[1] .. " " .. newState[2] .. " " .. newState[3] .. " " .. newState_distribution )
	info = {cluster_x, cluster_y, spot_x, spot_y}
	save()
end

function changeStates()
	local side = {"right", "bottom", "left"} -- redstone directions relative to the computer
	for i=1,4 do
		if CLUSTER_X == 0 and not ( STATE_DISTRIBUTION[SKYDIRECTION][state_distribution] == newState_distribution ) then
			print(STATE_DISTRIBUTION[SKYDIRECTION][state_distribution] .. " == " .. newState_distribution)
			state_distribution = state_distribution + 1
			redstone.setOutput("top", not redstone.getOutput("top"))
			if state_distribution > 3 then state_distribution = 1 end
		end

		for i=1,3 do
			if not ( STATE_STORAGE[SKYDIRECTION][state[i]] == newState[i] ) then
				state[i] = state[i] + 1
				if state[i] > 5 then state[i] = 1 end
				redstone.setOutput(side[i], not redstone.getOutput(side[i]))
			end
		end
		save()
		os.sleep(0.05) -- sums up to 0.2
	end

	os.sleep(0.5) --??? TODO fine tuning
end

function sendMessage(cluster_x, cluster_y, spot_x, spot_y) -- sends message to the next cluster if it isnt the destination cluster
	if not (CLUSTER_X == cluster_x and CLUSTER_Y == cluster_y) then
		local nextX = CLUSTER_X
		local nextY = CLUSTER_Y
		if CLUSTER_Y < cluster_y then
			nextY = cluster_y + 1
		elseif CLUSTER_Y == cluster_y and CLUSTER_X < cluster_x then
			nextX = cluster_x + 1
		end
		print(textutils.serialize({SYSTEM_NAME, (CLUSTER_X..":"..CLUSTER_Y), (nextX..":"..nextY), "transport", {cluster_x, cluster_y, spot_x, spot_y}}))
		modem.transmit(CHANNEL, CHANNEL, textutils.serialize({SYSTEM_NAME, (CLUSTER_X..":"..CLUSTER_Y), (nextX..":"..nextY), "transport", {cluster_x, cluster_y, spot_x, spot_y}}))
	end
	haveToSend = false
end


-- SAVE AND LOAD

function save()
	local file = fs.open(SAVEFILE, "w")
		file.writeLine(SYSTEM_NAME)
		file.writeLine(CHANNEL)
		file.writeLine(CLUSTER_X)
		file.writeLine(CLUSTER_Y)
		file.writeLine(SKYDIRECTION)
		file.writeLine(state_distribution)
		file.writeLine(newState_distribution)
		file.writeLine(textutils.serialize(state))
		file.writeLine(textutils.serialize(newState))
		file.writeLine(haveToSend)
		file.writeLine(textutils.serialize(info))
	file.close()
end

function load()
	if os.getComputerLabel() == nil then
		os.setComputerLabel("clusterPC")
	end
	if fs.exists("rom/" .. os.getComputerID() .. "/"..SAVEFILE) then
		local file = fs.open(SAVEFILE, "r")
			SYSTEM_NAME = file.readLine()
			CHANNEL = tonumber(file.readLine())
			CLUSTER_X = tonumber(file.readLine())
			CLUSTER_Y = tonumber(file.readLine())
			SKYDIRECTION = tonumber(file.readLine())
			state_distribution = tonumber(file.readLine())
			newState_distribution = file.readLine()
			state = textutils.unserialize(file.readLine())
			newState = textutils.unserialize(file.readLine())
			if file.readLine() == "true" then haveToSend = true end
			info = textutils.unserialize(file.readLine())
		file.close()
		if haveToSend then
			sendMessage(info[1], info[2], info[3], info[4])
		end
	else
		term.clear()
		term.setCursorPos(1,1)
		term.write("Enter the X-position of the cluster: ")
		CLUSTER_X = tonumber(read())
		term.write("Enter the Y-position of the cluster: ")
		CLUSTER_Y = tonumber(read())
		term.setCursorPos(1,4)
		term.write("1 - North, 2 - East, 3 - South, 4 - West")
		term.setCursorPos(1, 3)
		term.write("Enter the sky direction: ")
		SKYDIRECTION = tonumber(read())
		term.clear()
		term.setCursorPos(1,1)
		for pos, side in pairs({"top"}) do
			redstone.setOutput(side, not redstone.getOutput(side))
		end
		save()
	end
end

-- RUN

load()
print("Computer ID: " .. os.getComputerID())
print("Cluster pos: " .. CLUSTER_X .. ":" .. CLUSTER_Y)
print("States before: " .. STATE_STORAGE[SKYDIRECTION][state[1]] .. " " ..STATE_STORAGE[SKYDIRECTION][state[2]] .. " " ..STATE_STORAGE[SKYDIRECTION][state[3]]  .. " " .. STATE_DISTRIBUTION[SKYDIRECTION][state_distribution])
while true do
	waitForInput()
end