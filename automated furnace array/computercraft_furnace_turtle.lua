local system = "my furnace";
rednet.open("left");
local pos = {["x"]=0, ["y"]=0, ["z"]=0, ["r"]=1};

local currentTask = {["taskname"]="idle"};
local slot = {};
for i = 1, 16, 1 do
    table.insert(slot, {["state"]="empty"});
end


-- MOVEMENT

function savePos()
    local file = fs.open("furnacestation","w");
        file.writeLine(string.gsub(textutils.serialize(pos),"\n%S-",""));
        file.writeLine(string.gsub(textutils.serialize(currentTask),"\n%S-",""));
        file.writeLine(string.gsub(textutils.serialize(slot),"\n%S-",""));
        file.writeLine(system);
    file.close();
    writeTask();
end

function load()
    if not fs.exists("furnacestation") then return end
    local file = fs.open("furnacestation","r")
        pos = textutils.unserialize(file.readLine())
        currentTask = textutils.unserialize(file.readLine())
        slot = textutils.unserialize(file.readLine())
        system = file.readLine();
    file.close();
end

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
        pos.y = pos.y + 1;
    elseif (pos.r == 1) then
        pos.x = pos.x + 1;
    elseif (pos.r == 2) then
        pos.y = pos.y - 1;
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
    while (not (x == pos.x and y == pos.y and z == pos.z)) do

        if (pos.y == 0 and not (z == pos.z) and pos.x > 0) then
            while (z > pos.z) do
                if (turtle.detectUp()) then
                    moveTo(0, 0, pos.z);
                end
                up();
            end
            while (z < pos.z) do
                if (turtle.detectDown()) then
                    moveTo(0, 0, pos.z);
                end
                down();
            end
        elseif (not (pos.y == y) and pos.x > 0) then
            if (pos.y < y) then
                rotate(0);
                forward();
            elseif (pos.y > y) then
                rotate(2);
                forward();
            end
        elseif (not (pos.x == x)) then
            if (pos.x < x) then
                rotate(1);
                forward();
            elseif (pos.x > x) then
                rotate(3);
                forward();
            end
        elseif (not (pos.z == z)) then
            if (pos.y == -1) then
                rotate(0);
                forward();
            elseif (pos.y == 1) then
                rotate(2);
                forward();
            end
        end
    end
end






-- INVENTORY

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


-- BASE INTERACTIONS

function goToBase(askForTask)
    askForTask = askForTask or true
    if (not (pos.x == 0 and pos.y == 0 and pos.z == 0)) then
        moveTo(1,0,0);
        rotate(3);
        forward();
        rotate(1);
    end
    dropAllItems();
    checkFuelReserves();
    refuelTurtle();
    if (askForTask) then
        takeItemsOut();
    end
end

function dropAllItems()
    dropItems("finished", "front", "The output chest is full! Please take items out!");
    dropItems("ores", "top", "The input chest is too full! Please take some items out!");
    if (countSlots("fuel") ~= 2) then
        dropItems("fuel", "down", "The fuel chest is too full! Please take some items out!");
    end
end

function dropItems(type, direction, error)
    if (countSlots(type) == 0) then
        return;
    end
    if (type == "finished") then
        rotate(2);
    end
    slots = findSlots(type);
    for i, s in pairs(slots) do
        if (turtle.getItemCount(s) > 0) then
            turtle.select(s);
            local b = drop(direction);
            if (not b or (b and turtle.getItemCount(s) > 0)) then
                for i = 1, 10, 1 do
                    drop(direction);
                end
                if (turtle.getItemCount(s) > 0) then
                    sendMessage({["state"]="error", ["errormessage"]=error});
                    if (not (type == "finished")) then
                        return;
                    end
                    while (turtle.getItemCount(s) > 0) do
                        os.sleep(15);
                        drop(direction);
                    end
                end
            end
        end
        slot[s].state = "empty";
        savePos();
    end
    if (type == "finished") then
        rotate(1);
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

function takeItemsOut()
    local emptySlots = findSlots("empty");
    for i, s in pairs(emptySlots) do
        turtle.select(s)
        turtle.suckUp();
        if (turtle.getItemCount(s) == 0) then
            break;
        else
            slot[s].state = "ore";
            savePos();
        end
    end
    if (countSlots("ore") == 0) then
        local delay = os.startTimer(10);
        while (true) do
            local event = { os.pullEvent() };
            if (event[1] == "timer" and event[2] == delay) then
                break;
            elseif (event[1] == "rednet_message" and event[4] == system and textutils.unserialize(event[3]).taskname == "update") then
                os.cancelTimer(delay);
                break;
            elseif (event[1] == "redstone") then
                break;
            end
        end
        sendMessage({["state"]="idle"});
    else
        sendMessage({["state"]="getemptyfurnace"});
    end
end

function refuelTurtle()
    if (turtle.getFuelLevel() < 300) then
        while (true) do
            local fuelSlots = findSlots("fuel");
            if (table.getn(fuelSlots) == 0) then
                takeFuelOut(1);
                fuelSlots = findSlots("fuel");
            end
            for i, s in pairs(fuelSlots) do
                turtle.select(s);
                while (turtle.getItemCount(s) > 0) do
                    turtle.refuel(1);
                    if (turtle.getFuelLevel() > 2000) then
                        return;
                    end
                end
            end
            dropItems("fuel", "down", "The fuel chest is too full! Please take some items out!");
            takeFuelOut(2);
        end
    end
end

