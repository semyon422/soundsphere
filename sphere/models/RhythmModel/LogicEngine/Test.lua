
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
}
rhythmModel.timeEngine = timeEngine

rhythmModel.scoreEngine = {
	send = function(self, event) print(inspect(event)) end,
	scoreSystem = {receive = function(self, event) end},
}

logicEngine.timings = {
	normalscore = 0.12,
	ShortScoreNote = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.16}
	},
	LongScoreNote = {
		startHit = {-0.12, 0.12},
		startMiss = {-0.16, 0.16},
		endHit = {-0.12, 0.12},
		endMiss = {-0.16, 0.16}
	}
}

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


local notes = {
	0, 1, 2, 3,
}

for _, time in ipairs(notes) do
	local timePoint = layerData:getTimePoint(time, -1)

	local noteData = NoteData:new(timePoint)
	noteData.inputType = "key"
	noteData.inputIndex = 1

	-- noteData.noteType = "LongNoteStart"
	-- noteData.noteType = "LongNoteEnd"
	noteData.noteType = "ShortNote"

	layerData:addNoteData(noteData)
end

noteChart:compute()

logicEngine.noteChart = noteChart
logicEngine:load()


timeEngine.currentTime = 0
logicEngine:receive({
	"key1",
	name = "keypressed",
	virtual = true,
	time = timeEngine.currentTime
})
logicEngine:update()
timeEngine.currentTime = 1
logicEngine:receive({
	"key1",
	name = "keypressed",
	virtual = true,
	time = timeEngine.currentTime
})
