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

	self.maxScore = self:getMaxScore()
end

ScoreEngine.update = function(self, dt)
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

	-- if not event.virtual then
	-- 	return
	-- end

	-- for noteHandler in pairs(self.noteHandlers) do
	-- 	noteHandler:receive(event)
	-- end
end

ScoreEngine.getScoreNote = function(self, noteData)
	return self.scoreEngine.sharedScoreNotes[noteData]
end

ScoreEngine.getMaxScore = function(self)
	local score = 0
	local scoreNotes = self.noteHandler.scoreNotes
	for i = 1, #scoreNotes do
		score = score + scoreNotes[i]:getMaxScore()
	end
	return score
end

return ScoreEngine
