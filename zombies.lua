--[[
zombies
Makes mice into zombies, controlled by captins

-- Index --

Variables
	makeCaptins - List of people to make captins
	idList - Popup and text id's
	playerIs - List of codes for player state
	keys - List of keys
	directions - List of directions
	miceList - List of mice (and list of their zombies)
	captinMov - Captin movements
	zombieMov - Zombie movements
	defaultZombieMov - Default values for new zombies
	Dimensions
		tfmDim - Size of tfm game screen
		textArea
		popUp
	linksList - For links
	zombieInfo - Info about zombies for textArea
	
startApocalypse()
	fillMiceList()
	zombieJump timer - for resetJump
	movZombies timer - for checkCaptinsMove

Events
	eventLoop
	eventNewPlayer
	eventPlayerLeft
	eventTextAreaCallback
	eventPopupAnswer
	eventKeyboard
	
Captin Control
	keyPressed
	checkCaptinsMove
	
Zombie Control
	moveZombies
	moveZombie (single)
	stopZombie
	resetJump

Setup
	fillMiceList
	sortPlayer

Set player
	makeCaptin
	makeZombie
	nullPlayer
	
Gui's
	newZombieButton
	addZombieToList
	newZombieClick
	
	makeZombiePop
	makeZombieAnswer
	
	infoPop

Tools
	makeLink
	runGlobal

Timer Code
	Timer functions

]]--

-- require("tools.tfm_dummy")

-- Variables --

-- List of people to make captins
makeCaptins = {}
makeCaptins["YourUsername"] = true

-- Popup and textArea id's
idList = {}
idList.newZombie = 0
idList.whoToZombify = 1
idList.infoPop = 2

-- List of codes for player state
playerIs = {}
playerIs.inRoom = 0
playerIs.captin = 1
playerIs.zombie = 2

-- List of codes for direction keys
keys = {}
keys["Left"] = 37;
keys["Up"] = 38;
keys["Right"] = 39;
keys["Down"] = 40;

-- List of directions
directions = {
	Left = 0,
	Right = 1,
	Up = 2,
	Down = 3
}

-- List of mice, and what they are (and their zombies/owners)
miceList = {}
-- miceList.player.status = num
-- miceList.player.zombies = {listOfZombies = yes}
-- miceList.player.owner = ownerName

-- List of captins and if they are moving
captinMov = {}
-- captinMov.captin.left = false

-- List of zombies and their movement
zombieMov = {}

-- Default variable for new zombies
defaultZombieMov = {
	walkSpeed = 40,
	jumpSpeed = 40,
	canJump = true,
	canJumpCheck = 0,
	
	xSpeed = 0,
	ySpeed = 0,
}

-- Dimensions
tfmDim = {w = 800, h = 400}
popupDim = {x = 10, y = 25, w = 300}
textAreaDim = {
	w = 110,
	h = 20,
	pad = 10,
	bgColour = 0x5555FF,
	brColour = 0x000000,
	alpha = 710.3
}

-- For makeLink
linksList = {}

-- Zombie info on button (for each player)
zombieInfo = {}
zombieInfo.default = {
	count = 0,
	list = "", -- String of zombie names (sperated with <br>)
	x = tfmDim.w-textAreaDim.w-textAreaDim.pad,
	y = tfmDim.h-textAreaDim.h-textAreaDim.pad,
	w = textAreaDim.w,
	h = textAreaDim.h,
	entryH = 10
}

