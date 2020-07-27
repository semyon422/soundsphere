local Screen					= require("sphere.screen.Screen")
local RhythmModel				= require("sphere.models.RhythmModel")
local NoteChartModel			= require("sphere.models.NoteChartModel")
local NoteSkinModel				= require("sphere.models.NoteSkinModel")
-- local InputModel				= require("sphere.models.InputModel")
local GameplayView				= require("sphere.screen.gameplay.GameplayView")
local NoteSkinManager			= require("sphere.models.NoteSkinModel.NoteSkinManager")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local GameplayScreen = Screen:new()

GameplayScreen.load = function(self)
	NoteSkinManager:load()

	local noteChartModel = NoteChartModel:new()
	noteChartModel:load()

	local rhythmModel = RhythmModel:new()
	local view = GameplayView:new()
	-- local rhythmController = RhythmController:new()
	
	self.rhythmModel = rhythmModel
	self.view = view
	-- self.rhythmController = rhythmController

	view.rhythmModel = rhythmModel
	-- rhythmController.rhythmModel = rhythmController

	local noteChart = noteChartModel:getNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel:setNoteSkin(NoteSkinModel:getNoteSkin(noteChart))
	-- rhythmModel:setInputBindings(InputModel:getInputBindings(noteChart)))
	rhythmModel:load()

	view:load()
	-- rhythmController:load()

	
	NoteChartResourceLoader:load(self.noteChartEntry.path, noteChart, function()
		self.rhythmModel.audioEngine.localAliases = NoteChartResourceLoader.localAliases
		self.rhythmModel.audioEngine.globalAliases = NoteChartResourceLoader.globalAliases
		self.rhythmModel.graphicEngine.localAliases = NoteChartResourceLoader.localAliases
		self.rhythmModel.graphicEngine.globalAliases = NoteChartResourceLoader.globalAliases
		self.rhythmModel.timeEngine:setTimeRate(self.rhythmModel.timeEngine:getBaseTimeRate())
	end)
end

GameplayScreen.unload = function(self)
	self.rhythmModel:unload()
	self.view:unload()
	-- self.rhythmController:unload()
end

GameplayScreen.receive = function(self, event)
	self.rhythmModel:receive(event)
	self.view:receive(event)
	-- self.rhythmController:receive(event)
end

GameplayScreen.update = function(self, dt)
	self.rhythmModel:update(dt)
	self.view:update(dt)
	-- self.rhythmController:update(dt)

	Screen.update(self)
end

GameplayScreen.draw = function(self)
	Screen.draw(self)

	self.view:draw()
end

return GameplayScreen
