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
local ScreenManager = require("sphere.screen.ScreenManager")
local ModifierManager = require("sphere.game.ModifierManager")

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
	self.engine:load()
	self.playField:load()
	
	self.engine.observable:add(self.playField)
	self.engine.observable:add(NotificationLine)
	NoteChartResourceLoader.observable:add(NotificationLine)
	
	NoteChartResourceLoader:load(self.cacheData.path, noteChart, function()
		self.engine:play()
	end)
	
	BackgroundManager:setColor({63, 63, 63})
end

GameplayScreen.unload = function(self)
	self.engine:unload()
	self.playField:unload()
end

GameplayScreen.update = function(self, dt)
	self.engine:update(dt)
	self.playField:update()
	
	Screen.update(self)
end

GameplayScreen.draw = function(self)
	Screen.draw(self)
end

GameplayScreen.receive = function(self, event)
	InputManager:receive(event, self.engine)
	self.engine:receive(event)
	self.playField:receive(event)
	
	if event.name == "keypressed" and event.args[1] == "escape" then
		ScreenManager:set(require("sphere.screen.ResultScreen"))
		ScreenManager:receive({
			name = "score",
			score = self.engine.score
		})
		ScreenManager:receive({
			name = "metadata",
			data = self.cacheData
		})
	end
end

return GameplayScreen