-- Start
function startApocalypse()
	fillMiceList() -- Fill mice list
	
	-- zombieJump timer (for later use
	zombieJumpTimer = {
		id = "zombieJumpTimer",
		speed = timF.toMills(0.5),
		funt = resetJump,
	}
	
	movZombiesTimer = {				-- Timer that moves zombies according to captins
		id = "moveZombiesTimer",	-- Timer id
		speed = timF.toMills(0.5),	-- How often it will be called
		funct = checkCaptinsMove	-- Which function to call
	}
	timF.addTimer(movZombiesTimer.id, movZombiesTimer.speed, movZombiesTimer.funct, true) -- Add the timer
end

-- --

-- Events --

-- Occurs about every 605 seconds
function eventLoop (currentTime, timeRemaining)
	timF.interval()
end

-- When player joins the room
function eventNewPlayer (player)
	sortPlayer(player)
end

-- When player leaves the room
function eventPlayerLeft (player)
	nullPlayer(player)
end

-- Callback from textArea click
function eventTextAreaCallback (textAreaId, player, callback)
	if (textAreaId == idList.newZombie) then
		newZombieClick(player, callback)
	end
end

-- When player answers popup
function eventPopupAnswer (popupId, player, answer)
	if (popupId == idList.whoToZombify) then
		makeZombieAnswer(player, answer)
	end
end

-- When (binded captin) player presses buttons
function eventKeyboard (player, keyCode, down, xPlayerPosition, yPlayerPosition)
	keyPressed(player, keyCode, down)
end

-- --

-- Captin Control --

-- When captin presses a binded key
function keyPressed (player, keyCode, down)
	for direction, value in pairs(keys) do -- Check every key in "keys" table
		if (value == keyCode) then -- If match
			captinMov[player][direction] = down -- Record movements
			
			-- Move once on press
			moveZombies (player, direction, down)
		end
	end
end

-- Check if captin is moving
function checkCaptinsMove ()
	-- Move zombies if needed
	for player in pairs(miceList) do -- For every mouse in miceList
		status = miceList[player].status -- Check their status
		if (status == playerIs.captin) then -- If mouse is captin
			for direction in pairs(directions) do -- For all keys in "directions" table
				moving = captinMov[player][direction] -- If captin is moving in this direction
				moveZombies(player, direction, moving) -- Move zombies accordingly
			end
		end
	end
end

-- --

-- Zombie Control --

-- Move zombies towards direction
function moveZombies (player, direction, moving)
	zombies = miceList[player].zombies -- List of players zombies
	if (zombies == nil) then return end -- If no zombies, return without doing anything
	
	for zombie, controlled in pairs(zombies) do -- For every zombie
		if (controlled) then -- If zombie should be controlled
			if (moving) then
				moveZombie(zombie, direction) -- Move zombie if captin moving
			else
				stopZombie(zombie, direction) -- Else stop zombie
			end
		end
	end
end

-- Move single zombie
function moveZombie (zombie, direction)
	-- Movement info
	walkSpeed = zombieMov[zombie].walkSpeed
	jumpSpeed = zombieMov[zombie].jumpSpeed
	canJump = zombieMov[zombie].canJump
	xSpeed = zombieMov[zombie].xSpeed
	ySpeed = zombieMov[zombie].ySpeed
	
	-- Check direction
	if (direction == "Left") then
		xSpeed = -walkSpeed
	elseif (direction == "Right") then
		xSpeed = walkSpeed
	elseif (direction == "Up" and canJump) then
		ySpeed = -jumpSpeed
		zombieMov[zombie].canJump = false
		timF.addTimer(zombieJumpTimer.id, zombieJumpTimer.speed, zombieJumpTimer.funt, true, zombie) -- resetJump
	elseif (direction == "Down") then
		ySpeed = jumpSpeed
	end
	
	if (xSpeed ~= 0 or ySpeed ~= 0) then
		tfm.exec.movePlayer(zombie, 0, 0, true, xSpeed, ySpeed, false)
	end
end

-- Stop zombie from moving
function stopZombie (zombie, direction)
	vx = tfm.get.room.playerList[zombie].vx
	vy = tfm.get.room.playerList[zombie].vy
	
	if (direction == "Left" or direction == "Right") then -- If left or right, stop x
		xSpeed = 1
	elseif (direction == "Up" or direction == "Down") then -- If up or down, stop y
		ySpeed = 1
	end

	if (xSpeed ~= 0 and ySpeed ~= 0) then
		tfm.exec.movePlayer(zombie, 0, 0, true, xSpeed, ySpeed, false)
	end
end

-- Reset jump variable
function resetJump (zombie)
	check = zombieMov[zombie].canJumpCheck + 1
	owner = miceList[zombie].owner
	inAir = tfm.get.room.playerList[owner].isJumping
	
	if (not inAir or check >= 3) then -- If captin isn't in air, or tried 3 times
		zombieMov[zombie].canJump = true
		zombieMov[zombie].canJumpCheck = 0
	else
		zombieMov[zombie].canJumpCheck = check
	end
end

-- --

-- Setup --

-- Fill mice list (and set captins accordingly)
function fillMiceList ()
	miceInRoom = tfm.get.room.playerList -- List of players in room
	
	for player in pairs(miceInRoom) do -- For every player in room
		sortPlayer(player) -- Make captin if they should be
	end
end

-- Check if player should be captin and set them accordingly
function sortPlayer (player)
	miceList[player] = {} -- Table to store info about player
	
	for captin, shouldBeCaptin in pairs(makeCaptins) do -- For every captinToBe
		if (player == captin and shouldBeCaptin) then -- If the mouse should be captin
			makeCaptin(player) -- Make them a captin
			break
		else
			miceList[player].status = playerIs.inRoom -- Or else, just set them as default
		end
	end
end

--

-- Set player --

-- Make player a captin
function makeCaptin (player)
	miceList[player].status = playerIs.captin -- Set player status to captin
	miceList[player].zombies = {} -- List of zombies

	bindKeyboard(player, true) -- Bind keyboard
	captinMov[player] = {} -- Keep track of movements

	newZombieButton(player) -- Button to make new zombies
end

-- Make player a zombie
function makeZombie (captin, player)
	miceList[player].status = playerIs.zombie -- Set target status to zombie
	miceList[captin].zombies[player] = true -- Add target to captin's list
	miceList[player].owner = captin -- Makes note of who controls player
	
	-- Make new movement table for this zombie
	zombieMov[player] = {
		walkSpeed = defaultZombieMov.walkSpeed,
		jumpSpeed = defaultZombieMov.jumpSpeed,
		canJump = defaultZombieMov.canJump,
		canJumpCheck = defaultZombieMov.canJumpCheck,
		
		xSpeed = defaultZombieMov.xSpeed,
		ySpeed = defaultZombieMov.ySpeed,
	}
	
	addZombieToList(captin, player) -- Add to visual list
end

-- Removes player from all lists and such
function nullPlayer (player)
	status = miceList[player].status -- Players current status

	if (status == playerIs.captin) then -- If captin
		bindKeyboard(player, false) -- Unbind keyboard
		miceList[player].zombies = nil -- Remove list of zombies
		captinMov[player] = nil -- Remove table of movement

	elseif (status == playerIs.zombie) then -- If zombie
		owner = miceList[player].owner -- Owner name
		miceList[owner].zombies[player] = nil -- Remove from owners list
		miceList[player].owner = nil -- Remove note of owner
		zombieMov[player] = nil -- Remove table of movement
		
	end
	miceList[player].status = playerIs.inRoom -- Set status to default
	miceList[player] = nil -- Null player from list
end

-- Toggles keyboard binding of player for all keys in "keys" table
function bindKeyboard (player, toggle)
	keys = keys -- Global keys table
	for key, value in pairs(keys) do -- For all keys in "keys" table
		-- Player, keyCode, keyDown, toggle
		tfm.exec.bindKeyboard(player, value, true, toggle) -- Keydown
		tfm.exec.bindKeyboard(player, value, false, toggle) -- Keyup
	end
end

--

-- Gui's --

-- New button for making new zombies
function newZombieButton (player)
	def = zombieInfo.default
	zombieInfo[player] = {
		count = def.count,
		list = def.list,
		x = def.x,
		y = def.y,
		w = def.w,
		h = def.h,
		entryH = def.entryH,
		
		link = makeLink("Create new Zombie", "makeZombiePop", player)
	}
	
	z = zombieInfo[player]

	ui.addTextArea(idList.newZombie, z.link .. z.list, player, z.x, z.y, z.w, z.h, textAreaDim.bgColour, textAreaDim.brColour, textAreaDim.alpha)
end

-- Add a list of zombies below button for making zombies
function addZombieToList (player, zombie)
	z = zombieInfo[player] -- For quick use

	-- Add zombie to list
	zombieInfo[player].list = z.list .. "<br>" .. zombie
	
	-- Count + 1, and alter height and x
	zombieInfo[player].count = z.count + 1
	zombieInfo[player].y = z.y - z.entryH
	zombieInfo[player].h = z.h + z.entryH
	
	z = zombieInfo[player] -- For quick use
	
	ui.removeTextArea(idList.newZombie, player)
	ui.addTextArea(idList.newZombie, z.link .. z.list, player, z.x, z.y, z.w, z.h, textAreaDim.bgColour, textAreaDim.brColour, textAreaDim.alpha)
end

-- When newZombieButton is clicked
function newZombieClick (player, callback)
	param = linksList[callback]
	runGlobal(callback,param)
end

-- Popup asking who to zombify
function makeZombiePop (player)
	x = popupDim.x
	y = popupDim.y
	w = popupDim.w
	ui.addPopup(idList.whoToZombify, 2, "Who do you want to zombify, " .. player .. "?", player, x, y, w)
end

-- When player answers zombify popup
function makeZombieAnswer (player, answer)
	-- Target name
	target = tostring(answer)

	-- If answer is blank
	if (target == "" or target == nil) then
		return false
	end
	
	-- If target is not in room
	if (miceList[target] == nil) then
		infoPop(player, "Oops.. I can't find \"" .. target .. "\" :s")
		return false
	end
	
	-- Target status
	targetStates = miceList[target].status
	
	-- Set target according to status
	if (targetStates == playerIs.inRoom) then -- If target player is in the room (but not affected)
		makeZombie(player, target) -- Make it a zombie under your control
		infoPop(player, "Woo! " .. target .. " is now a zombie! ^,.,^")
		infoPop(target, "Uh oh O_o")		
	elseif (targetStates == playerIs.zombie) then
		infoPop(player, "Oops.. " .. target .. " is already a zombie! O_o")
	elseif (targetStates == playerIs.captin) then
		infoPop(player, "Oops.. " .. target .. " is too strong.. O_o")
	else
		infoPop(player, "Oops.. I'm confused :s")
	end
end

-- Popup with information
function infoPop (player, msg)
	x = popupDim.x
	y = popupDim.y
	w = popupDim.w
	ui.addPopup(idList.infoPop, 0, msg, player, x, y, w)
end

--

-- Tools --

-- Make link and store info in global linksList table (for use with textArea callbacks)
function makeLink (text, callback, param)
	-- Stores param(s) in list (Send them as tables to store more)
	linksList[callback] = param
	
	-- <a href="event:callback">text</a>
	return ""
	.. "<a href=\"event:"
	.. tostring(callback)
	.. "\">"
	.. tostring(text)
	.. "</a>"
end

function runGlobal (funct, param)
	_G[funct](param)
end

function globalFunct (funct)
	return _G[funct]
end

-- --

-- Timer Code --
--[[
Short version of timer.lua, meant for copying
Notes:
Add "timF.interval()" in "eventLoop" function body !
Example use: timF.addTimer("id", timF.toMills(sec), funct)
]]--
timers = {}
timers.functions = {}
--
function timers.initialize()
	timers = timers
	timers.time = 0				-- Current time (Milliseconds since start of script)
	timers.timerList = {}		-- List of timers
	timers.nilId = "makeNil"	-- Id to make nil
	_G.timF = timers.functions -- Short
end
--
function timers.functions.interval ()
	timers.time = timers.time + 605			-- Increase time variable manually
	for key,value in pairs(timers.timerList) do	-- Scan through all timers
		if (value == timers.nilId) then -- If timer should be nil
			key = nil -- Make nil
		else
			timers.functions.checkTimer(key)	-- Check the timer
		end
	end
end
--
function timers.functions.checkTimer (id)
	startTime = timers.timerList[id].startTime
	delay = timers.timerList[id].delay
	funct = timers.timerList[id].funct
	param = timers.timerList[id].param
	loop = timers.timerList[id].loop
	if (timers.time >= startTime+delay) then				-- Delay has passed
		if (loop) then										-- If timer should loop
			timers.timerList[id].startTime = timers.time	-- Reset time
		else
			timers.functions.removeTimer(id)				-- Else, remove timer from list
		end
		if (type(funct) == "function") then	-- If function exists, call it
			if (param ~= nil) then
				funct(param)
			else
				funct()
			end
			return true
		else -- Function doesn't exist
			return false -- Failed
		end
	end
end
--
function timers.functions.addTimer (id, delay, funct)
	timers.functions.addTimer (id, delay, funct, false)
end
function timers.functions.addTimer (id, delay, funct, loop)
	timers.functions.addTimer (id, delay, funct, false, nil)
end
function timers.functions.addTimer (id, delay, funct, loop, param)
	timers.timerList[id] = {
		startTime = timers.time,	-- Starting time (now)
		delay = delay,			-- Delay this long before activate
		funct = funct,			-- Call this function when done
		param = param,			-- Parameters to send to function
		loop = loop				-- If timer should loop
	}
end
--
function timers.functions.removeTimer (id)
	timers.timerList[id] = "makeNil"
end
--
function timers.functions.toMills (num)
	return num*1000
end
timers.initialize()

-- End of timer code --

-- Ternary
function tern (cond, T, F)
	if cond then return T else return F end
end

--

startApocalypse()

