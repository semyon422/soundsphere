local Config					= require("sphere.config.Config")
local NoteChartFactory			= require("notechart.NoteChartFactory")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local NoteSkinManager			= require("sphere.noteskin.NoteSkinManager")
local NoteSkinLoader			= require("sphere.noteskin.NoteSkinLoader")
local NotificationLine			= require("sphere.ui.NotificationLine")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local LogicEngine				= require("sphere.screen.gameplay.LogicEngine")
local GraphicEngine				= require("sphere.screen.gameplay.GraphicEngine")
local CustomScore				= require("sphere.screen.gameplay.CustomScore")
local InputManager				= require("sphere.screen.gameplay.InputManager")
local ModifierManager			= require("sphere.screen.gameplay.ModifierManager")
local PauseOverlay				= require("sphere.screen.gameplay.PauseOverlay")
local GameplayGUI				= require("sphere.screen.gameplay.GameplayGUI")
local Screen					= require("sphere.screen.Screen")
local ScreenManager				= require("sphere.screen.ScreenManager")

local GameplayScreen = Screen:new()

GameplayScreen.init = function(self)
	InputManager:init()
	PauseOverlay:init()
	NoteChartResourceLoader:init()
end

GameplayScreen.load = function(self)
	InputManager:read()
	NoteSkinManager:load()
	
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
	local noteChart = noteCharts[1]

	self.logicEngine = LogicEngine:new()
	self.logicEngine.score = CustomScore:new()

	self.graphicEngine = GraphicEngine:new()
	self.graphicEngine.logicEngine = self.logicEngine

	self.gui = GameplayGUI:new()

	ModifierManager.logicEngine = self.logicEngine
	ModifierManager.noteChart = noteChart
	ModifierManager:apply()

	InputManager:setInputMode(noteChart.inputMode:getString())
	
	local noteSkinMetaData = NoteSkinManager:getMetaData(noteChart.inputMode)
	local noteSkin = NoteSkinLoader:load(noteSkinMetaData)
	noteSkinMetaData = noteSkinMetaData or {}

	noteSkin.container = self.container
	noteSkin:joinContainer(self.container)
	
	self.graphicEngine.noteChart = noteChart
	self.graphicEngine.noteSkin = noteSkin
	self.graphicEngine.container = self.container
	self.graphicEngine.localAliases = {}
	self.graphicEngine.globalAliases = {}
	
	self.logicEngine.noteChart = noteChart
	self.logicEngine.localAliases = {}
	self.logicEngine.globalAliases = {}
	
	self.gui.root = noteSkinMetaData.directoryPath
	self.gui.jsonData = noteSkin.playField
	self.gui.noteSkin = noteSkin
	self.gui.container = self.container
	self.gui.logicEngine = self.logicEngine
	
	self.logicEngine.score.logicEngine = self.logicEngine
	self.logicEngine.score.noteChart = noteChart
	self.logicEngine.score.hash = self.noteChartDataEntry.hash
	self.logicEngine.score.index = self.noteChartDataEntry.index
	self.gui.score = self.logicEngine.score
	
	self.logicEngine:load()
	self.graphicEngine:load()
	self.gui:loadTable(noteSkin.playField)
	
	self.logicEngine.observable:add(self.gui)
	self.logicEngine.observable:add(NotificationLine)
	self.graphicEngine.observable:add(NotificationLine)
	NoteChartResourceLoader.observable:add(NotificationLine)
	
	PauseOverlay.logicEngine = self.logicEngine
	PauseOverlay.noteChart = noteChart
	PauseOverlay.noteChartEntry = self.noteChartEntry
	PauseOverlay.noteChartDataEntry = self.noteChartDataEntry
	PauseOverlay:load()
	
	InputManager.observable:add(self.logicEngine)
	
	local dim = 255 * (1 - Config:get("dim.gameplay"))
	local color = {dim, dim, dim}
	NoteChartResourceLoader:load(self.noteChartEntry.path, noteChart, function()
		self.logicEngine.localAliases = NoteChartResourceLoader.localAliases
		self.logicEngine.globalAliases = NoteChartResourceLoader.globalAliases
		self.graphicEngine.localAliases = NoteChartResourceLoader.localAliases
		self.graphicEngine.globalAliases = NoteChartResourceLoader.globalAliases
		PauseOverlay:play()
		BackgroundManager:setColor(color)
	end)
	
	BackgroundManager:setColor(color)
end

GameplayScreen.unload = function(self)
	self.graphicEngine.noteSkin:leaveContainer(self.container)

	self.logicEngine:unload()
	self.graphicEngine:unload()
	self.gui:unload()
	
	if self.logicEngine.score.setinput then
		InputManager:setKeysFromInputStats(self.logicEngine.inputStats)
		InputManager:write()
	end
	
	InputManager.observable:remove(self.logicEngine)
end

GameplayScreen.update = function(self, dt)
	self.logicEngine:update(dt)
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

GameplayScreen.receive = function(self, event)
	if not PauseOverlay.paused then
		self.logicEngine:receive(event)
		self.graphicEngine:receive(event)
		InputManager:receive(event)
		self.gui:receive(event)
	end
	PauseOverlay:receive(event)
end

return GameplayScreen
