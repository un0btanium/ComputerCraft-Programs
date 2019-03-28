-- Dual Wood Chopper by UNOBTANIUM

-- VARIABLES
local w, h = term.getSize()
local posAction = "start"
local posPosition = 0
local errormessage = "Lastest Error: None"
local persistenceResume = false
local actionsPerformed = 0
local actions = {"","","","","","","",""}

local wood, saplings, bonemeal, coal, resumes = 0, 0, 0, 0, 0

local useBonemeal = true
local persistence = true
local extendedTracking = true
local height = 55
local timeWaitingToGrow = 5
local timeBetweenBonemealing = 1
local timeBeforeNextTree = 0
local redstoneTicks = 5


-- MENU


function menu()
	local menustate = 1
	local selected = 1

	while true do
		local menus = {
		{{"Start",2},{"Options",3},{"Statistics",130},{"Quit",0}},
		{{"Chop",100},{"Go up",101},{"Build layout",102},{"Back",1}},
		{{"Number Values",4},{"Boolean Values",5},{"Back",1}},
		{{"Height            " .. height,110},{"Bonemeal Interval " .. timeBetweenBonemealing ,111},{"Waiting to Grow   " .. timeWaitingToGrow ,112},{"Tree Interval     " .. timeBeforeNextTree ,113},{"Redstone Ticks    " .. redstoneTicks , 114},{"Back",3}},
		{{"Session Persistence " .. tostring(persistence) ,120},{"Bonemeal Usage      " .. tostring(useBonemeal) ,121},{"Extended Tracking   " .. tostring(extendedTracking), 122 },{"Back",3}}
		}

		term.clear()
		header("Dual Wood Chopper")
		local start = 4
		for i=1,table.getn(menus[menustate]) do
			term.setCursorPos(8,start+i)
			term.write(menus[menustate][i][1])
			if selected == i then
				term.setCursorPos(4,4+i)
				term.write("C>")
			end
		end

		local event, key = os.pullEvent("char")
		if key == "w" then
			selected = selected - 1
			if selected == 0 then
				selected = table.getn(menus[menustate])
			end
		elseif key == "s" then
			selected = selected + 1
			if selected > table.getn(menus[menustate]) then
				selected = 1
			end
		elseif key == "a" then
			selected = table.getn(menus[menustate])
			key = "d"
		end
		if key == "d" then
			if menus[menustate][selected][2] == 0 then
				term.clear()
				term.setCursorPos(1,1)
				break
			elseif menus[menustate][selected][2] < 100 then
				menustate = menus[menustate][selected][2]
				selected = 1
			elseif menus[menustate][selected][2] == 100 then
				main()
			elseif menus[menustate][selected][2] == 101 then
				goUp()
			elseif menus[menustate][selected][2] == 102 then
				buildLayout()
			elseif menus[menustate][selected][2] == 110 then
				height = betterRead(1+start,height)
			elseif menus[menustate][selected][2] == 111 then
				timeBetweenBonemealing = betterRead(2+start,timeBetweenBonemealing)
			elseif menus[menustate][selected][2] == 112 then
				timeWaitingToGrow = betterRead(3+start,timeWaitingToGrow)
			elseif menus[menustate][selected][2] == 113 then
				timeBeforeNextTree = betterRead(4+start,timeBeforeNextTree)
			elseif menus[menustate][selected][2] == 114 then
				redstoneTicks = betterRead(5+start,redstoneTicks)
			elseif menus[menustate][selected][2] == 120 then
				persistence = not persistence
			elseif menus[menustate][selected][2] == 121 then
				useBonemeal = not useBonemeal
			elseif menus[menustate][selected][2] == 122 then
				extendedTracking = not extendedTracking
			elseif menus[menustate][selected][2] == 130 then
				overview()
			end
		end
		saveVariables()
	end

end

