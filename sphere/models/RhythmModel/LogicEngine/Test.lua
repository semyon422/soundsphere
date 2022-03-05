
local LogicEngine = require("sphere.models.RhythmModel.LogicEngine")
local inspect = require("inspect")

local NoteChart		= require("ncdk.NoteChart")
local VelocityData	= require("ncdk.VelocityData")
local NoteData		= require("ncdk.NoteData")

local rhythmModel = {}

local logicEngine = LogicEngine:new()
rhythmModel.logicEngine = logicEngine
logicEngine.rhythmModel = rhythmModel

local timeEngine = {
	currentTime = 0,
	timeRate = 1,
	inputOffset = 0,
}
rhythmModel.timeEngine = timeEngine

logicEngine.timings = {
	normalscore = 0.1,
	ShortScoreNote = {
		hit = {-0.1, 0.1},
		miss = {-0.2, 0.2}
	},
	LongScoreNote = {
		startHit = {-0.1, 0.1},
		startMiss = {-0.2, 0.2},
		endHit = {-0.1, 0.1},
		endMiss = {-0.2, 0.2}
	}
}

local function test(notes, events, states)
	local noteChart = NoteChart:new()

	local layerData = noteChart.layerDataSequence:requireLayerData(1)
	layerData:setTimeMode("absolute")

	noteChart.inputMode:setInputCount("key", 1)

	do
		local timePoint = layerData:getTimePoint(
			0, -- absoluteTime in absolute mode
			-1 -- side, doesn't affect anything in absolute mode
		)

		local velocityData = VelocityData:new(timePoint)
		velocityData.currentVelocity = 1
		layerData:addVelocityData(velocityData)
	end

	for _, time in ipairs(notes) do
		if type(time) == "number" then
			local timePoint = layerData:getTimePoint(time, -1)

			local noteData = NoteData:new(timePoint)
			noteData.inputType = "key"
			noteData.inputIndex = 1

			noteData.noteType = "ShortNote"

			layerData:addNoteData(noteData)
		elseif type(time) == "table" then
			local timePoint = layerData:getTimePoint(time[1], -1)

			local startNoteData = NoteData:new(timePoint)
			startNoteData.inputType = "key"
			startNoteData.inputIndex = 1
			startNoteData.noteType = "LongNoteStart"
			layerData:addNoteData(startNoteData)

			timePoint = layerData:getTimePoint(time[2], -1)

			local endNoteData = NoteData:new(timePoint)
			endNoteData.inputType = "key"
			endNoteData.inputIndex = 1
			endNoteData.noteType = "LongNoteEnd"
			layerData:addNoteData(endNoteData)

			startNoteData.endNoteData = endNoteData
			endNoteData.startNoteData = startNoteData
		end
	end

	noteChart:compute()

	logicEngine.noteChart = noteChart

	local newStates = {}
	rhythmModel.scoreEngine = {
		send = function(self, event)
			-- print(inspect({
			-- 	currentTime = event.currentTime,
			-- 	newState = event.newState,
			-- 	noteEndTime = event.noteEndTime,
			-- 	noteStartTime = event.noteStartTime,
			-- 	noteType = event.noteType,
			-- 	oldState = event.oldState,
			-- }))
			table.insert(newStates, event)
		end,
		scoreSystem = {receive = function(self, event) end},
	}

	logicEngine:load()

	local function press(time)
		logicEngine:receive({
			"key1",
			name = "keypressed",
			virtual = true,
			time = time
		})
	end
	local function release(time)
		logicEngine:receive({
			"key1",
			name = "keyreleased",
			virtual = true,
			time = time
		})
	end
	local function update(time)
		logicEngine:update()
	end

	for _, event in ipairs(events) do
		local time = event[1]
		for char in event[2]:gmatch(".") do
			if char == "p" then
				press(time)
			elseif char == "r" then
				release(time)
			elseif char == "u" then
				update(time)
			elseif char == "t" then
				timeEngine.currentTime = time
			end
		end
	end

	if not states then return end
	assert(#states == #newStates)
	for i, event in ipairs(newStates) do
		assert(event.currentTime == states[i][1])
		assert(event.oldState == states[i][2])
		assert(event.newState == states[i][3])
	end
end

test(
	{0},
	{
		{1, "tu"},
	},
	{
		{0.2, "clear", "missed"},
	}
)

test(
	{{0, 1}},
	{
		{2, "tu"},
	},
	{
		{0.2, "clear", "startMissed"},
		{1.2, "startMissed", "endMissed"},
	}
)

test(
	{{0, 1}, 1},
	{
		{1, "p"},
	},
	{
		{0.2, "clear", "startMissed"},
		{1, "startMissed", "endMissed"},
		{1, "clear", "passed"},
	}
)
