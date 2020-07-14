local NoteChartFactory		= require("notechart.NoteChartFactory")
local ScoreEngine			= require("sphere.screen.gameplay.ScoreEngine")
local LogicEngine			= require("sphere.screen.gameplay.LogicEngine")
local TimeEngine			= require("sphere.screen.gameplay.TimeEngine")
local InputManager			= require("sphere.screen.gameplay.InputManager")
local ReplayManager			= require("sphere.screen.gameplay.ReplayManager")
local ModifierManager		= require("sphere.screen.gameplay.ModifierManager")

local FastPlay = {}

FastPlay.loadNoteChart = function(self)
	local path = self.noteChartEntry.path
	local file = love.filesystem.newFile(path)
	file:open("r")
	local content = file:read()
	file:close()
	
	local status, noteCharts = NoteChartFactory:getNoteCharts(
		path,
		content,
		self.noteChartDataEntry.index
	)
	if not status then
		error(noteCharts)
	end
	return noteCharts[1]
end

FastPlay.play = function(self)
	self:loadTimePoints()
	self:load()

	local timeEngine = self.timeEngine
	local absoluteTimeList = self.absoluteTimeList
	for i = 1, #absoluteTimeList do
		local time = absoluteTimeList[i]
		timeEngine.currentTime = time
		timeEngine.exactCurrentTime = time
		timeEngine:sendState()
		self:update(0)
	end
	-- print(self.scoreEngine.scoreSystem.scoreTable.score)

	self:unload()
end

FastPlay.load = function(self)
	local noteChart = self:loadNoteChart()

	ModifierManager.noteChart = noteChart
	ModifierManager:apply("NoteChartModifier")

	local timeEngine = TimeEngine:new()
	self.timeEngine = timeEngine
	timeEngine.noteChart = noteChart
	timeEngine:load()
	ModifierManager.timeEngine = timeEngine
	ModifierManager:apply("TimeEngineModifier")

	local scoreEngine = ScoreEngine:new()
	self.scoreEngine = scoreEngine
	scoreEngine.noteChart = noteChart
	scoreEngine:load()
	timeEngine.observable:add(scoreEngine)

	ModifierManager.scoreEngine = scoreEngine
	ModifierManager:apply("ScoreEngineModifier")

	InputManager:read()
	InputManager:setInputMode(noteChart.inputMode:getString())

	local logicEngine = LogicEngine:new()
	self.logicEngine = logicEngine
	logicEngine.scoreEngine = scoreEngine
	logicEngine.noteChart = noteChart
	logicEngine.localAliases = {}
	logicEngine.globalAliases = {}
	ModifierManager.logicEngine = logicEngine
	logicEngine.observable:add(ModifierManager)

	ModifierManager.logicEngine = logicEngine
	ModifierManager:apply("LogicEngineModifier")
	
	logicEngine:load()

	timeEngine.observable:add(logicEngine)
	timeEngine.observable:add(ReplayManager)
	InputManager.observable:add(logicEngine)
	InputManager.observable:add(ReplayManager)
	ReplayManager.observable:add(InputManager)
	ReplayManager.timeEngine = timeEngine
	ReplayManager.logicEngine = logicEngine
	ReplayManager:load()
	
	timeEngine:setTimeRate(timeEngine:getBaseTimeRate())
end

FastPlay.unload = function(self)
	self.logicEngine:unload()
	self.scoreEngine:unload()
	
	InputManager.observable:remove(self.logicEngine)
	ReplayManager.observable:remove(InputManager)
end

FastPlay.update = function(self, dt)
	self.logicEngine:update(dt)
	self.scoreEngine:update()
	ModifierManager:update()
end

FastPlay.loadTimePoints = function(self)
	local absoluteTimes = {}

	local events = self.replay.events
	for i = 1, #events do
		absoluteTimes[events[i].time] = true
	end
	
	local absoluteTimeList = {}
	for time in pairs(absoluteTimes) do
		absoluteTimeList[#absoluteTimeList + 1] = time
	end
	table.sort(absoluteTimeList)
	
	self.absoluteTimeList = absoluteTimeList
	self.nextTimeIndex = 1
end

return FastPlay