function betterRead(y,text)
	term.setCursorBlink(true)
	local s = tostring(text)
	local x = 26
	local w,h = term.getSize()

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
		if e[1] == "timer" and e[2] == delay then
			delay = os.startTimer( 2 )
		elseif e[1] == "char" then
			s = s .. e[2]
		elseif e[1] == "key" then
			if e[2] == keys.enter then
				break
			elseif e[2] == keys.backspace then
				s = s:sub( 1, s:len() - 1 )
			end
		end
	end
	term.setCursorBlink(false)
 	s = tonumber(s)
 	if not s or s < 0 then
 		s = text
 	end
	return s
end

-- MAIN PROGRAM

function main()
	while true do
		drawScreen("Function: Main Start")

		getSapling(true)
		placeSaplings(true)
		bonemealing(true)
		chopUp(true)
		chopDown(true)
		dropWood(true)
		refuel(true)
		gotoStart(true)

		perform("reset","finished",0)

		drawScreen("Function: Main End")
		--need check for stop (redstone or rednet)
		if redstone.getInput("left") then
			return
		end
		sleep(timeBeforeNextTree) 
	end
end


function goUp()
	for i=1,height do
		if turtle.detectUp() then
			turtle.digUp()
		end
		turtle.up()
	end
	perform("reset","chopup",(height*3)+100)
	restart()
	main()
	perform("reset","start",0)
	sleep(0)
end


function getSapling(reset)
	drawScreen("Function: Get Saplings Start")
	if reset then
		perform("reset","getsapling",0)
	elseif not (posAction == "getsapling") then
		return
	end
	perform("back","getsapling",1)
	if posPosition == 1 then
		turtle.select(1)
		if not turtle.dropDown() and turtle.getItemCount(1) > 0 then
			turtle.drop()
		end
		turtle.suckDown()
		drawScreen("Suck Down Saplings")
		if turtle.getItemCount(1) > 5 then
			turtle.dropDown(turtle.getItemCount(1)-5)
			if turtle.getItemCount(1) > 5 then
				saplings = saplings + turtle.getItemCount(1)-5
				saveStats()
				errormessage = "Latest Error: Sapling Chest Is Full!"
				turtle.dropUp(turtle.getItemCount(1))
			end
		end
		perform("reset","getsapling",2)
	end
	saplings = saplings + 5
	saveStats()
	perform("forward","getsapling",3)

	if not reset and posAction == "getsapling" then
		persistenceResume = true
		drawScreen("Resume...")
	end

	drawScreen("Function: Get Saplings End")
end

function placeSaplings(reset)
	drawScreen("Function: Place Saplings Start")
	if reset then
		perform("reset","placesaplings",0)
	elseif not (posAction == "placesaplings") then
		return
	end
	turtle.select(1)
	perform("chop","placesaplings",1)
	perform("forward","placesaplings",2)
	perform("chop","placesaplings",3)
	perform("forward","placesaplings",4)
	perform("right","placesaplings",5)
	perform("place","placesaplings",6)
	perform("left","placesaplings",7)
	perform("back","placesaplings",8)
	perform("place","placesaplings",9)
	perform("right","placesaplings",10)
	perform("chop","placesaplings",11)
	perform("place","placesaplings",12)
	perform("left","placesaplings",13)
	perform("back","placesaplings",14)
	perform("place","placesaplings",15)

	if not reset and posAction == "placesaplings" then
		persistenceResume = true
		drawScreen("Resume...")
	end

	drawScreen("Function: Place Saplings End")
end


