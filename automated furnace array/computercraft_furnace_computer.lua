local system = "my furnace";
local furnaceCount = 8; -- 8, 16, 24, 32 ect on each side
local useFuel = true;
local useOutput = true;

rednet.open("left");
local network = peripheral.wrap("back");
local timerID = os.startTimer(0.1);
local errorMessage = "";
local idleTimer = 0;

local furnaceGlobalName = "iron_furnace_";
-- Vanilla Furnace: local methods = {["getFinishedItems"]={["method"]="getStackInSlot", ["parameter"]={3}}, ["getQueuedItems"]={["method"]="getStackInSlot", ["parameter"]={1}}, ["getFuelItems"]={["method"]="getStackInSlot", ["parameter"]={2}}};
-- Iron Furnace: 
local methods = {["getFinishedItems"]={["method"]="getStackInSlot", ["parameter"]={2}}, ["getQueuedItems"]={["method"]="getStackInSlot", ["parameter"]={1}}, ["getFuelItems"]={["method"]="getStackInSlot", ["parameter"]={3}}};

local furnace = {};
local furnaceGlobalNumber = -1
for x = 1, furnaceCount, 1 do
	table.insert(furnace, {["x"]=x+1, ["y"]=1, ["state"]="empty", ["fuel"]=16, ["finishedItems"]=0, ["queuedItems"]=0, ["furnaceName"]="NONE"});
	table.insert(furnace, {["x"]=x+1, ["y"]=-1, ["state"]="empty", ["fuel"]=16, ["finishedItems"]=0, ["queuedItems"]=0, ["furnaceName"]="NONE"});
end


local menu = {
		{{"Which type of furnace is in use?"}, {"Standard Furnace","Iron Furnace","Custom"}, {{10,1},{8,1.25}}},
		{{"How should smelted items be handled?"},{"let turtle gather finished items"}, {"take care about items yourself"}, {true, false}},
		{{"How should fuel be handled?"}, {"let the turtle refuel the furnaces"}, {"take care about refueling yourself"}, {true, false}},
		{{"Which fuel type is in use?"}, {"Coal", "Blaze Rod", "Custom"}, {80, 120}},
		{{"Enter the name of this furnace station:"}}
}


function setSettings()
	local selected = 1;
	for i = 1, 5, 1 do
		
	end
end

function loadSettings()

end






local task = {};


-- Save and Load

function save()
	local file = fs.open("furnacestation","w");
	    file.writeLine(string.gsub(textutils.serialize(furnace),"\n%S-",""));
	    file.writeLine(string.gsub(textutils.serialize(methods),"\n%S-",""));
	    file.writeLine(system);
	    file.writeLine(furnaceCount);
	    file.writeLine(tostring(useFuel));
	    file.writeLine(tostring(useOutput));
  	file.close();
end

function load()
	if not fs.exists("furnacestation") then return end
	local file = fs.open("furnacestation","r")
	    furnace = textutils.unserialize(file.readLine())
	    methods = textutils.unserialize(file.readLine())
	    system = file.readLine()
	    furnaceCount = tonumber(file.readLine())
	    if (tostring(file.readLine()) == "true") then
	    	useFuel = true
	   	else
	   		useFuel = false
	   	end
	   	if (tostring(file.readLine()) == "true") then
	    	useOutput = true
	    else
	    	useOutput = false
	    end
	file.close();
end



-- Task


function sendTask(message)
	for i = 1, furnaceCount*2, 1 do
		if (useOutput and furnace[i].state ~= "disconnected" and furnace[i].state == "finished") then
			sendMessage({["taskname"]="retrieveitems", ["furnacenumber"]=i, ["x"]=furnace[i].x, ["y"]=furnace[i].y, ["itemcount"]=furnace[i].finishedItems});
			return;
		elseif (useFuel and furnace[i].state ~= "disconnected" and furnace[i].fuel < 10) then
			sendMessage({["taskname"]="refuel", ["furnacenumber"]=i, ["x"]=furnace[i].x, ["y"]=furnace[i].y});
			return;
		end
	end
	sendMessage({["taskname"]=message});
end

