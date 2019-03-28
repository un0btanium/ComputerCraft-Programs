

local farmsize = {["x"]=4, ["y"]=8, ["dx"]=3, ["dy"]=3};
local waitTime = 300;
local countdown = 300;

local stats = {["wood"]=0, ["tree"]=0};
local pos = {["x"]=-2, ["y"]=0, ["z"]=0, ["r"]=1, ["treex"]=1, ["treey"]=1, ["state"]="idle"};
local slot = {};
for i = 1, 16, 1 do
    table.insert(slot, {["state"]="empty"});
end
--state: idle, moveToTree, chop, moveDown, plant, furnace

local EM = "";

-- SAVE FILES

function saveVar()
	local file = fs.open("unobtanium_chopper_var","w");
	    file.writeLine(string.gsub(textutils.serialize(farmsize),"\n%S-",""));
	    file.writeLine(waitTime);
	    file.writeLine(countdown);
  	file.close();
end

function loadVar()
	if not fs.exists("unobtanium_chopper_var") then return end
	local file = fs.open("unobtanium_chopper_var","r")
	    farmsize = textutils.unserialize(file.readLine())
	    waitTime = tonumber(file.readLine());
	    countdown = tonumber(file.readLine());
	file.close();
end

function savePos()
	drawGUI();
    local file = fs.open("pos","w");
        file.writeLine(string.gsub(textutils.serialize(pos),"\n%S-",""));
        file.writeLine(string.gsub(textutils.serialize(slot),"\n%S-",""));
        file.writeLine(string.gsub(textutils.serialize(stats),"\n%S-",""));
    file.close();
end

function loadPos()
    if not fs.exists("pos") then return end
    local file = fs.open("pos","r")
        pos = textutils.unserialize(file.readLine())
        slot = textutils.unserialize(file.readLine())
        stats = textutils.unserialize(file.readLine())
    file.close();
end


-- MOVEMENT

function turnLeft()
    if (pos.r == 0) then
        pos.r = 3;
    else
        pos.r = pos.r - 1;
    end
    savePos();
    turtle.turnLeft();
end

function turnRight()
    pos.r = (pos.r + 1) % 4;
    savePos();
    turtle.turnRight();
end

function rotate(r)
    while (not (pos.r == r)) do
        if (r == pos.r-1 or (r == 3 and pos.r == 0)) then
            turnLeft();
        elseif (r == pos.r+1 or (r == 0 and pos.r == 3)) then
            turnRight();
        elseif math.ceil(math.random()) < 0.5 then
            turnLeft()
        else
            turnRight();
        end
    end
end

function forward()
    if (pos.r == 0) then
        pos.y = pos.y - 1;
    elseif (pos.r == 1) then
        pos.x = pos.x + 1;
    elseif (pos.r == 2) then
        pos.y = pos.y + 1;
    elseif (pos.r == 3) then
        pos.x = pos.x - 1;
    end
    savePos();
    turtle.forward();
end

function up()
    pos.z = pos.z + 1;
    savePos();
    turtle.up();
end

function down()
    pos.z = pos.z - 1;
    savePos();
    turtle.down();
end

function moveTo(x,y,z)
	z = z or 0;
    while (not (x == pos.x and y == pos.y and z == pos.z)) do
    	if not (z == pos.z) and ((z > pos.z and not turtle.detectUp()) or (z < pos.z and not turtle.detectDown())) then
            while (z > pos.z) do
                up();
            end
            while (z < pos.z) do
                down();
            end
        elseif (not (pos.x == x)) then
        	local dir = table.remove({0,2},math.random(1,2));
            if (pos.x < x) then
                rotate(1);
                if (turtle.detect()) then -- new route around the obstacle
                	rotate(dir);
	            end
            elseif (pos.x > x) then
                rotate(3);
                if (turtle.detect()) then -- new route around the obstacle
                	rotate(dir);
	            end
            end
            forward();
        elseif (not (pos.y == y) and pos.x >= 0) then
        	local dir = table.remove({1,3},math.random(1,2))
            if (pos.y > y) then
                rotate(0);
                if (turtle.detect()) then -- new route around the obstacle
                	rotate(dir);
	            end
            elseif (pos.y < y) then
                rotate(2);
                if (turtle.detect()) then -- new route around the obstacle
                	rotate(dir);
	            end
            end
            forward();
        end
    end
end

-- GUI

