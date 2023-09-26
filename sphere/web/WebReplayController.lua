local FastplayController = require("sphere.controllers.FastplayController")
local WebNoteChartController = require("sphere.web.WebNoteChartController")

local Replay = require("sphere.models.ReplayModel.Replay")
local ReplayModel = require("sphere.models.ReplayModel")
local ModifierModel = require("sphere.models.ModifierModel")
local DifficultyModel = require("sphere.models.DifficultyModel")
local RhythmModel = require("sphere.models.RhythmModel")

local deps = require("sphere.deps")

local WebReplayController = {}

WebReplayController.getReplay = function(replay)
	local file = io.open(replay.path, "r")
	if not file then
		error("Replay not found")
	end
	local content = file:read("*a")
	file:close()

	return Replay():fromString(content)
end

function WebReplayController:POST()
	local params = self.params

	local noteCharts, err = WebNoteChartController.getNoteCharts(params.notechart)
	if not noteCharts then
		return {status = 500, json = {error = err}}
	end

	local noteChart = noteCharts[1]

	local replay = WebReplayController.getReplay(params.replay)

	local fastplayController = FastplayController()

	local rhythmModel = RhythmModel()
	local modifierModel = ModifierModel()
	local difficultyModel = DifficultyModel()
	local replayModel = ReplayModel(
		rhythmModel,
		modifierModel
	)
	fastplayController.rhythmModel = rhythmModel
	fastplayController.replayModel = replayModel
	fastplayController.modifierModel = modifierModel
	fastplayController.difficultyModel = difficultyModel

	rhythmModel.judgements = {}
	rhythmModel.settings = require("sphere.persistence.ConfigModel.settings")
	rhythmModel.hp = rhythmModel.settings.gameplay.hp

	modifierModel:setConfig(replay.modifiers)
	modifierModel:fixOldFormat(replay.modifiers)

	rhythmModel.timings = replay.timings
	replayModel.replay = replay

	fastplayController:play(noteChart, replay)

	local score = rhythmModel.scoreEngine.scoreSystem:getSlice()

	return {json = {
		score = score,
		inputMode = tostring(noteChart.inputMode),
		modifiers = replay.modifiers,
		modifiersEncoded = modifierModel:encode(replay.modifiers),
		modifiersString = modifierModel:getString(replay.modifiers),
	}}
end


return WebReplayController