function bonemealing(reset)
	drawScreen("Function: Bonemealing Start")
	if reset then
		perform("reset","bonemeal",0)
	elseif not (posAction == "bonemeal") then
		return
	end
	if useBonemeal and posPosition == 0 then
		while true do
			turtle.select(1)
			if not turtle.compare() then
				if turtle.getItemCount(2) > 0 then
					turtle.select(2)
					turtle.dropDown()
					turtle.drop()
				end
				break
			elseif turtle.getItemCount(2) == 0 and not turtle.suckDown() then
				if not errormessage == "Latest Error: No Bonemeal Left!!!" then
					errormessage = "Latest Error: No Bonemeal Left!!!"
					drawScreen("New Error Occured!!!")
				end
				sleep(10)
			else
				turtle.select(2)
				if turtle.place() then
					bonemeal = bonemeal + 1
					saveStats()
				end
				turtle.select(1)
				if turtle.compare() then
					drawScreen("Tree didnt grew!")
					sleep(timeBetweenBonemealing)
				end
			end
		end
	else
		while true do
			perform("forward","bonemeal",2)
			turtle.select(1)
			if not turtle.compare() then
				break
			end
			perform("reset","bonemeal",0)
			perform("back","bonemeal",1)
			sleep(timeWaitingToGrow + 0.1)
		end
	end

	if not reset and posAction == "bonemeal" then
		persistenceResume = true
		drawScreen("Resume...")
	end

	drawScreen("Function: Bonemealing Start")
end




function chopUp(reset)
	drawScreen("Function: Chop Up Start")
	turtle.select(1)
	if reset then
		perform("reset","chopup",0)
		rednet.open("right")
		rednet.broadcast("DWCdigdown")
		rednet.close("right")
	elseif not (posAction == "chopup") then
		return
	end

	perform("chop","chopup",1)
	perform("forward","chopup",2)
	perform("chop","chopup",3)
	if posPosition == 3 and redstoneTicks > 0 then
		redstone.setOutput("down", true)
		sleep(math.floor(redstoneTicks)/10)
		redstone.setOutput("down", false)
	end
	for i=0,height-1,1 do
		perform("chopUp","chopup",4+i*3)
		perform("up","chopup",5+i*3)
		perform("chop","chopup",6+i*3)
	end
	perform("back","chopup",(height-1)*3+7)

	if not reset and posAction == "chopup" then
		persistenceResume = true
		drawScreen("Resume...")
	end

	drawScreen("Function: Chop Up End")
end



function chopDown(reset)
	drawScreen("Function: Chop Down Start")
	turtle.select(1)
	if reset then
		rednet.open("right")
		while true do
			local event, id, message, distance = os.pullEvent("rednet_message")
			if type(message) == "string" and message == "DWCdigdown" and distance == height then
				break
			end
			drawScreen(event .. " " .. message .. " " .. distance)
		end
		rednet.close("right")
		perform("reset","chopdown",0)
	elseif not (posAction == "chopdown") then
		return
	end

	perform("right","chopdown",1)
	perform("chop","chopdown",2)
	perform("forward","chopdown",3)
	perform("left","chopdown",4)
	perform("chop","chopdown",5)
	perform("forward","chopdown",6)
	perform("chop","chopdown",7)
	for i=0,height-1,1 do
		perform("chopDown","chopdown",8+i*3)
		perform("down","chopdown",9+i*3)
		perform("chop","chopdown",10+i*3)
	end
	perform("back","chopdown",(height-1)*3+11)

	if not reset and posAction == "chopdown" then
		persistenceResume = true
		drawScreen("Resume...")
	end

	drawScreen("Function: Chop Down End")
end


function dropWood(reset)
	drawScreen("Function: Drop Wood Start")
	if reset then
		perform("reset","dropwood",0)
	elseif not (posAction == "dropwood") then
		return
	end
	for i=2,16 do
		if turtle.getItemCount(i) > 0 then
			wood = wood + turtle.getItemCount(i)
			saveStats()
			turtle.select(i)
			if i == 2 and turtle.getFuelLevel() < height*3 then
				perform("dropDown","dropwood",i-1,turtle.getItemCount(i)-32)
			else
				perform("dropDown","dropwood",i-1,64)
			end
		else
			perform("reset","dropwood",i-1)
		end
	end

	if not reset and posAction == "dropwood" then
		persistenceResume = true
		drawScreen("Resume...")
	end

	drawScreen("Function: Drop Wood End")
end


