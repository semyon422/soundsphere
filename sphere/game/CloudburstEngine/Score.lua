local Class = require("aqua.util.Class")
local AudioManager = require("aqua.audio.AudioManager")

local Autoplay = require("sphere.game.CloudburstEngine.Autoplay")

local Score = Class:new()

Score.construct = function(self)
	self.combo = 0
	self.maxcombo = 0
	self.rate = 1
	self.hits = {}
end

local passEdge = 0.120
local missEdge = 0.160
Score.getTimeState = function(self, deltaTime)
	if deltaTime + passEdge < 0 then
		return "late"
	elseif math.abs(deltaTime) - passEdge <= 0 then
		return "exactly"
	elseif deltaTime - passEdge > 0 and deltaTime - missEdge <= 0 then
		return "early"
	else
		return "none"
	end
end

local interval = 0.004
Score.hit = function(self, deltaTime)
	deltaTime = math.floor(deltaTime / interval) * interval
	self.hits[deltaTime] = (self.hits[deltaTime] or 0) + 1
end

Score.needAutoplay = function(self, note)
	return note.noteType == "SoundNote" or note.engine.autoplay
end

Score.processNote = function(self, note)
	if note.ended then
		return
	end
	
	if self:needAutoplay(note) then
		Autoplay:processNote(note)
	elseif note.noteType == "ShortNote" then
		self:processShortNote(note)
	elseif note.noteType == "LongNote" then
		self:processLongNote(note)
	end
end

Score.processShortNote = function(self, note)
	local deltaTime = (note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime) / self.rate
	local timeState = self:getTimeState(deltaTime)
	
	note:process(timeState)
	self:processShortNoteState(note.state)
	
	if note.ended then
		self:hit(deltaTime)
	end
end

Score.processLongNote = function(self, note)
	local deltaStartTime = (note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime) / self.rate
	local deltaEndTime = (note.endNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime) / self.rate
	local startTimeState = self:getTimeState(deltaStartTime)
	local endTimeState = self:getTimeState(deltaEndTime)
	
	local oldState = note.state
	note:process(startTimeState, endTimeState)
	self:processLongNoteState(note.state, oldState)
	
	if note.started then
		self:hit(deltaStartTime)
		note.started = false
	end
	if note.ended then
		self:hit(deltaEndTime)
	end
end

Score.processShortNoteState = function(self, newState)
	if newState == "skipped" or newState == "clear" then
		return
	end
	if newState == "passed" then
		self.combo = self.combo + 1
		self.maxcombo = math.max(self.combo, self.maxcombo)
	elseif newState == "missed" then
		self.combo = 0
	end
end

Score.processLongNoteState = function(self, newState, oldState)
	if newState == "skipped" then
		return
	end
	if oldState == "clear" and newState == "startPassedPressed" then
		self.combo = self.combo + 1
		self.maxcombo = math.max(self.combo, self.maxcombo)
	elseif (
		(oldState == "clear" or oldState == "startPassedPressed") and (
			newState == "startMissed" or
			newState == "startMissedPressed" or
			newState == "endMissed"
		)
	) then
		self.combo = 0
	end
end

return Score