function takeFuelOut(stacks)
    stacks = stacks or 1
    if (stacks > 16) then
        stacks = 16;
    end
    while (true) do
        local emptySlots = findSlots("empty");
        for i = 1, stacks, 1 do
            if (emptySlots[i] == null) then
                break;
            end
            turtle.select(emptySlots[i]);
            turtle.suckDown();
            if (turtle.getItemCount(emptySlots[i]) > 0) then
                slot[emptySlots[i]].state = "fuel";
                savePos();
            end
        end
        local fuelSlots = findSlots("fuel");
        if (table.getn(fuelSlots) == 0) then
            sendMessage({["state"]="error", ["errormessage"]="No fuel left! Please put fuel into the chest!"});
            os.sleep(60);
        else
            return;
        end
    end
end

function checkFuelReserves()
    while (true) do
        if (countSlots("fuel") == 2) then
            return;
        end
        dropItems("fuel", "down", "The fuel chest is too full! Please take some items out!");
        takeFuelOut(2);
        if (countSlots("fuel") < 2) then
            local fuelSlots = findSlots("fuel");
            local amount = 0;
            for i, s in pairs(fuelSlots) do
                amount = turtle.getItemCount(s);
            end
            if (amount >= 128) then
                return;
            elseif (amount < 32) then
                sendMessage({["state"]="error", ["errormessage"]="Not enough fuel left! Please put fuel into the chest!"});
                return;
            else
                sendMessage({["state"]="error", ["errormessage"]="Low on fuel! Please put fuel into the chest!"});
                return;
            end
        else
            return;
        end
    end
end


-- FURNACE INTERACTIONS

function writeTask()
    term.clear();
    term.setCursorPos(1, 1);
    print(textutils.serialize(pos));
    print(textutils.serialize(currentTask));
end

function doTask()
    while (true) do
        writeTask();
        if (currentTask.taskname == "refuel") then
            refuelFurnace();
        elseif (currentTask.taskname == "retrieveitems") then
            retrieveItem();
        elseif (currentTask.taskname == "additems") then
            addOres();
        elseif (currentTask.taskname == "getemptyfurnace") then
            sendMessage({["state"]="getemptyfurnace"});
            waitForInput();
        elseif (currentTask.taskname == "idle") then
            sendMessage({["state"]="idle"});
            waitForInput();
        end
    end
end

function finishedTask()
    sendMessage({["state"] = "update"});
    if (countSlots("ore") == 0) then
        currentTask = {["taskname"]="idle"};
    else
        currentTask = {["taskname"]="getemptyfurnace"};
    end
    savePos();
end


function refuelFurnace()
    local fuelSlotsCount = countSlots("fuel");
    if (fuelSlotsCount == 0) then
        goToBase(false);
    end

    moveTo(currentTask.x, 0, 0);
    if (currentTask.y == 1) then
        rotate(0);
    else
        rotate(2);
    end
    local fuelSlots = findSlots("fuel");
    for i, s in pairs(fuelSlots) do
        local count = turtle.getItemCount(s);
        turtle.select(s);
        turtle.drop();
        if (turtle.getItemCount(s) > 0) then
            break;
        else
            slot[s].state = "empty";
            savePos();
        end
    end
    finishedTask();
end

function retrieveItem()
    if (countSlots("empty") == 0) then
        if (countSlots("fuel") + countSlots("finished") == 16) then
            goToBase(false);
        else
            local tempTask = currentTask;
            print("addOres")
            addOres();
            currentTask = tempTask;
        end
    end
    moveTo(currentTask.x, currentTask.y, -1);
    local emptySlots = findSlots("empty");
    s = emptySlots[1];
    turtle.select(s);
    turtle.suckUp();
    if (turtle.getItemCount(s) == currentTask.itemcount) then
        slot[s].state = "finished";
    elseif (turtle.getItemCount(s) == 0) then
        --moveTo(currentTask.x, currentTask.y, 1);
        slot[s].state = "finished";
        turtle.suckDown();
    else
        slot[s].state = "finished";
        while (turtle.getItemCount(s) ~= currentTask.itemcount) do
            os.sleep(10);
            turtle.suckUp();
        end
    end
    savePos();
    finishedTask();
end

function addOres() -- can be improved for fuel efficiency
    moveTo(currentTask.x, currentTask.y, 1);
    local oreSlots = findSlots("ore");
    local s = oreSlots[1];
    local count = turtle.getItemCount(s);
    turtle.select(s);
    turtle.dropDown();
    if (turtle.getItemCount(s) == 0) then
        slot[s].state = "empty";
        sendMessage({["state"]="setfurnace", ["furnacenumber"]=currentTask.furnacenumber, ["itemcount"]=count});
    elseif (count-turtle.getItemCount(s) == 0) then
        slot[s].state = "finished";
    end
    savePos();
    finishedTask();
end


-- MESSAGES

function sendMessage(message)
    rednet.broadcast(textutils.serialize(message), system);
end


function waitForInput()
    while (true) do
        writeTask();
        local e = { os.pullEvent() }
        if (e[1] == "rednet_message" and e[4] == system) then
            message = textutils.unserialize(e[3]);
            if (type(message) == "table") then
                if (message["taskname"] == "refuel" or message["taskname"] == "retrieveitems" or message["taskname"] == "additems") then
                    currentTask = message;
                    return; -- to doTask()
                elseif (message["taskname"] == "checkitems") then
                    currentTask = {["taskname"]="idle"};
                    goToBase(); -- may break stuff when ore items got picked up allready? -- sends message, requires response
                elseif (message["taskname"] == "noemptyfurnace") then
                    currentTask = {["taskname"]="idle"};
                    takeItemsOut(); -- sends message, requires response
                end
            end
        end
    end
end

load();
doTask();