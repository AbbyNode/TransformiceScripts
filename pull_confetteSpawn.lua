--[[
Combination of pull and confetteSpawn

Pulls mice and things when clicked
Spawns item when confette'd
]]--

-- Variables --

saidYes = {}	-- Table to store player's answer

-- Dimensions
popupDim = {x = 10, y = 25, w = 200}

pull = {}
pull.gap = 20
pull.power = 15
pull.radius = 200
pull.ghost = "yes"

confette = {}
confette.item = 39		-- Item to throw (6 = ball, 39 = apple)
confette.defSpeed = 10	-- Speed of throw
confette.height = 5		-- Height of throw
confette.defAngle = 90	-- Angle of item
confette.defOffset = 30	-- In front of mouse

-- --

-- Events --

-- When someone dies
function eventPlayerDied (player)
	stopPull (player)
	pullPop (player)
end

-- When someone does an emote
function eventEmotePlayed (player, emoteId)
	if (emoteId == 9) then
		pullPop (player)
		throwConfette (player, confette.item)
	elseif (emoteId == 5) then
		throwConfette(player, 17, true)
	end
end

-- When player answers popup
function eventPopupAnswer(popupId, player, answer)
	if (popupId == 0) then pullAnswer(player, answer)
	end
end

-- When (binded) player clicks mouse
function eventMouse(player, xMousePosition, yMousePosition)
	pullMouse(player, xMousePosition, yMousePosition)
end

-- --

-- Functions --

-- Popup asking player for pull
function pullPop (player)
	if (saidYes[player] ~= 1) then
		ui.addPopup(0, 1, "Hey " .. player .. "!\nWanna have some fun? ^_^", player, popupDim.x, popupDim.y, popupDim.w)
	end
end

-- When player answers popup for pull
function pullAnswer (player, answer)
	if (answer == "yes") then
		system.bindMouse(player, yes)
		saidYes[player] = 1
	end
end

-- Pull to mouseclick
function pullMouse (player, x, y)
	if (saidYes[player] == 0) then return end
	
	-- Arrows
	tfm.exec.addShamanObject(0, x, y-pull.gap, 0, 1, 1, pull.ghost)
	tfm.exec.addShamanObject(0, x+pull.gap, y, 90, 1, 1, pull.ghost)
	tfm.exec.addShamanObject(0, x, y+pull.gap, 180, 1, 1, pull.ghost)
	tfm.exec.addShamanObject(0, x-pull.gap, y, 270, 1, 1, pull.ghost)

	-- Inward spirit (pulls)
	tfm.exec.explosion(x, y, -pull.power, pull.radius, no)
end

-- Disable pull
function stopPull (player)
	saidYes[player] = 0
end

--

-- Throw item on confette
function throwConfette (player, item, ghost)
	-- Player values
	t = tfm.get.room.playerList[player]
	vx = t["vx"] -- Velocity x
	vy = t["vy"] -- Velocity y
	jump = t["isJumping"]
	movLeft = t["movingLeft"]
	movRight = t["movingRight"]
	adj = 15 -- Adjustment
	x = t["x"] + vx + tern(movLeft, -adj, 0) + tern(movRight, adj, 0)
	y = t["y"] + vy + tern(jump, -adj, 0)
	faceRight = t["isFacingRight"]
	
	-- Check which side to throw depending on faceRight
	angle = tern(faceRight, confette.defAngle, -confette.defAngle)
	speed = tern(faceRight, confette.defSpeed, -confette.defSpeed)
	offset = tern(faceRight, confette.defOffset, -confette.defOffset)
	height = -confette.height
	
	-- Throw item
	tfm.exec.addShamanObject(item, x+offset, y, angle, speed, height, ghost)
end

-- Ternary
function tern (cond, T, F)
	if cond then return T else return F end
end

-- Short tostring
function tostr(str) return tostring(str) end

-- --
