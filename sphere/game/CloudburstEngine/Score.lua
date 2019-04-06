local Class = require("aqua.util.Class")

local Autoplay = require("sphere.game.CloudburstEngine.Autoplay")

local Score = Class:new()

Score.construct = function(self)
	self.combo = 0
	self.maxcombo = 0
	self.rate = 1
	self.hits = {}
	self.judges = {}
end

Score.passEdge = 0.120
Score.missEdge = 0.160
Score.getTimeState = function(self, deltaTime)
	if math.abs(deltaTime) <= self.passEdge then
		return "exactly"
	elseif deltaTime > self.passEdge then
		return "late"
	elseif deltaTime >= -self.missEdge then
		return "early"
	end
	
	return "none"
end

Score.timegates = {
	{
		time = 0.120,
		name = "great"
	},
	{
		time = 0.160,
		name = "miss"
	}
}

Score.interval = 0.004
Score.hit = function(self, deltaTime)
	if math.abs(deltaTime) <= self.passEdge then
		deltaTime = math.floor(deltaTime / self.interval) * self.interval
		self.hits[deltaTime] = (self.hits[deltaTime] or 0) + 1
	end
	
	local judgeIndex = self:judge(deltaTime)
	self.judges[judgeIndex] = (self.judges[judgeIndex] or 0) + 1
end

Score.judge = function(self, deltaTime)
	local deltaTime = math.abs(deltaTime)
	for i = 1, #self.timegates do
		if deltaTime <= self.timegates[i].time then
			return i
		end
	end
	return #self.timegates
end

Score.needAutoplay = function(self, note)
	return note.noteType == "SoundNote" or note.engine.autoplay
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

Score.processShortNote = function(self, note)
	local deltaTime = (note.engine.exactCurrentTime - note.startNoteData.timePoint:getAbsoluteTime()) / self.rate
	local timeState = self:getTimeState(deltaTime)
	
	note:process(timeState)
	self:processShortNoteState(note.state)
	
	if note.ended then
		self:hit(deltaTime)
	end
end

Score.processLongNote = function(self, note)
	local deltaStartTime = (note.engine.exactCurrentTime - note.startNoteData.timePoint:getAbsoluteTime()) / self.rate
	local deltaEndTime = (note.engine.exactCurrentTime - note.endNoteData.timePoint:getAbsoluteTime()) / self.rate
	local startTimeState = self:getTimeState(deltaStartTime)
	local endTimeState = self:getTimeState(deltaEndTime)
	
	local oldState = note.state
	note:process(startTimeState, endTimeState)
	self:processLongNoteState(note.state, oldState)
	
	if note.started and not note.judged then
		self:hit(deltaStartTime)
		note.judged = true
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
