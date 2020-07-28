local Class						= require("aqua.util.Class")
local ScreenManager				= require("sphere.screen.ScreenManager")
local RhythmModel				= require("sphere.models.RhythmModel")
local NoteChartModel			= require("sphere.models.NoteChartModel")
local NoteSkinModel				= require("sphere.models.NoteSkinModel")
local InputModel				= require("sphere.models.InputModel")
local GameplayView				= require("sphere.views.GameplayView")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local GameplayController = Class:new()

GameplayController.load = function(self)
	local noteChartModel = NoteChartModel:new()
	local noteSkinModel = NoteSkinModel:new()
	local rhythmModel = RhythmModel:new()
	local inputModel = InputModel:new()

	noteChartModel:load()
	noteSkinModel:load()

	local view = GameplayView:new()

	self.noteChartModel = noteChartModel
	self.noteSkinModel = noteSkinModel
	self.rhythmModel = rhythmModel
	self.inputModel = inputModel
	self.view = view

	view.rhythmModel = rhythmModel

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
		self:receive({
			name = "play"
		})
	end)

	rhythmModel.observable:add(view)
end

GameplayController.unload = function(self)
	self.rhythmModel:unload()
	self.view:unload()
	self.rhythmModel.observable:remove(self.view)
end

GameplayController.update = function(self, dt)
	self.rhythmModel:update(dt)
	self.view:update(dt)
end

GameplayController.draw = function(self)
	self.view:draw()
end

GameplayController.receive = function(self, event)
	self.rhythmModel:receive(event)
	self.view:receive(event)

	if event.name == "play" then
		self:play()
	elseif event.name == "pause" then
		self:pause()
	elseif event.name == "keypressed" then
		if event.args[1] == "1" then
			self:pause()
		elseif event.args[1] == "2" then
			self:play()
		elseif event.args[1] == "escape" then
			self:saveScore()
			local ResultController = require("sphere.controllers.ResultController")
			local resultController = ResultController:new()

			resultController.scoreSystem = self.rhythmModel.scoreEngine.scoreSystem
			resultController.noteChart = self.noteChart
			resultController.noteChartEntry = self.noteChartModel.noteChartEntry
			resultController.noteChartDataEntry = self.noteChartModel.noteChartDataEntry
			resultController.autoplay = self.rhythmModel.logicEngine.autoplay

			ScreenManager:set(resultController)
		end
	end
end

GameplayController.saveScore = function(self)
	-- if scoreSystem.scoreTable.score > 0 and ReplayManager.mode ~= "replay" and not event.autoplay then
	-- 	local modifierSequence = ModifierManager:getSequence()
	-- 	local replayHash = ReplayManager:saveReplay(event.noteChartDataEntry, modifierSequence)
	-- 	ScoreManager:insertScore(scoreSystem.scoreTable, event.noteChartDataEntry, replayHash, modifierSequence)
	-- end
end

GameplayController.pause = function(self)
	self.rhythmModel.timeEngine:setTimeRate(0)
end

GameplayController.play = function(self)
	self.rhythmModel.timeEngine:setTimeRate(self.rhythmModel.timeEngine:getBaseTimeRate())
end

return GameplayController
