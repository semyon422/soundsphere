local Config					= require("sphere.config.Config")
local NoteChartFactory			= require("sphere.database.NoteChartFactory")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local NotificationLine			= require("sphere.ui.NotificationLine")
local BackgroundManager			= require("sphere.ui.BackgroundManager")
local BMSBGA					= require("sphere.screen.gameplay.BMSBGA")
local CloudburstEngine			= require("sphere.screen.gameplay.CloudburstEngine")
local NoteSkin					= require("sphere.screen.gameplay.CloudburstEngine.NoteSkin")
local CustomScore				= require("sphere.screen.gameplay.CustomScore")
local InputManager				= require("sphere.screen.gameplay.InputManager")
local ModifierManager			= require("sphere.screen.gameplay.ModifierManager")
local NoteSkinManager			= require("sphere.screen.gameplay.NoteSkinManager")
local NoteSkinLoader			= require("sphere.screen.gameplay.NoteSkinLoader")
local PauseOverlay				= require("sphere.screen.gameplay.PauseOverlay")
local PlayField					= require("sphere.screen.gameplay.PlayField")
local ProgressBar				= require("sphere.screen.gameplay.ProgressBar")
local AccuracyGraph				= require("sphere.screen.result.AccuracyGraph")
local Screen					= require("sphere.screen.Screen")
local ScreenManager				= require("sphere.screen.ScreenManager")

local GameplayScreen = Screen:new()

GameplayScreen.init = function(self)
	InputManager:init()
	ProgressBar:init()
	PauseOverlay:init()
	AccuracyGraph:init()
end

GameplayScreen.load = function(self)
	InputManager:read()
	NoteSkinManager:load()
	
	local noteChart, hash = NoteChartFactory:getNoteChart(self.cacheData.path)

	self.engine = CloudburstEngine:new()
	self.engine.score = CustomScore:new()
	self.playField = PlayField:new()

	ModifierManager.engine = self.engine
	ModifierManager.noteChart = noteChart
	ModifierManager:apply()

	InputManager:setInputMode(noteChart.inputMode:getString())
	
	local noteSkinMetaData = NoteSkinManager:getMetaData(noteChart.inputMode)
	local noteSkin = NoteSkinLoader:load(noteSkinMetaData)
	noteSkinMetaData = noteSkinMetaData or {}
	
	self.engine.noteChart = noteChart
	self.engine.noteSkin = noteSkin
	self.engine.container = self.container
	self.engine.localAliases = {}
	self.engine.globalAliases = {}
	
	self.playField.directoryPath = noteSkinMetaData.directoryPath
	self.playField.noteSkinData = noteSkin
	self.playField.playFieldData = noteSkin.playField
	self.playField.noteSkin = noteSkin
	self.playField.container = self.container
	
	self.bga = BMSBGA:new()
	self.bga.noteChart = noteChart
	self.bga.engine = self.engine
	self.engine.bga = self.bga
	self.engine.score.engine = self.engine
	self.engine.score.noteChart = noteChart
	self.engine.score.hash = hash
	self.playField.score = self.engine.score
	
	self.engine:load()
	self.playField:load()
	
	self.engine.observable:add(self.playField)
	self.engine.observable:add(NotificationLine)
	NoteChartResourceLoader.observable:add(NotificationLine)
	
	PauseOverlay.engine = self.engine
	PauseOverlay.noteChart = noteChart
	PauseOverlay.cacheData = self.cacheData
	PauseOverlay:load()
	
	ProgressBar.engine = self.engine
	ProgressBar:load()
	
	AccuracyGraph.score = self.engine.score
	AccuracyGraph:load()
	
	InputManager.observable:add(self.engine)
	
	NoteChartResourceLoader:load(self.cacheData.path, noteChart, function()
		self.engine.localAliases = NoteChartResourceLoader.localAliases
		self.engine.globalAliases = NoteChartResourceLoader.globalAliases
		self.bga:load()
		PauseOverlay:play()
	end)
	
	local dim = 255 * (1 - Config:get("dim.gameplay"))
	local color = {dim, dim, dim}
	BackgroundManager:setColor(color)
	self.bga:setColor(color)
end

GameplayScreen.unload = function(self)
	self.engine:unload()
	self.playField:unload()
	self.bga:unload()
	
	if self.engine.score.setinput then
		InputManager:setKeysFromInputStats(self.engine.inputStats)
		InputManager:write()
	end
	
	InputManager.observable:remove(self.engine)
end

GameplayScreen.update = function(self, dt)
	self.engine:update(dt)
	self.playField:update()
	self.bga:update(dt)
	PauseOverlay:update(dt)
	ProgressBar:update(dt)
	
	Screen.update(self)
end

GameplayScreen.draw = function(self)
	self.bga:draw()
	AccuracyGraph:draw()
	self.engine:draw()
	
	Screen.draw(self)
	
	ProgressBar:draw()
	PauseOverlay:draw()
end

GameplayScreen.receive = function(self, event)
	if not PauseOverlay.paused then
		self.engine:receive(event)
		InputManager:receive(event)
		self.playField:receive(event)
		self.bga:receive(event)
		AccuracyGraph:receive(event)
	end
	PauseOverlay:receive(event)
end

return GameplayScreen
