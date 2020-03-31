local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local Autoplay		= require("sphere.screen.gameplay.LogicEngine.Autoplay")

local Score = Class:new()

Score.send = function(self, event)
	return self.observable:send(event)
end

Score.construct = function(self)
	self.observable = Observable:new()

	self.combo = 0
	self.maxcombo = 0
	self.timeRate = 1
	self.hits = {}
	self.judges = {}
	
	self.sum = 0
	self.count = 0
	self.accuracy = 0
	self.timegate = ""
	self.grade = "?"
	
	self.score = 0
end

Score.passEdge = 0.120
Score.missEdge = 0.160
Score.getTimeState = function(self, deltaTime)
	local deltaTime = deltaTime / self.timeRate

	if math.abs(deltaTime) <= self.passEdge then
		return "exactly"
	elseif deltaTime > self.passEdge then
		return "late"
	elseif deltaTime >= -self.missEdge then
		return "early"
	end
	
	return "none"
end

Score.needAutoplay = function(self, note)
	return
		self.autoplay or
		note.noteType == "SoundNote" or
		note.startNoteData.autoplay or
		note.autoplay
end

Score.processNote = function(self, note)
	if note.ended then
		return
	end
	
	if self:needAutoplay(note) then
		return Autoplay:processNote(note)
	elseif note.noteType == "ShortNote" then
		return self:processShortNote(note)
	elseif note.noteType == "LongNote" then
		return self:processLongNote(note)
	end
end

return Score