function refuel(reset)
	drawScreen("Function: Refuel Start")
	if reset then
		if turtle.getFuelLevel() >= height*3 then
			return
		end
		perform("reset","refuel",0)
	elseif not (posAction == "refuel") then
		return
	end
	perform("back","refuel",1)
	perform("back","refuel",2)
	turtle.select(2)
	perform("dropDown","refuel",3,32)
	perform("forward","refuel",4)
	perform("down","refuel",5)
	perform("turn","refuel",6)
	local tryAgain = true
	while tryAgain do
		perform("suck","refuel",7)
		coal = coal + turtle.getItemCount(2)
		saveStats()
		perform("down","refuel",8)
		perform("forward","refuel",9)
		if posPosition == 9 then
			if turtle.getFuelLevel() + (turtle.getItemCount(2)-8)*80 >= height*7 then
				perform("dropUp","refuel",10,8)
				tryAgain = false
			elseif turtle.getFuelLevel() + (turtle.getItemCount(2)-3)*80 >= height*7 then
				perform("dropUp","refuel",10,3)
				tryAgain = false
			else
				turtle.suckUp()
				if turtle.getItemCount(3) > 0 then
					turtle.select(3)
					turtle.refuel()
					turtle.select(2)
				end
				for i=turtle.getItemCount(2),2,-1 do
					if i <= 2 then
						perform("dropUp","refuel",10,turtle.getItemCount(2))
						drawScreen("Not enought coal to keep going. Waiting...")
						sleep(16)
						perform("refuel","refuel",11)
						perform("back","refuel",12)
						perform("up","refuel",13)
						perform("reset","refuel",6)
					elseif turtle.getFuelLevel() + (turtle.getItemCount(2)-i)*80 >= height*7 then
						perform("dropUp","refuel",10,i)
						tryAgain = false
						break
					end
				end
			end
		end
	end
	drawScreen("refueled: " .. turtle.getItemCount(2))
	perform("refuel","refuel",11)
	perform("back","refuel",12)
	perform("up","refuel",13)
	perform("turn","refuel",14)
	perform("up","refuel",15)
	perform("forward","refuel",16)

	if not reset and posAction == "refuel" then
		persistenceResume = true
		drawScreen("Resume...")
	end

	drawScreen("Function: Refuel End")
end

function gotoStart(reset)
	drawScreen("Function: Goto Start Start")
	if reset then
		perform("reset","gotostart",0)
	elseif not (posAction == "gotostart") then
		return
	end

	perform("left","gotostart",1)
	perform("forward","gotostart",2)
	perform("right","gotostart",3)

	drawScreen("Function: Goto Start End")
end







-- RESUME / SESSION PERSISTENCE

function restart()
	persistenceResume = false
	getSapling(persistenceResume)
	placeSaplings(persistenceResume)
	bonemealing(persistenceResume)
	chopUp(persistenceResume)
	chopDown(persistenceResume)
	dropWood(persistenceResume)
	refuel(persistenceResume)
	gotoStart(persistenceResume)
end





-- BUILDING

