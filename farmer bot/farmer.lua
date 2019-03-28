

local countdown = 900;
local pos = {["x"]=0, ["y"]=0, ["z"]=0, ["r"]=1};
local slot = {};
for i = 1, 16, 1 do
    table.insert(slot, {["state"]="empty"});
end






function save()
    local file = fs.open("farmer","w");
        file.writeLine(string.gsub(textutils.serialize(pos),"\n%S-",""));
        file.writeLine(string.gsub(textutils.serialize(slot),"\n%S-",""));
        file.writeLine(countdown);
    file.close();
end

function load()
    if not fs.exists("farmer") then return end
    local file = fs.open("farmer","r")
        pos = textutils.unserialize(file.readLine())
        slot = textutils.unserialize(file.readLine())
        countdown = tonumber(file.readLine());
    file.close();
end

function turnLeft()
    if (pos.r == 0) then
        pos.r = 3;
    else
        pos.r = pos.r - 1;
    end
    save();
    turtle.turnLeft();
end

function turnRight()
    pos.r = (pos.r + 1) % 4;
    save();
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

function forward(l)
	for i = 1, l do
	    if (pos.r == 0) then
	        pos.y = pos.y + 1;
	    elseif (pos.r == 1) then
	        pos.x = pos.x + 1;
	    elseif (pos.r == 2) then
	        pos.y = pos.y - 1;
	    elseif (pos.r == 3) then
	        pos.x = pos.x - 1;
	    end
	    save();
	    while not turtle.forward() do
	    	os.sleep(1);
	    end
   	end
end

function up()
    pos.z = pos.z + 1;
    save();
    while not turtle.up() do
    	os.sleep(1);
    end
end

function down()
    pos.z = pos.z - 1;
    save();
    while not turtle.down() do
    	os.sleep(1);
    end
end


function moveToField()
	if not (pos.x == 0 and pos.y == 0 and pos.z == 0 and pos.r == 1) then os.shutdown(); end
	rotate(3);
	forward(1);
	for i = 1, 7 do
		up();
	end
	rotate(1);
	foward(7);
	rotate(0);
	forward(22);
	rotate(1);
	forward(3);
	rotate(0);
	for i = 1, 3 do
		down();
	end
end

function moveToBase()
	forward(4);
	rotate(2);
	forward(22);
	rotate(3);
	forward(7);
	rotate(1);
	for i = 1, 7 do
		down();
	end
	forward(1);
	for s = 1, 16 do
		turtle.select(s);
		turtle.drop();
	end
end

function harvestPlant()
	turtle.select(1);
	if turtle.detectDown() then
		turtle.digDown();
		for s = 1, 2 do
			local itemdata = turtle.getItemDetail(s);
			if (string.match(itemdata.name, "seed")) then
				turtle.select(s);
				turtle.placeDown();
				break;
			end
		end
		for s = 1, 2 do
			turtle.select(s);
			turtle.transferTo(3);
		end
	end
end

function dropSeeds()
	for s = 1, 16 do
		local itemdata = turtle.getItemDetail(s);
		if (string.match(itemdata.name, "seed")) then
			turtle.select(s);
			turtle.drop();
			break;
		end
	end
end

function harvest()
	moveToField();
	turtle.select(1);
	for i = 1, 4 do
		for j = 1, 16 do
			harvestPlant();
			forward(1);
		end
		rotate(3);
		forward(1);
		rotate(2);
		for j = 1, 16 do
			harvestPlant();
			forward(1);
		end
		if (i < 4) then
			rotate(3);
			forward(1);
			rotate(0);
		end
	end
	rotate(3);
	dropSeeds();
	rotate(1);
	moveToBase();
end


function countDown()
	while (true) do
		if (countdown > 0) then
			print(countdown);
			os.sleep(30);
			countdown = countdown - 30;
			save();
		else
			harvest();
			countdown = 900;
			save();
		end
	end
end

load();
countDown();