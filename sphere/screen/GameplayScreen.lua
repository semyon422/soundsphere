local Screen = require("sphere.screen.Screen")
local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local NoteSkinManager = require("sphere.game.NoteSkinManager")
local InputManager = require("sphere.game.InputManager")
local PlayField = require("sphere.game.PlayField")
local CustomScore = require("sphere.game.CustomScore")
local NoteChartResourceLoader = require("sphere.game.NoteChartManager.NoteChartResourceLoader")
local CloudburstEngine = require("sphere.game.CloudburstEngine")
local NoteSkin = require("sphere.game.CloudburstEngine.NoteSkin")
local NotificationLine = require("sphere.ui.NotificationLine")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local PauseOverlay = require("sphere.ui.PauseOverlay")
local ScreenManager = require("sphere.screen.ScreenManager")
local ModifierManager = require("sphere.game.ModifierManager")
local BMSBGA = require("sphere.game.BMSBGA")
local Config = require("sphere.game.Config")

local GameplayScreen = Screen:new()

Screen.construct(GameplayScreen)

GameplayScreen.load = function(self)
	InputManager:load()
	
	local noteChart = NoteChartFactory:getNoteChart(self.cacheData.path)
	local noteSkinData = NoteSkinManager:getNoteSkin(noteChart.inputMode)
	
	local noteSkin = NoteSkin:new({
		directoryPath = noteSkinData.directoryPath,
		noteSkinData = noteSkinData.noteSkin
	})
	
	self.engine = CloudburstEngine:new()
	self.engine.noteChart = noteChart
	self.engine.noteSkin = noteSkin
	self.engine.container = self.container
	self.engine.score = CustomScore:new()
	self.engine.aliases = NoteChartResourceLoader.aliases
	
	self.playField = PlayField:new()
	self.playField.directoryPath = noteSkinData.directoryPath
	self.playField.noteSkinData = noteSkinData.noteSkin
	self.playField.playFieldData = noteSkinData.playField
	self.playField.noteSkin = noteSkin
	self.playField.container = self.container
	
	ModifierManager.engine = self.engine
	ModifierManager.noteChart = noteChart
	ModifierManager.noteSkin = noteSkin
	ModifierManager.playField = self.playField
	ModifierManager:apply()
	
	self.bga = BMSBGA:new()
	self.bga.noteChart = noteChart
	self.bga.engine = self.engine
	self.engine.bga = self.bga
	self.engine.score.engine = self.engine
	self.engine.score.noteChart = noteChart
	self.playField.score = self.engine.score
	
	self.engine:load()
	self.playField:load()
	
	self.engine.observable:add(self.playField)
	self.engine.observable:add(NotificationLine)
	NoteChartResourceLoader.observable:add(NotificationLine)
	
	NoteChartResourceLoader:load(self.cacheData.path, noteChart, function()
		self.bga:load()
		self.engine:play()
	end)
	
	PauseOverlay.engine = self.engine
	PauseOverlay:load()
	
	local dim = 255 * (1 - Config.data.dim.gameplay)
	local color = {dim, dim, dim}
	BackgroundManager:setColor(color)
	self.bga:setColor(color)
end

GameplayScreen.unload = function(self)
	self.engine:unload()
	self.playField:unload()
	self.bga:unload()
end

GameplayScreen.update = function(self, dt)
	self.engine:update(dt)
	self.playField:update()
	self.bga:update(dt)
	PauseOverlay:update(dt)
	
	Screen.update(self)
end

GameplayScreen.draw = function(self)
	self.bga:draw()
	self.engine:draw()
	
	Screen.draw(self)
	
	PauseOverlay:draw()
end

GameplayScreen.receive = function(self, event)
	InputManager:receive(event, self.engine)
	self.engine:receive(event)
	self.playField:receive(event)
	self.bga:receive(event)
	PauseOverlay:receive(event)
	
	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "escape" and not shift then
			PauseOverlay:pause()
		elseif key == "escape" then
			PauseOverlay:menu()
		end
	end
end

return GameplayScreen
