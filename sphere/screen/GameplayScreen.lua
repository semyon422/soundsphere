local Screen					= require("sphere.screen.Screen")
local RhythmModel				= require("sphere.models.RhythmModel")
local NoteChartModel			= require("sphere.models.NoteChartModel")
local NoteSkinModel				= require("sphere.models.NoteSkinModel")
local InputModel				= require("sphere.models.InputModel")
local GameplayController		= require("sphere.controllers.GameplayController")
local GameplayView				= require("sphere.views.GameplayView")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local GameplayScreen = Screen:new()

GameplayScreen.load = function(self)
	local noteChartModel = NoteChartModel:new()
	local noteSkinModel = NoteSkinModel:new()
	local rhythmModel = RhythmModel:new()
	local inputModel = InputModel:new()

	noteChartModel:load()
	noteSkinModel:load()

	local view = GameplayView:new()
	local gameplayController = GameplayController:new()

	self.rhythmModel = rhythmModel
	self.view = view
	self.gameplayController = gameplayController
	self.inputModel = inputModel

	view.rhythmModel = rhythmModel
	gameplayController.view = view
	gameplayController.rhythmModel = rhythmModel
	gameplayController.noteChartModel = noteChartModel

	local noteChart = noteChartModel:getNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart
	view.noteChart = noteChart

	inputModel:load()
	rhythmModel:setInputBindings(inputModel:getInputBindings())
	rhythmModel.inputManager:setInputMode(noteChart.inputMode:getString())

	-- rhythmModel:load()

	local modifierModel = rhythmModel.modifierModel

	modifierModel:load()

	modifierModel:apply("NoteChartModifier")

	local noteSkin = noteSkinModel:getNoteSkin(noteChart.inputMode)
	noteSkin:load()
	rhythmModel:setNoteSkin(noteSkin)
	view.noteSkin = noteSkin

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

	view.scoreSystem = rhythmModel.scoreEngine.scoreSystem

	view:load()

	NoteChartResourceLoader:load(self.noteChartEntry.path, noteChart, function()
		rhythmModel:setResourceAliases(NoteChartResourceLoader.localAliases, NoteChartResourceLoader.globalAliases)
		gameplayController:receive({
			name = "play"
		})
	end)

	rhythmModel.observable:add(view)
end

GameplayScreen.unload = function(self)
	self.rhythmModel:unload()
	self.view:unload()
	self.rhythmModel.observable:remove(self.view)
end

GameplayScreen.receive = function(self, event)
	self.rhythmModel:receive(event)
	self.view:receive(event)
	self.gameplayController:receive(event)
end

GameplayScreen.update = function(self, dt)
	self.rhythmModel:update(dt)
	self.view:update(dt)

	Screen.update(self)
end

GameplayScreen.draw = function(self)
	Screen.draw(self)

	self.view:draw()
end

return GameplayScreen
