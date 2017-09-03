--[[
colourNames
Flashing coloured names
]]--

--[[
timer
Functions for making timers in Transformice
]]--

-- -- Code for timer --

-- Variables --

time = 0			-- Current time (Milliseconds since start of script)
timerList = {}		-- List of timers
timerListCount = 0	-- Number of timers in list

-- --

-- Events --

-- Occurs every 605 seconds
function eventLoop (currentTime, timeRemaining)
	time = time + 605 -- Increase time variable manually
	if (next(timerList) ~= nil) then -- If there are more timers in list
		for key,value in pairs(timerList) do -- Scan through all timers
			checkTimer(key) -- Check the timer
			if (timerListCount <= 0) then -- No more timers in list, don't continue
				break
			end
		end
	end
end

-- --

-- Functions --

-- Add a timer (String id, Int delay, Function funct) Delay in milliseconds
function addTimer (id, delay, funct)
	timerList[id] = {
		startTime = time,	-- Starting time (now)
		delay = delay,		-- Delay this long before activate
		funct = funct		-- Call this function when done
	}
	timerListCount = timerListCount + 1	-- Add 1 to list count
end

-- Checks if timer is over (Called by eventLoop)
function checkTimer (id)
	startTime = timerList[id].startTime
	delay = timerList[id].delay
	funct = timerList[id].funct
	
	if (time >= startTime+delay) then -- Delay has passed
		removeTimer(id) -- Remove timer from list
		if (type(funct) == "function") then -- If function exists, call it
			funct()
			return true -- Worked
		else
			return false -- Failed
		end
	end
end

-- Removes timer from timerList
function removeTimer (id)
	timerList[id] = nil
	timerListCount = timerListCount -1
end

-- Seconds to milliseconds
function toMills (num)
	return num*1000
end

-- --

-- -- Code for colourNames --

-- List of colours
colours = {}
colours[1] = 0xFF5555
colours[2] = 0x55FF55
colours[3] = 0x5555FF
colours[4] = 0x401673
colours[5] = 0x7124B2

-- Counter and max
colourSelector = 1
maxColours = 5

-- Change colour of mice to next in list
function changeColour()
	-- Counter
	colourSelector = colourSelector +1
	if (colourSelector >= maxColours) then colourSelector = 1 end
	
	-- Next colour
	colour = colours[colourSelector]
	
	-- Colour all mice
	miceInRoom = tfm.get.room.playerList -- List of players in room
	for mouse, unused in pairs(miceInRoom) do -- For every player in room
		tfm.exec.setNameColor(mouse, colour)
	end
	
	-- Start timer again
	addTimer("colourId", toMills(1), changeColour)
end

-- Start timer first time
addTimer("colourId", toMills(1), changeColour)

-- --