function buildLayout()
	term.clear()
	centered("This program builds the layout.", 9)
	centered("You can cancel with Ctrg + T", 10)
	checkItemSlot(1,"or more charcoal", 12)
	checkItemSlot(2,"chest for wood storage",1)
	checkItemSlot(3,"chest for bonemeal storage",1)
	checkItemSlot(4,"chest for sapling storage",1)
	checkItemSlot(5,"furnace",1)
	checkItemSlot(6,"lever",1)
	checkItemSlot(7,"or more saplings",1)
	checkItemSlot(8,"or more bonemeal",1)
	checkItemSlot(9,"dirt blocks",4)
	while turtle.getFuelLevel() < 50 do
		checkItemSlot(10," fuel (e.g. charcoal)", 1)
		turtle.refuel()
	end

	centered("Start the building process?", 5)
	centered("Y / N", 7)
	while true do
		local event, key = os.pullEvent("char")
		if key == "n" then return
		elseif key == "y" then break end
		sleep(0)
	end 
	term.clear()
	centered("Take a step back please!!!", 6)
	sleep(5)
	centered("Building...", 7)
	turtle.select(10)
	turtle.digDown()
	turtle.select(3) -- bonemeal chest
	turtle.placeDown()
	turtle.select(8) -- bonemeal indicator
	turtle.dropDown()
	for i = 1, 5 do
		if i == 3  or i == 4 then
			turtle.turnRight()
		end
		turtle.forward()
		turtle.select(10)
		turtle.digDown()
		if i<= 4 then
			turtle.select(9) -- dirt block
		else
			turtle.select(2) -- wood chest
		end
		turtle.placeDown()
	end
	turtle.forward()
	turtle.select(10)
	for i = 1,2 do
		turtle.digDown()
		turtle.down()
		turtle.dig()
	end
	turtle.forward()
	turtle.select(5) -- furnace
	turtle.placeUp()
	turtle.select(1) -- charcoal for the furnace
	turtle.dropUp()
	turtle.back()
	for i = 1, 2 do turtle.up() end
	turtle.turnRight()
	turtle.forward()
	turtle.turnRight()
	turtle.select(10)
	turtle.digDown()
	turtle.select(4) -- sapling chest
	turtle.placeDown()
	turtle.select(7) -- sapling indicator
	turtle.dropDown()
	turtle.forward()
	turtle.turnLeft()
	turtle.select(6) -- lever
	turtle.place()
	turtle.select(10)
	turtle.drop()
	turtle.turnRight()
end


function checkItemSlot(slot, item, amount)
	header("Building layout")
	if turtle.getFuelLevel() < 50 then
		centered(slot .. " / 10", 4)
	else
		centered(slot .. " / 9", 4)
	end
	centered("Put " .. amount .. " " .. item,5)
	centered("into the selected slot!",6)
	turtle.select(slot)
	while turtle.getItemCount(slot) < amount do
		sleep(0.5)
	end
	term.clear()
end






-- PERFORM ACTION + SESSION PERSISTENCE

function perform(action, pos, num, amount)
	amount = amount or 64
	if action == "reset" then
		if extendedTracking then
			drawScreen("" .. action .. " " .. pos .. num)
		end
		posAction = pos
		posPosition = num
	elseif (pos == posAction and num-1 == posPosition) then
		if extendedTracking then
			drawScreen("" .. action .. " " .. pos .. num)
		end
		posAction = pos
		posPosition = num
		actionsPerformed = actionsPerformed + 1
		local file = fs.open("DWCpos","w")
			file.writeLine(pos)
			file.writeLine(num)
		file.close()
		if action == "up" then
			turtle.up()
		elseif action == "chop" then
			turtle.dig()
		elseif action == "chopDown" then
			turtle.digDown()
		elseif action == "chopUp" then
			turtle.digUp()
		elseif action == "down" then
			turtle.down()
		elseif action == "forward" then
			turtle.forward()
		elseif action == "back" then
			turtle.back()
		elseif action == "place" then
			turtle.place()
		elseif action == "right" then
			turtle.turnRight()
		elseif action == "left" then
			turtle.turnLeft()
		elseif action == "turn" then
			if math.random() < 0.5 then
				turtle.turnLeft()
				turtle.turnLeft()
			else
				turtle.turnRight()
				turtle.turnRight()
			end

			--?????
		elseif action == "drop" then
			turtle.drop(amount)
		elseif action == "dropDown" then
			turtle.dropDown(amount)
		elseif action == "dropUp" then
			turtle.dropUp(amount)
		elseif action == "suck" then
			turtle.suck()
		elseif action == "suckDown" then
			turtle.suckDown()
		elseif action == "suckUp" then
			turtle.suckUp()
		elseif action == "refuel" then
			turtle.refuel()
		end
	end
end

