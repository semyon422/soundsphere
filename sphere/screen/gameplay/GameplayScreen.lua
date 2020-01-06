local Config					= require("sphere.config.Config")
local NoteChartFactory			= require("sphere.database.NoteChartFactory")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local NoteSkinManager			= require("sphere.noteskin.NoteSkinManager")
local NoteSkinLoader			= require("sphere.noteskin.NoteSkinLoader")
local NotificationLine			= require("sphere.ui.NotificationLine")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local BMSBGA					= require("sphere.screen.gameplay.BMSBGA")
local CloudburstEngine			= require("sphere.screen.gameplay.CloudburstEngine")
local NoteSkin					= require("sphere.screen.gameplay.CloudburstEngine.NoteSkin")
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
end

GameplayScreen.load = function(self)
	InputManager:read()
	NoteSkinManager:load()
	
	local noteChart, hash = NoteChartFactory:getNoteChart(self.cacheData.path)

	self.engine = CloudburstEngine:new()
	self.engine.score = CustomScore:new()
	self.gui = GameplayGUI:new()

	ModifierManager.engine = self.engine
	ModifierManager.noteChart = noteChart
	ModifierManager:apply()

	InputManager:setInputMode(noteChart.inputMode:getString())
	
	local noteSkinMetaData = NoteSkinManager:getMetaData(noteChart.inputMode)
	local noteSkin = NoteSkinLoader:load(noteSkinMetaData)
	noteSkinMetaData = noteSkinMetaData or {}

	noteSkin.container = self.container
	noteSkin:joinContainer(self.container)
	
	self.engine.noteChart = noteChart
	self.engine.noteSkin = noteSkin
	self.engine.container = self.container
	self.engine.localAliases = {}
	self.engine.globalAliases = {}
	
	self.gui.root = noteSkinMetaData.directoryPath
	self.gui.jsonData = noteSkin.playField
	self.gui.noteSkin = noteSkin
	self.gui.container = self.container
	self.gui.engine = self.engine
	
	self.bga = BMSBGA:new()
	self.bga.noteChart = noteChart
	self.bga.engine = self.engine
	self.engine.bga = self.bga
	self.engine.score.engine = self.engine
	self.engine.score.noteChart = noteChart
	self.engine.score.hash = hash
	self.gui.score = self.engine.score
	
	self.engine:load()
	self.gui:loadTable(noteSkin.playField)
	
	self.engine.observable:add(self.gui)
	self.engine.observable:add(NotificationLine)
	NoteChartResourceLoader.observable:add(NotificationLine)
	
	PauseOverlay.engine = self.engine
	PauseOverlay.noteChart = noteChart
	PauseOverlay.cacheData = self.cacheData
	PauseOverlay:load()
	
	InputManager.observable:add(self.engine)
	
	local dim = 255 * (1 - Config:get("dim.gameplay"))
	local color = {dim, dim, dim}
	NoteChartResourceLoader:load(self.cacheData.path, noteChart, function()
		self.engine.localAliases = NoteChartResourceLoader.localAliases
		self.engine.globalAliases = NoteChartResourceLoader.globalAliases
		self.bga:load()
		PauseOverlay:play()
		BackgroundManager:setColor(color)
		self.bga:setColor(color)
	end)
	
	BackgroundManager:setColor(color)
	self.bga:setColor(color)
end

GameplayScreen.unload = function(self)
	self.engine.noteSkin:leaveContainer(self.container)

	self.engine:unload()
	self.gui:unload()
	self.bga:unload()
	
	if self.engine.score.setinput then
		InputManager:setKeysFromInputStats(self.engine.inputStats)
		InputManager:write()
	end
	
	InputManager.observable:remove(self.engine)
end

GameplayScreen.update = function(self, dt)
	self.engine:update(dt)
	self.gui:update()
	self.bga:update(dt)
	PauseOverlay:update(dt)
	ModifierManager:update()
	
	Screen.update(self)
end

GameplayScreen.draw = function(self)
	self.bga:draw()
	
	Screen.draw(self)
	
	PauseOverlay:draw()
end

GameplayScreen.receive = function(self, event)
	if not PauseOverlay.paused then
		self.engine:receive(event)
		InputManager:receive(event)
		self.gui:receive(event)
		self.bga:receive(event)
	end
	PauseOverlay:receive(event)
end

return GameplayScreen
