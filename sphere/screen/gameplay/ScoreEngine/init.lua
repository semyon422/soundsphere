local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local NoteHandler	= require("sphere.screen.gameplay.ScoreEngine.NoteHandler")
local Score			= require("sphere.screen.gameplay.ScoreEngine.Score")

local ScoreEngine = Class:new()

ScoreEngine.load = function(self)
	self.observable = Observable:new()

	self.score = Score:new()
	self.score.noteChart = self.noteChart
	self.score.scoreEngine = self
	
	self.sharedScoreNotes = {}
	self.currentTime = 0
	self.timeRate = 1
	
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
	return self.scoreEngine.sharedScoreNotes[noteData]
end

return ScoreEngine
