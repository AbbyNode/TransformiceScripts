--[[
emoteDisplay
Display's message of what emote someone did
]]--

-- Variables --

emotes = {}
emotes["0"] = "dance"
emotes["1"] = "laugh"
emotes["2"] = "cry"
emotes["3"] = "kiss"
emotes["4"] = "rage"
emotes["5"] = "clap"
emotes["6"] = "sleep"
emotes["7"] = "facepalm"
emotes["8"] = "sit"
emotes["9"] = "confette"

-- --

-- Events --

-- When player does emote
function eventEmotePlayed(player, emoteId)
	printEmote(player, emoteId)
end

-- --

-- Functions --

-- Prints name of player and emote
function printEmote(player, emoteId)
	print (player .. " did " .. emoteName(emoteId))
end

-- Returns emote name
function emoteName(emoteId)
	return emotes[tostring(emoteId)]
end

-- --