function updateFurnaceData()
	term.clear();
	term.setCursorPos(1, 1);
	local sendUpdate = false;
	for i = 1, furnaceCount*2, 1 do
		if (network.isPresentRemote(furnace[i].furnaceName)) then
			local data = network.callRemote(furnace[i].furnaceName, methods.getFinishedItems.method, unpack(methods.getFinishedItems.parameter));
				if (data == nil) then
					furnace[i].finishedItems = 0;
				else
					furnace[i].finishedItems = data.qty or 0;
				end
			if (useOutput) then
				local data = network.callRemote(furnace[i].furnaceName, methods.getQueuedItems.method, unpack(methods.getQueuedItems.parameter));
				if (data == nil) then
					furnace[i].queuedItems = 0;
				else
					furnace[i].queuedItems = data.qty or 0;
				end
			else
				furnace[i].queuedItems = 0;
			end
			if (useFuel) then
				local data = network.callRemote(furnace[i].furnaceName, methods.getFuelItems.method, unpack(methods.getFuelItems.parameter));
				if (data == nil) then
					furnace[i].fuel = 0;
				else
					furnace[i].fuel = data.qty or 64;
				end
				if (furnace[i].fuel < 10) then
					sendUpdate = true;
				end
			else
				furnace[i].fuel = 64;
			end
			if (furnace[i].queuedItems > 0 and furnace[i].finishedItems >= 0) then
				furnace[i].state = "smelting";
			elseif (useOutput and furnace[i].finishedItems > 0 and furnace[i].queuedItems == 0) then
				furnace[i].state = "finished";
				sendUpdate = true;
			else
				furnace[i].state = "empty";
			end

			print(" " .. i .. " " .. furnace[i].fuel .. " " .. furnace[i].queuedItems .. " " .. furnace[i].finishedItems .. " " .. furnace[i].state);
		elseif (furnace[i].furnaceName == "NONE") then
			furnace[i].state = "disconnected";
			print(" " .. i .. " ?  ?  ? not set yet")
		else
			furnace[i].state = "disconnected";
			print(" " .. i .. " ?  ?  ? "  .. furnace[i].state);
		end
	end
	if (sendUpdate) then
		sendMessage({["taskname"]="update"});
	end
	print(errorMessage);
end


function checkTimer()
	timerID = os.startTimer(4);
	updateFurnaceData();
end

function findEmptyFurnace()
	for i = 1, furnaceCount*2, 1 do
		if (furnace[i].state == "empty" or furnace[i].state == "disconnected") then
			sendMessage({["taskname"]="additems", ["furnacenumber"]=i, ["x"]=furnace[i].x, ["y"]=furnace[i].y});
			return;
		end
	end
	sendTask("noemptyfurnace");
end

function setFurnace(message)
	local furnacenumber = message.furnacenumber;
	if (furnace[furnacenumber].furnaceName ~= "NONE") then
		return;
	end
	local itemcount = message.itemcount;
	local units = network.getNamesRemote();
	for i, u in pairs(units) do
		if (string.sub(u, 1, #furnaceGlobalName) == furnaceGlobalName) then
			local dataFinished = network.callRemote(u, methods.getFinishedItems.method, unpack(methods.getFinishedItems.parameter));
			local dataQueued = network.callRemote(u, methods.getQueuedItems.method, unpack(methods.getQueuedItems.parameter));
			if (dataFinished == nil and dataQueued ~= nil and dataQueued.qty == itemcount) then
				local b = true;
				for j, f in pairs(furnace) do
					if (f.furnaceName == u) then
						b = false;
					end
				end
				if (b) then
					furnace[furnacenumber].furnaceName = u;
					return;
				end
			end
		end
	end
end

function sendMessage(message)
	save();
	rednet.broadcast(textutils.serialize(message), system);
end

function checkMessage(message)
	if (message.state == "update") then
		updateFurnaceData();
	elseif (message.state == "setfurnace") then
		setFurnace(message);
	elseif (message.state == "getemptyfurnace") then
		findEmptyFurnace();
	elseif (message.state == "idle") then
		sendTask("checkitems");
	elseif (message.state == "error") then
		-- ouput chest full, fuel chest empty
		-- turn on redstone signal, toggle every second?
		errorMessage = message["errormessage"];
	end
end

function loop()
	while (true) do
		local e = { os.pullEvent() }
		if ( e[1] == "timer" and timerID == e[2] ) then 
			checkTimer();
			save();
		elseif (e[1] == "rednet_message" and e[4] == system) then
			checkMessage(textutils.unserialize(e[3]));
			save();
		end
	end
end

load();
sendMessage({["taskname"]="update"});
loop();