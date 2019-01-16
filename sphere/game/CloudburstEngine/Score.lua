local Class = require("aqua.util.Class")
local AudioManager = require("aqua.audio.AudioManager")

local Autoplay = require("sphere.game.CloudburstEngine.Autoplay")

local Score = Class:new()

Score.construct = function(self)
	self.combo = 0
	self.maxcombo = 0
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

Score.needAutoplay = function(self, note)
	return note.noteType == "SoundNote" or note.engine.autoplay
end

Score.processNote = function(self, note)
	if note.ended then
		return
	end
	
	local oldState = note.state
	if self:needAutoplay(note) then
		Autoplay:processNote(note)
	elseif note.noteType == "ShortNote" then
		self:processShortNote(note)
	elseif note.noteType == "LongNote" then
		self:processLongNote(note)
	end
	self:processState(note.state, oldState)
end

Score.processShortNote = function(self, note)
	local deltaTime = note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	local timeState = self:getTimeState(deltaTime)
	
	return note:process(timeState)
end

Score.processLongNote = function(self, note)
	local deltaStartTime = note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	local deltaEndTime = note.endNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	local startTimeState = self:getTimeState(deltaStartTime)
	local endTimeState = self:getTimeState(deltaEndTime)
	
	return note:process(startTimeState, endTimeState)
end

Score.processState = function(self, newState, oldState)
	if newState == "skipped" then
		return
	end
	if oldState == "clear" and (
		newState == "passed" or
		newState == "startPassedPressed"
	) then
		self.combo = self.combo + 1
		self.maxcombo = math.max(self.combo, self.maxcombo)
	elseif (
		(oldState == "clear" or oldState == "startPassedPressed") and (
			newState == "missed" or
			newState == "startMissed" or
			newState == "startMissedPressed" or
			newState == "endMissed"
		)
	) then
		self.combo = 0
	end
end

return Score
