local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteHandler		= require("sphere.models.RhythmModel.ScoreEngine.NoteHandler")
local ScoreSystemContainer	= require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")

local ScoreEngine = Class:new()

ScoreEngine.construct = function(self)
	self.observable = Observable:new()
	self.scoreSystem = ScoreSystemContainer:new()
end

ScoreEngine.load = function(self)
	local scoreSystem = self.scoreSystem
	scoreSystem.scoreEngine = self

	self.inputMode = self.noteChart.inputMode:getString()
	self.baseTimeRate = self.timeEngine:getBaseTimeRate()

	self.sharedScoreNotes = {}
	self.currentTime = 0
	self.timeRate = 1

	self.minTime = self.noteChart.metaData:get("minTime")
	self.maxTime = self.noteChart.metaData:get("maxTime")

	self.noteHandler = NoteHandler:new()
	self.noteHandler.scoreEngine = self
	self.noteHandler:load()
end

ScoreEngine.update = function(self)
	self.noteHandler:update()
end

ScoreEngine.unload = function(self)
	self.noteHandler:unload()
end

ScoreEngine.send = function(self, event)
	return self.observable:send(event)
end

ScoreEngine.receive = function(self, event)
	if event.name == "TimeState" then
		self.currentTime = event.exactCurrentTime
		self.timeRate = event.timeRate
	end
end

ScoreEngine.getScoreNote = function(self, noteData)
	return self.sharedScoreNotes[noteData]
end

return ScoreEngine