function drawGUI()
	term.clear();
	local w, h = term.getSize();
	write(1, 1, string.rep("#",w));
	write(1, 2, "# State: " .. pos.state);
	write(1, 3, "# Pos: " .. pos.x .. " | " .. pos.y .. " | " .. pos.z);
	write(1, 4, "# Tree: " .. pos.treex .. " | " .. pos.treey);
	write(1, 5, "# Fuel: " .. turtle.getFuelLevel());
	write(1, 6, string.rep("#",w));
	write(1, 7, "# Wood: " .. stats.wood);
	write(1, 8, "# Trees: " .. stats.tree);
	write(1, 9, string.rep("#",w));
	write(1, 10, "# Farm Size: " .. farmsize.x .. " | " .. farmsize.y);
	write(1, 11, "# Tree Spacing: " .. farmsize.dx .. " | " .. farmsize.dy);
	write(1, 12, string.rep("#",w));
	if (countdown < waitTime) then
		write(1, 13, "Countdown: " .. waitTime-countdown .. " / " .. waitTime);
	end
	write(1, 13, tostring(EM));
end

function write(x, y, text)
	term.setCursorPos(x, y);
	term.write(text);
end

function setErrorMessage(message)
	EM = message;
	drawGUI();
end


-- PROCEDURE

function checkCurrentSlot()
	if (slot[turtle.getSelectedSlot()].state ~= "wood") then
		if (turtle.getItemCount(turtle.getSelectedSlot()) > 0) then
			if (countSlots("wood") > 0) then
				local woodSlots = findSlots("wood");
				for i, s in pairs(woodSlots) do
					if (turtle.getItemCount(s) < 64) then
						turtle.select(s);
						return;
					end
				end
				turtle.select(woodSlots[1]);
			else
				local emptySlots = findSlots("empty");
				turtle.select(emptySlots[1]);
				slot[emptySlots[1]].state = "wood";
				return;
			end
		else
			slot[turtle.getSelectedSlot()].state = "wood";
			return;
		end
	end 
	if (turtle.getItemCount(turtle.getSelectedSlot()) == 64) then
		local woodSlots = findSlots("wood");
		for i, s in pairs(woodSlots) do
			if (turtle.getItemCount(s) < 64) then
				turtle.select(s);
				return;
			end
		end
		turtle.select(woodSlots[1]);
		if (turtle.getItemCount(turtle.getSelectedSlot()) == 64) then
			local emptySlots = findSlots("empty");
			turtle.select(emptySlots[1]);
			slot[emptySlots[1]].state = "wood";
			return;
		end
	end
end

function countSlots(type)
    local count = 0;
    for i = 1, 16, 1 do
        if (slot[i].state == type) then
            count = count + 1;
        end
    end
    return count;
end

function findSlots(type)
    local a = {};
    for i = 1, 16, 1 do
        if (slot[i].state == type) then
            table.insert(a, i);
        end
    end
    return a;
end

function dropItems(itemtype, direction, errormessage)
	errormessage = errormessage or "Unknown Error";
    if (countSlots(itemtype) == 0) then
        return;
    end
    slots = findSlots(itemtype);
    for i, s in pairs(slots) do
        if (turtle.getItemCount(s) > 0) then
            turtle.select(s);
            local b = drop(direction);
            if (not b or (b and turtle.getItemCount(s) > 0)) then
                for i = 1, 5, 1 do
                    drop(direction);
                end
                if (turtle.getItemCount(s) > 0) then
                	setErrorMessage(errormessage);
                    while (turtle.getItemCount(s) > 0) do
                        os.sleep(15);
                        drop(direction);
                    end
                    setErrorMessage("");
                end
            end
        end
        slot[s].state = "empty";
        savePos();
    end
end

function drop(direction)
    if (direction == "front") then
        return turtle.drop();
    elseif (direction == "down") then
        return turtle.dropDown();
    elseif (direction == "up") then
        return turtle.dropUp();
    end
end