function checkState(pos, num, diff)
	diff = diff or 0
	return ((pos == posAction) and (num == posPosition+diff))
end

-- ON SCREEN

function drawScreen(text)
	term.clear()
	for i=1,7 do
		actions[i] = actions[i+1]
		term.setCursorPos(1,i+1)
		term.write(actions[i])
	end
	actions[8] = text
	term.setCursorPos(1, 8)
	term.write(actions[7])
	term.setCursorPos(1,10)
	term.write("------------------------------")
	term.setCursorPos(1, 11)
	term.write(errormessage)
	--[[
	term.setCursorPos(1,12)
	term.write("Wood: " .. wood .. " | Coal: " .. coal)
	term.setCursorPos(1,13)
	term.write("Saplings: " .. saplings .. " | Bonemeal: " .. bonemeal)
	]]--

end


function overview()
	term.clear()
	header("Statistics")
	term.setCursorPos(8, 5)
	term.write("Wood: " .. wood)
	term.setCursorPos(4, 6)
	term.write("Saplings: " .. saplings)
	term.setCursorPos(4, 7)
	term.write("Bonemeal: " .. bonemeal)
	term.setCursorPos(8, 8)
	term.write("Coal: " .. coal)
	term.setCursorPos(5, 10)
	term.write("Resumes: " .. resumes)
	term.setCursorPos(5, 11)
	term.write("Actions: " .. actionsPerformed)
	os.pullEvent("char")
	sleep(0.1)
end

function centered(text, ypos)
	term.setCursorPos(w/2 - #text/2, ypos)
 	term.write(text)
end

function header(str, ypos)
	ypos = ypos or 1
 	centered(str, ypos)
 	centered(string.rep("-", w), ypos+1)
end

-- SAVE AND LOAD

function saveVariables()
	local file = fs.open("DWCvars","w")
		file.writeLine(tostring(useBonemeal))
		file.writeLine(tostring(persistence))
		file.writeLine(tostring(extendedTracking))
		file.writeLine(height)
		file.writeLine(timeWaitingToGrow)
		file.writeLine(timeBetweenBonemealing)
		file.writeLine(timeBeforeNextTree)
		file.writeLine(redstoneTicks)
	file.close()
end

function saveStats()
	local file = fs.open("DWCstats","w")
		file.writeLine(wood)
		file.writeLine(saplings)
		file.writeLine(bonemeal)
		file.writeLine(coal)
		file.writeLine(actionsPerformed)
		file.writeLine(resumes)
	file.close()
end

function load()
	if fs.exists("DWCvars") then
		local file = fs.open("DWCvars","r")
			if file.readLine() == "false" then
				useBonemeal = false
			end
			if file.readLine() == "false" then
				persistence = false
			end
			if file.readLine() == "false" then
				extendedTracking = false
			end
			height = tonumber(file.readLine())
			timeWaitingToGrow = tonumber(file.readLine())
			timeBetweenBonemealing = tonumber(file.readLine())
			timeBeforeNextTree = tonumber(file.readLine())
			redstoneTicks = tonumber(file.readLine())
		file.close()
	end

	if fs.exists("DWCstats") then
		local file2 = fs.open("DWCstats","r")
			wood = tonumber(file2.readLine())
			saplings = tonumber(file2.readLine())
			bonemeal = tonumber(file2.readLine())
			coal = tonumber(file2.readLine())
			actionsPerformed = tonumber(file2.readLine())
			resumes = tonumber(file2.readLine())
		file2.close()
	end
end


-- CHECK FOR SESSION PERSISTENCE AND MAIN

term.clear()
term.setCursorPos(1, 1)
drawScreen("Dual Wood Chopper initiated!!!")
load()
if persistence and fs.exists("DWCpos") then
	local file = fs.open("DWCpos","r")
		posAction = file.readLine()
		posPosition = tonumber(file.readLine())
	file.close()
	drawScreen("Restart at " .. posAction .. posPosition)
	restart()
	main()
end

menu()