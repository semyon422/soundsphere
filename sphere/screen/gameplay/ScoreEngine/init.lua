local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteHandler		= require("sphere.screen.gameplay.ScoreEngine.NoteHandler")
local ScoreSystem		= require("sphere.screen.gameplay.ScoreEngine.ScoreSystem")
local ScoreNoteFactory	= require("sphere.screen.gameplay.ScoreEngine.ScoreNoteFactory")

local ScoreEngine = Class:new()

ScoreEngine.construct = function(self)
	self.observable = Observable:new()
end

ScoreEngine.load = function(self)
	self.scoreSystem = ScoreSystem:new()
	self.scoreSystem:loadConfig("score.json")
	
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
	return self.sharedScoreNotes[noteData]
end

return ScoreEngine