function checkInventory(allways) -- check if there is enough space and a sapling left
	allways = allways or false;
	if (allways or (countSlots("empty") == 0 or countSlots("sapling") == 0 or turtle.getFuelLevel() < 400)) then
		if (not (pos.x == -2 or pos.x == -1 and pos.y == 0 and pos.z == 0) or turtle.getFuelLevel() < 400) then
			moveTo(0,0);
			rotate(3);
			forward();
			if (turtle.getFuelLevel() < 1000) then
				up(); up();
				forward();
				local woodSlot = findSlots("wood");
				local amount = 0;
				for i, s in pairs(woodSlot) do
					amount = amount + turtle.getItemCount(s);
					turtle.select(s);
					turtle.dropDown();
					if (turtle.getItemCount(s) > 0) then
						break;
					end
					slot[s].state = "empty";
					savePos();
					if (amount == 64) then
						break;
					elseif (amount > 64) then
						slot[s].state = "wood";
						savePos();
						break;
					end
				end
				rotate(1);
				forward();
				down();
				down();
				rotate(3);
				forward()
				local emptySlots = findSlots("empty");
				local s = emptySlots[1];
				slot[s].state = "coal";
				turtle.select(s);
				turtle.suckUp();
				savePos();
				if (turtle.getItemCount(s) > 8) then
					turtle.refuel(turtle.getItemCount(s)-8);
				end
				rotate(1);
				forward();
				up()
				rotate(3);
				turtle.select(s);
				slot[s].state = "empty";
				turtle.drop();
				turtle.refuel();
				savePos();
				down();
				forward();
			end
		end
		moveTo(-2, 0);
		rotate(3);
		while (countSlots("wood") > 0) do
			dropItems("wood", "front", "ERROR: Wood chest is filled up!");
			if (countSlots("wood") > 0) then
				os.sleep(10);
			end
		end
		savePos();
		rotate(0);
		while (countSlots("sapling") > 0) do
			dropItems("sapling","front", "ERROR: Sapling chest is filled up!");
			if (countSlots("sapling") > 0) then
				os.sleep(10);
			end
		end
		savePos();
		local emptySlots = findSlots("empty");
		local s = emptySlots[1];
		turtle.select(s);
		while (turtle.getItemCount(s) == 0) do
			turtle.suck();
			if (turtle.getItemCount(s) == 0) then
				os.sleep(10);
				setErrorMessage("ERROR: Not enough saplings!");
			end
		end
		slot[s].state = "sapling";
		savePos();
		rotate(1);
	end
	for i = 1, 16, 1 do
		if (turtle.getItemCount(i) == 0) then
			slot[i].state = "empty";
		end
	end
	savePos();
end

function nextTree()
	pos.state = "moveToTree";
	if (pos.treey % 2 == 1) then
		pos.treex = pos.treex + 1;
		if (pos.treex > farmsize.x) then
			pos.treey = pos.treey + 1;
			pos.treex = farmsize.x;
		end
	else
		pos.treex = pos.treex - 1;
		if (pos.treex <= 0) then
			pos.treey = pos.treey + 1;
			pos.treex = 1;
		end
	end
	if (pos.treey > farmsize.y) then
		pos.treey = 1;
		pos.state = "finished";
	end
end

function harvest()
	local x = pos.treex*farmsize.dx + (pos.treex-1);
	local y = pos.treey*farmsize.dy + (pos.treey-1);
	if (pos.state == "moveToTree") then
		checkInventory();
		if (pos.treey % 2 == 1) then
			moveTo(x-1, y);
			rotate(1);
		else
			moveTo(x+1, y);
			rotate(3);
		end
		pos.state = "chop";
	elseif (pos.state == "chop") then
		if (pos.x ~= x and pos.z == 0) then
			if (countSlots("wood") > 0) then
				local woodSlot = findSlots("wood");
				turtle.select(woodSlot[1]);
				if (not turtle.compare()) then
					if (not turtle.detect()) then
						pos.state = "plant";
						return;
					else
						nextTree();
						return;
					end
				end
			else 
				local saplingSlot = findSlots("sapling");
				turtle.select(saplingSlot[1]);
				if (turtle.compare()) then
					nextTree();
					return;
				elseif (not turtle.detect()) then
					pos.state = "plant";
					return;
				end
			end
			checkCurrentSlot();
			turtle.dig();
			stats.wood = stats.wood + 1;
			forward();
		end
		if (pos.state == "chop") then
			while (turtle.compareUp()) do
				checkCurrentSlot();
				turtle.digUp();
				stats.wood = stats.wood + 1;
				up();
			end
			pos.state = "moveDown";
		end
	elseif (pos.state == "moveDown") then
		while (not turtle.detectDown()) do
			down();
		end
		pos.state = "plant";
		stats.tree = stats.tree + 1;
	elseif (pos.state == "plant") then
		if (pos.treey % 2 == 1) then
			moveTo(x+1, y);
			rotate(3);
		else
			moveTo(x-1, y);
			rotate(1);
		end
		local saplingSlots = findSlots("sapling");
		local s = saplingSlots[1];
		turtle.select(s);
		turtle.place();
		turtle.suck();
		if (turtle.getItemCount(s) == 0) then
			slot[s].state = "empty";
		end
		nextTree();
	elseif (pos.state == "finished") then
		checkInventory(true);
		pos.state = "idle";
		countdown = 0;
	end
end


function main()
	while (true) do
		savePos();
		if (pos.state == "idle") then
			if (countdown >= waitTime) then
				pos.treex = 1;
				pos.treey = 1;
				pos.state = "moveToTree";
			else
				delay = os.startTimer(1);
				local event = { os.pullEvent() };
				if (event[1] == "timer" and event[2] == delay) then
					countdown = countdown + 1;
					saveVar();
				end
			end
		else
			setErrorMessage("");
			harvest();
		end
	end
end


loadVar();
loadPos();
main();