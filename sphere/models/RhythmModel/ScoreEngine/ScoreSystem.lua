local Class = require("aqua.util.Class")

local ScoreSystem = Class:new()

ScoreSystem.missWindows = {
	ShortScoreNote = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.16}
	},
	LongScoreNote = {
		startHit = {-0.12, 0.12},
		startMiss = {-0.16, 0.16},
		endHit = {-0.12, 0.12},
		endMiss = {-0.16, 0.16}
	}
}

ScoreSystem.noteScores = {
	{
		time = -0.16,
		names = {"miss"}
	},
	{
		time = -0.12,
		names = {"bad"}
	},
	{
		time = -0.04,
		names = {"early good", "good"}
	},
	{
		time = -0.016,
		names = {"great"}
	},
	{
		time = 0.016,
		names = {"great"}
	},
	{
		time = 0.04,
		names = {"late good", "good"}
	},
	{
		time = 0.12,
		names = {"bad"}
	},
	{
		time = 0.16,
		names = {"miss"}
	}
}

local sortNoteScores = function(a, b)
	return a.time < b.time
end

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

	self.noteScoreName = ""
	self.noteScoreCounters = {}
	self.noteScoresLT0 = {}
	self.noteScoresMT0 = {}

	for _, noteScore in ipairs(self.noteScores) do
		for _, name in ipairs(noteScore.names) do
			self.noteScoreCounters[name] = 0
		end
		if noteScore.time < 0 then
			table.insert(self.noteScoresLT0, noteScore)
			noteScore.time = -noteScore.time
		elseif noteScore.time > 0 then
			table.insert(self.noteScoresMT0, noteScore)
		end
	end

	table.sort(self.noteScoresLT0, sortNoteScores)
	table.sort(self.noteScoresMT0, sortNoteScores)
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

	self.enps = self.baseEnps * event.timeRate
	self.averageStrain = self.baseAverageStrain * event.timeRate

	self.performance = self.baseEnps / self.score * 1e6

	table.insert(self.scoreSequence, {
		currentTime = event.currentTime,
		missFactor = self.missFactor,
		score = self.score,
		performance = self.performance,
		combo = self.combo,
		normCombo = self.combo / self.noteCount,
		maxcombo = self.maxcombo
	})
end

ScoreSystem.processAccuracy = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)

	self.accuracySum = self.accuracySum + deltaTime ^ 2
	self.accuracyCount = self.accuracyCount + 1
	self.accuracy = 1000 * math.sqrt(self.accuracySum / self.accuracyCount)

	table.insert(self.hitSequence, {
		currentTime = event.currentTime,
		deltaTime = deltaTime
	})
end

ScoreSystem.processNoteScore = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)
	local noteScores = deltaTime < 0 and self.noteScoresLT0 or self.noteScoresMT0
	deltaTime = math.abs(deltaTime)

	for _, noteScore in ipairs(noteScores) do
		if deltaTime <= noteScore.time then
			for _, name in ipairs(noteScore.names) do
				self.noteScoreCounters[name] = (self.noteScoreCounters[name] or 0) + 1
			end
			self.noteScoreName = noteScore.names[1]
			break
		end
	end
end

ScoreSystem.processSuccessfulHit = function(self)
	self.hitcount = self.hitcount + 1
	self.combo = self.combo + 1
	self.maxcombo = math.max(self.maxcombo, self.combo)
end

ScoreSystem.breakCombo = function(self)
	self.combo = 0
end

ScoreSystem.short_missed = function(self, event)
	self:breakCombo()
	self.misscount = self.misscount + 1
end

ScoreSystem.rules = {
	ShortScoreNote = {
		clear = {
			passed = {ScoreSystem.processAccuracy, ScoreSystem.processNoteScore, ScoreSystem.processSuccessfulHit},
			missed = ScoreSystem.short_missed,
		},
	},
	LongScoreNote = {
		clear = {
			startPassedPressed = {ScoreSystem.processAccuracy, ScoreSystem.processNoteScore},
			startMissed = ScoreSystem.short_missed,
			startMissedPressed = ScoreSystem.short_missed,  -- ??? does it appear anywhere?
		},
		startPassedPressed = {
			startMissed = ScoreSystem.short_missed,
			endMissed = ScoreSystem.short_missed,
			endPassed = ScoreSystem.processSuccessfulHit,
		},
		startMissedPressed = {
			endMissedPassed = function(self, event) end,
			startMissed = ScoreSystem.breakCombo,
			endMissed = ScoreSystem.breakCombo,
		},
		startMissed = {
			startMissedPressed = ScoreSystem.breakCombo,
			endMissed = ScoreSystem.breakCombo,
		},
	},
}

ScoreSystem.receive = function(self, event)
	if event.name ~= "ScoreNoteState" or not event.currentTime then
		return
	end

	self:before(event)

	local oldState, newState = event.oldState, event.newState
	local handler =
		self.rules[event.noteType] and
		self.rules[event.noteType][oldState] and
		self.rules[event.noteType][oldState][newState]

	if type(handler) == "function" then
		handler(self, event)
	elseif type(handler) == "table" then
		for _, h in ipairs(handler) do
			h(self, event)
		end
	end

	self:after(event)
end

return ScoreSystem
