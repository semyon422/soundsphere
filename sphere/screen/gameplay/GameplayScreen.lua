local Config					= require("sphere.config.Config")
local NoteChartFactory			= require("notechart.NoteChartFactory")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local NoteSkinManager			= require("sphere.noteskin.NoteSkinManager")
local NoteSkinLoader			= require("sphere.noteskin.NoteSkinLoader")
local NotificationLine			= require("sphere.ui.NotificationLine")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local ScoreEngine				= require("sphere.screen.gameplay.ScoreEngine")
local LogicEngine				= require("sphere.screen.gameplay.LogicEngine")
local GraphicEngine				= require("sphere.screen.gameplay.GraphicEngine")
local AudioEngine				= require("sphere.screen.gameplay.AudioEngine")
local TimeEngine				= require("sphere.screen.gameplay.TimeEngine")
local InputManager				= require("sphere.screen.gameplay.InputManager")
local ReplayManager				= require("sphere.screen.gameplay.ReplayManager")
local ModifierManager			= require("sphere.screen.gameplay.ModifierManager")
local PauseOverlay				= require("sphere.screen.gameplay.PauseOverlay")
local GameplayGUI				= require("sphere.screen.gameplay.GameplayGUI")
local Screen					= require("sphere.screen.Screen")
local ScreenManager				= require("sphere.screen.ScreenManager")

local GameplayScreen = Screen:new()

GameplayScreen.init = function(self)
	InputManager:init()
	ReplayManager:init()
	PauseOverlay:init()
	NoteChartResourceLoader:init()
end

GameplayScreen.loadNoteChart = function(self)
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

