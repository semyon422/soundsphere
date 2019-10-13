local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local Autoplay		= require("sphere.screen.gameplay.CloudburstEngine.Autoplay")

local Score = Class:new()

Score.observable = Observable:new()

Score.send = function(self, event)
	return self.observable:send(event)
end

Score.construct = function(self)
	self.combo = 0
	self.maxcombo = 0
	self.rate = 1
	self.hits = {}
	self.judges = {}
	
	self.sum = 0
	self.count = 0
	self.accuracy = 0
	self.timegate = ""
	self.grade = ""
	
	self.score = 0
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

Score.grades = {
	{
		time = 0.120,
		name = "S"
	},
	{
		name = "F"
	}
}

Score.updateGrade = function(self)
	local accuracy = self.accuracy / 1000
	local grades = self.grades
	for i = 1, #grades - 1 do
		if accuracy <= grades[i].time then
			self.grade = grades[i].name
			return
		end
	end
	self.grade = grades[#grades].name
end

Score.interval = 0.004
Score.scale = 3.6
Score.unit = 1/60
Score.hit = function(self, deltaTime, time)
	self.hits[#self.hits + 1] = {time, deltaTime}
	
	local judgeIndex = self:judge(deltaTime)
	self.judges[judgeIndex] = (self.judges[judgeIndex] or 0) + 1
	
	self.count = self.count + 1
	
	self:send({
		name = "hit",
		time = time,
		deltaTime = deltaTime
	})
	
	if math.abs(deltaTime) >= self.timegates[#self.timegates - 1].time then
		self:updateAccuracy()
		return
	end
	
	-- self.count = self.count + 1
	-- self.sum = self.sum + (deltaTime * 1000) ^ 2
	-- self.accuracy = math.sqrt(self.sum / self.count)
	-- self:updateGrade()
	
	self.score = self.score
		+ math.exp(-(deltaTime / self.unit / self.scale) ^ 2)
		/ self.engine.noteCount
		* 1000000
	
	self:updateAccuracy()
	
	local timegateData = self.timegates[judgeIndex]
	if deltaTime < 0 and timegateData.nameEarly then
		self.timegate = timegateData.nameEarly
	elseif deltaTime > 0 and timegateData.nameLate then
		self.timegate = timegateData.nameLate
	else
		self.timegate = timegateData.name
	end
end

Score.updateAccuracy = function(self)
	self.accuracy = 1000 * math.sqrt(math.abs(-math.log(self.score / 1000000 * self.engine.noteCount / self.count))) * self.unit * self.scale
	self:updateGrade()
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
	return
		note.noteType == "SoundNote" or
		self.autoplay or
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

Score.processShortNote = function(self, note)
	local deltaTime = (note.engine.exactCurrentTime - note.startNoteData.timePoint.absoluteTime) / self.rate
	local timeState = self:getTimeState(deltaTime)
	
	note:process(timeState)
	self:processShortNoteState(note.state)
	
	if note.ended then
		self:hit(deltaTime, note.startNoteData.timePoint.absoluteTime)
	end
end

Score.processLongNote = function(self, note)
	local deltaStartTime = (note.engine.exactCurrentTime - note.startNoteData.timePoint.absoluteTime) / self.rate
	local deltaEndTime = (note.engine.exactCurrentTime - note.endNoteData.timePoint.absoluteTime) / self.rate
	local startTimeState = self:getTimeState(deltaStartTime)
	local endTimeState = self:getTimeState(deltaEndTime)
	
	local oldState = note.state
	note:process(startTimeState, endTimeState)
	self:processLongNoteState(note.state, oldState)
	
	local nextNote = note:getNext()
	if nextNote and note.state == "startMissed" and nextNote:isReachable() then
		note:next()
	end
	
	if note.started and not note.judged then
		self:hit(deltaStartTime, note.startNoteData.timePoint.absoluteTime)
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
