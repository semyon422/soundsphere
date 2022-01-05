local Class = require("aqua.util.Class")

local FastplayController = require("sphere.controllers.FastplayController")
local ResultController = require("sphere.controllers.ResultController")
local WebNoteChartController = require("sphere.controllers.WebNoteChartController")

local Replay = require("sphere.models.ReplayModel.Replay")
local NoteChartFactory = require("notechart.NoteChartFactory")
local ModifierModel = require("sphere.models.ModifierModel")
local DifficultyModel = require("sphere.models.DifficultyModel")
local RhythmModel = require("sphere.models.RhythmModel")
local NoteChartModel = require("sphere.models.NoteChartModel")

local WebReplayController = {}

WebReplayController.getReplay = function(replay)
	local file = io.open(replay.path, "r")
	if not file then
		error("Replay not found")
	end
	local content = file:read("*a")
	file:close()

	return Replay:new():fromString(content)
end

WebReplayController.POST = function(self)
	local params = self.params

	local noteChart = WebNoteChartController.getNoteChart(params.notechart)
	local noteChartDataEntry = noteChart.metaData:getTable()

	local replay = WebReplayController.getReplay(params.replay)

	local fastplayController = FastplayController:new()

	local rhythmModel = RhythmModel:new()
	local modifierModel = ModifierModel:new()
	local noteChartModel = NoteChartModel:new()
	local difficultyModel = DifficultyModel:new()

	modifierModel.noteChartModel = noteChartModel
	modifierModel.difficultyModel = difficultyModel
	modifierModel.rhythmModel = rhythmModel

	rhythmModel.modifierModel = modifierModel
	rhythmModel.timings = require("sphere.models.ConfigModel.timings")
	rhythmModel.judgements = require("sphere.models.ConfigModel.judgements")
	rhythmModel.hp = require("sphere.models.ConfigModel.hp")
	rhythmModel.settings = require("sphere.models.ConfigModel.settings")

	noteChartModel.noteChart = noteChart
	noteChartModel.load = function() end
	noteChartModel.loadNoteChart = function() return noteChart end

	noteChartModel.noteChartDataEntry = noteChartDataEntry

	fastplayController.gameController = {
		noteChartModel = noteChartModel,
		difficultyModel = difficultyModel,
		rhythmModel = rhythmModel,
	}

	modifierModel.config = replay.modifiers
	modifierModel:fixOldFormat(replay.modifiers)

	if replay.timings then
		rhythmModel.timings = replay.timings
	else
		rhythmModel.timings = ResultController.oldTimings
	end
	rhythmModel.replayModel.replay = replay
	rhythmModel.inputManager:setMode("internal")
	rhythmModel.replayModel:setMode("replay")

	fastplayController:play()

	local score = rhythmModel.scoreEngine.scoreSystem:getSlice()

	return {json = {
		score = score,
		inputMode = noteChart.inputMode:getString(),
		modifiers = replay.modifiers,
		modifiersEncoded = modifierModel:encode(replay.modifiers),
		modifiersString = modifierModel:getString(replay.modifiers),
	}}
end


return WebReplayController
