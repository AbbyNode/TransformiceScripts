--[[
confetteSpawn
Spawns item when confette'd
]]--

-- Variables --

confette = {}
confette.item = 39		-- Item to throw (6 = ball, 39 = apple)
confette.defSpeed = 10	-- Speed of throw
confette.height = 5		-- Height of throw
confette.defAngle = 90	-- Angle of item
confette.defOffset = 30	-- In front of mouse

-- --

-- Events --

-- When someone does an emote
function eventEmotePlayed (player, emoteId)
	if (emoteId == 9) then
		throwConfette (player, confette.item)
	elseif (emoteId == 5) then
		throwConfette(player, 17, true)
	end
end

-- --

-- Functions --

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

--

-- Ternary
function tern (cond, T, F)
	if cond then return T else return F end
end

-- Short tostring
function tostr(str) return tostring(str) end

-- --