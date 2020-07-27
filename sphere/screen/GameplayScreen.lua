local Screen					= require("sphere.screen.Screen")
local RhythmModel				= require("sphere.models.RhythmModel")
local NoteChartModel			= require("sphere.models.NoteChartModel")
local NoteSkinModel				= require("sphere.models.NoteSkinModel")
local InputModel				= require("sphere.models.InputModel")
local GameplayController		= require("sphere.controllers.GameplayController")
local GameplayView				= require("sphere.views.GameplayView")
local NoteSkinManager			= require("sphere.models.NoteSkinModel.NoteSkinManager")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local GameplayScreen = Screen:new()

GameplayScreen.load = function(self)
	NoteSkinManager:load()

	local noteChartModel = NoteChartModel:new()
	noteChartModel:load()

	local rhythmModel = RhythmModel:new()
	local view = GameplayView:new()
	local gameplayController = GameplayController:new()
	local inputModel = InputModel:new()

	self.rhythmModel = rhythmModel
	self.view = view
	self.gameplayController = gameplayController
	self.inputModel = inputModel

	view.rhythmModel = rhythmModel
	gameplayController.rhythmModel = rhythmModel

	local noteChart = noteChartModel:getNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	inputModel:read()
	rhythmModel:setInputBindings(inputModel:getInputBindings())
	rhythmModel.inputManager:setInputMode(noteChart.inputMode:getString())

	-- rhythmModel:load()
	-- gameplayController:load()

	local modifierModel = rhythmModel.modifierModel

	modifierModel:load()

	modifierModel:apply("NoteChartModifier")

	rhythmModel.noteSkinMetaData = NoteSkinModel:getNoteSkinMetaData(noteChart)
	rhythmModel:setNoteSkin(NoteSkinModel:getNoteSkin(rhythmModel.noteSkinMetaData))

	rhythmModel.timeEngine:load()
	modifierModel:apply("TimeEngineModifier")

	rhythmModel.scoreEngine:load()
	modifierModel:apply("ScoreEngineModifier")

	rhythmModel.audioEngine:load()
	modifierModel:apply("AudioEngineModifier")

	modifierModel:apply("LogicEngineModifier")
	modifierModel:apply("GraphicEngineModifier")

	rhythmModel.logicEngine:load()
	rhythmModel.graphicEngine:load()
	rhythmModel.replayManager:load()

	view:load()

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
	-- self.gameplayController:unload()
end

GameplayScreen.receive = function(self, event)
	self.rhythmModel:receive(event)
	self.view:receive(event)
	self.gameplayController:receive(event)
end

GameplayScreen.update = function(self, dt)
	self.rhythmModel:update(dt)
	self.view:update(dt)
	-- self.gameplayController:update(dt)

	Screen.update(self)
end

GameplayScreen.draw = function(self)
	Screen.draw(self)

	self.view:draw()
end

return GameplayScreen