GameplayScreen.load = function(self)
	local noteChart = self:loadNoteChart()

	ModifierManager.noteChart = noteChart
	ModifierManager:apply("NoteChartModifier")

	local timeEngine = TimeEngine:new()
	self.timeEngine = timeEngine
	timeEngine.noteChart = noteChart
	timeEngine:load()
	ModifierManager.timeEngine = timeEngine

	ModifierManager.timeEngine = timeEngine
	ModifierManager:apply("TimeEngineModifier")

	local scoreEngine = ScoreEngine:new()
	self.scoreEngine = scoreEngine
	scoreEngine.noteChart = noteChart
	scoreEngine.timeEngine = timeEngine
	scoreEngine:load()
	timeEngine.observable:add(scoreEngine)

	ModifierManager.scoreEngine = scoreEngine
	ModifierManager:apply("ScoreEngineModifier")

	local audioEngine = AudioEngine:new()
	self.audioEngine = audioEngine
	audioEngine:load()
	timeEngine.observable:add(audioEngine)

	ModifierManager.audioEngine = audioEngine
	ModifierManager:apply("AudioEngineModifier")

	timeEngine.audioEngine = audioEngine
	audioEngine.timeEngine = timeEngine

	InputManager:read()
	InputManager:setInputMode(noteChart.inputMode:getString())

	NoteSkinManager:load()
	local noteSkinMetaData = NoteSkinManager:getMetaData(noteChart.inputMode)
	local noteSkin = NoteSkinLoader:load(noteSkinMetaData)
	self.noteSkin = noteSkin
	noteSkinMetaData = noteSkinMetaData or {}
	noteSkin.container = self.container
	noteSkin:joinContainer(self.container)

	local logicEngine = LogicEngine:new()
	self.logicEngine = logicEngine
	logicEngine.scoreEngine = scoreEngine
	logicEngine.noteChart = noteChart
	logicEngine.localAliases = {}
	logicEngine.globalAliases = {}
	ModifierManager.logicEngine = logicEngine
	logicEngine.observable:add(ModifierManager)
	timeEngine.logicEngine = logicEngine

	ModifierManager.logicEngine = logicEngine
	ModifierManager:apply("LogicEngineModifier")

	local graphicEngine = GraphicEngine:new()
	self.graphicEngine = graphicEngine
	graphicEngine.logicEngine = logicEngine
	graphicEngine.noteChart = noteChart
	graphicEngine.noteSkin = noteSkin
	graphicEngine.container = self.container
	graphicEngine.localAliases = {}
	graphicEngine.globalAliases = {}

	ModifierManager.graphicEngine = graphicEngine
	ModifierManager:apply("GraphicEngineModifier")

	local gui = GameplayGUI:new()
	self.gui = gui
	gui.root = noteSkinMetaData.directoryPath
	gui.jsonData = noteSkin.playField
	gui.noteSkin = noteSkin
	gui.container = self.container
	gui.logicEngine = logicEngine
	gui.scoreSystem = scoreEngine.scoreSystem
	gui.noteChart = noteChart
	timeEngine.observable:add(gui)
	scoreEngine.observable:add(gui)
	
	logicEngine:load()
	graphicEngine:load()
	gui:loadTable(noteSkin.playField)

	logicEngine.observable:add(gui)
	logicEngine.observable:add(audioEngine)
	timeEngine.observable:add(logicEngine)
	timeEngine.observable:add(graphicEngine)
	timeEngine.observable:add(NotificationLine)
	timeEngine.observable:add(ReplayManager)
	timeEngine.observable:add(InputManager)
	graphicEngine.observable:add(NotificationLine)
	InputManager.observable:add(logicEngine)
	InputManager.observable:add(gui)
	InputManager.observable:add(ReplayManager)
	ReplayManager.observable:add(InputManager)
	NoteChartResourceLoader.observable:add(NotificationLine)
	
	PauseOverlay.logicEngine = logicEngine
	PauseOverlay.timeEngine = timeEngine
	PauseOverlay.scoreSystem = scoreEngine.scoreSystem
	PauseOverlay.noteChart = noteChart
	PauseOverlay.noteChartEntry = self.noteChartEntry
	PauseOverlay.noteChartDataEntry = self.noteChartDataEntry
	PauseOverlay:load()

	ReplayManager.timeEngine = timeEngine
	ReplayManager.logicEngine = logicEngine
	ReplayManager:load()
	
	local dim = 255 * (1 - Config:get("dim.gameplay"))
	local color = {dim, dim, dim}
	NoteChartResourceLoader:load(self.noteChartEntry.path, noteChart, function()
		audioEngine.localAliases = NoteChartResourceLoader.localAliases
		audioEngine.globalAliases = NoteChartResourceLoader.globalAliases
		graphicEngine.localAliases = NoteChartResourceLoader.localAliases
		graphicEngine.globalAliases = NoteChartResourceLoader.globalAliases
		timeEngine:setTimeRate(timeEngine:getBaseTimeRate())
		BackgroundManager:setColor(color)
	end)
	
	BackgroundManager:setColor(color)
end

GameplayScreen.unload = function(self)
	self.noteSkin:leaveContainer(self.container)

	self.logicEngine:unload()
	self.scoreEngine:unload()
	self.graphicEngine:unload()
	self.gui:unload()
	self.audioEngine:unload()
	
	InputManager.observable:remove(self.logicEngine)
	InputManager.observable:remove(self.gui)
	ReplayManager.observable:remove(InputManager)
end

GameplayScreen.receive = function(self, event)
	PauseOverlay:receive(event)

	if PauseOverlay.paused then
		return
	end

	self.timeEngine:update(0)
	self.timeEngine:receive(event)

	self.audioEngine:receive(event)
	ModifierManager:receive(event)
	InputManager:receive(event)
	self.scoreEngine:receive(event)
	self.graphicEngine:receive(event)
	self.gui:receive(event)
end

GameplayScreen.update = function(self, dt)
	ReplayManager:update()
	self.logicEngine:update()

	self.timeEngine:update(dt)
	self.audioEngine:update()
	self.scoreEngine:update()
	self.graphicEngine:update(dt)
	self.gui:update()
	PauseOverlay:update(dt)
	ModifierManager:update()
	
	Screen.update(self)
end

GameplayScreen.draw = function(self)
	Screen.draw(self)
	
	PauseOverlay:draw()
end

return GameplayScreen
