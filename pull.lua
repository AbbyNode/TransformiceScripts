--[[
pull
Pulls mice and things when clicked
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

-- --

-- Events --

-- When someone dies
function eventPlayerDied (player)
	stopPull(player)
	pullPop(player)
end

-- When someone does an emote
function eventEmotePlayed (player, emoteId)
	if (emoteId == 9) then
		pullPop(player)
	end
end

-- When player answers popup
function eventPopupAnswer (popupId, player, answer)
	if (popupId == 0) then pullAnswer(player, answer)
	end
end

-- When (binded) player clicks mouse
function eventMouse (player, xMousePosition, yMousePosition)
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
	system.bindMouse(player, no)
	saidYes[player] = 0
end

-- --
