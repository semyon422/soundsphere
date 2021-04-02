local Class = require("aqua.util.Class")

local ScoreSystem = Class:new()

ScoreSystem.missWindows = {
	ShortScoreNote = {
		pass = {-0.12, 0.12},
		miss = {-0.16}
	},
	LongScoreNote = {
		startPass = {-0.12, 0.12},
		startMiss = {-0.16},
		endPass = {-0.12, 0.12},
		endMiss = {-0.16}
	}
}

ScoreSystem.construct = function(self)
	self.score = 0

	self.noteCount = 0

	self.accuracySum = 0
	self.accuracyCount = 0
	self.accuracy = 0

	self.combo = 0
	self.maxcombo = 0
	self.hitcount = 0
	self.misscount = 0

	self.missFactor = 0

	self.hitSequence = {}
	self.scoreSequence = {}
end

ScoreSystem.updateNoteCount = function(self, event)
	if self.noteCount ~= 0 then
		return
	end

	local noteCount = 0
	noteCount = noteCount + (event.scoreNotesCount["ShortScoreNote"] or 0)
	noteCount = noteCount + (event.scoreNotesCount["LongScoreNote"] or 0)

	self.noteCount = noteCount
end

ScoreSystem.before = function(self, event)
	self:updateNoteCount(event)
end

ScoreSystem.after = function(self, event)
	if math.abs(event.timeRate) == 0 then
		return
	end

	self.missFactor = (self.hitcount + self.misscount) / self.hitcount

	self.score = self.accuracy * 1000 * self.missFactor / math.abs(event.timeRate)
	self.logscore = math.log(self.score / 1000) / math.log(2 ^ 0.1)

	self.enps = self.baseEnps * event.timeRate
	self.averageStrain = self.baseAverageStrain * event.timeRate

	self.performance = self.baseEnps / self.score * 1e6
	self.logperformance = math.log(self.performance / 100) / math.log(2 ^ 0.1)

	table.insert(self.scoreSequence, {
		currentTime = event.currentTime,
		missFactor = self.missFactor,
		score = self.score,
		logscore = self.logscore,
		performance = self.performance,
		logperformance = self.logperformance,
		combo = self.combo,
		normCombo = self.combo / self.noteCount,
		maxcombo = self.maxcombo
	})
end

ScoreSystem.processAccuracy = function(self, event)
	local deltaTime = (event.currentTime - event.noteTime) / math.abs(event.timeRate)

	self.accuracySum = self.accuracySum + deltaTime ^ 2
	self.accuracyCount = self.accuracyCount + 1
	self.accuracy = 1000 * math.sqrt(self.accuracySum / self.accuracyCount)

	table.insert(self.hitSequence, {
		currentTime = event.currentTime,
		deltaTime = deltaTime
	})
end

ScoreSystem.processSuccessfulHit = function(self)
	self.hitcount = self.hitcount + 1
	self.combo = self.combo + 1
	self.maxcombo = math.max(self.maxcombo, self.combo)
end

ScoreSystem.breakCombo = function(self)
	self.combo = 0
end

ScoreSystem.short_passed = function(self, event)
	self:processAccuracy(event)
	self:processSuccessfulHit()
end
ScoreSystem.short_missed = function(self, event)
	self:breakCombo()
	self.misscount = self.misscount + 1
end

ScoreSystem.long_clear_startPassedPressed = ScoreSystem.processAccuracy
ScoreSystem.long_clear_startMissed = ScoreSystem.short_missed
ScoreSystem.long_clear_startMissedPressed = ScoreSystem.short_missed  -- ??? does it appear anywhere?

ScoreSystem.long_startPassedPressed_startMissed = ScoreSystem.short_missed
ScoreSystem.long_startPassedPressed_endMissed = ScoreSystem.short_missed
ScoreSystem.long_startPassedPressed_endPassed = ScoreSystem.processSuccessfulHit

ScoreSystem.long_startMissedPressed_endMissedPassed = function(self, event) end
ScoreSystem.long_startMissedPressed_startMissed = ScoreSystem.breakCombo
ScoreSystem.long_startMissedPressed_endPassed = ScoreSystem.breakCombo

ScoreSystem.long_startMissed_startMissedPressed = ScoreSystem.breakCombo
ScoreSystem.long_startMissed_endMissed = ScoreSystem.breakCombo

ScoreSystem.receive = function(self, event)
	if event.name ~= "ScoreNoteState" or not event.currentTime then
		return
	end

	self:before(event)

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		if newState == "passed" then
			self:short_passed(event)
		elseif newState == "missed" then
			self:short_missed(event)
		end
	elseif event.noteType == "LongScoreNote" then
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				self:long_clear_startPassedPressed(event)
			elseif newState == "startMissed" then
				self:long_clear_startMissed(event)
			elseif newState == "startMissedPressed" then
				self:long_clear_startMissedPressed(event)
			end
		elseif oldState == "startPassedPressed" then
			if newState == "startMissed" then
				self:long_startPassedPressed_startMissed(event)
			elseif newState == "endMissed" then
				self:long_startPassedPressed_endMissed(event)
			elseif newState == "endPassed" then
				self:long_startPassedPressed_endPassed(event)
			end
		elseif oldState == "startMissedPressed" then
			if newState == "endMissedPassed" then
				self:long_startMissedPressed_endMissedPassed(event)
			elseif newState == "startMissed" then
				self:long_startMissedPressed_startMissed(event)
			elseif newState == "endMissed" then
				self:long_startMissedPressed_endPassed(event)
			end
		elseif oldState == "startMissed" then
			if newState == "startMissedPressed" then
				self:long_startMissed_startMissedPressed(event)
			elseif newState == "endMissed" then
				self:long_startMissed_endMissed(event)
			end
		end
	end

	self:after(event)
end

return ScoreSystem
