local FastplayController = require("sphere.controllers.FastplayController")
local ResultController = require("sphere.controllers.ResultController")
local WebNoteChartController = require("sphere.controllers.WebNoteChartController")

local Replay = require("sphere.models.ReplayModel.Replay")
local ReplayModel = require("sphere.models.ReplayModel")
local ModifierModel = require("sphere.models.ModifierModel")
local DifficultyModel = require("sphere.models.DifficultyModel")
local RhythmModel = require("sphere.models.RhythmModel")

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

	local noteChart = WebNoteChartController.getNoteCharts(params.notechart)[1]
	local noteChartDataEntry = noteChart.metaData

	local replay = WebReplayController.getReplay(params.replay)

	local fastplayController = FastplayController:new()

	local rhythmModel = RhythmModel:new()
	local modifierModel = ModifierModel:new()
	local noteChartModel = {}
	local difficultyModel = DifficultyModel:new()
	local replayModel = ReplayModel:new()

	local game = {}
	game.fastplayController = fastplayController
	game.rhythmModel = rhythmModel
	game.modifierModel = modifierModel
	game.noteChartModel = noteChartModel
	game.difficultyModel = difficultyModel
	game.replayModel = replayModel

	for k, v in pairs(game) do
		v.game = game
	end

	rhythmModel.judgements = {}
	rhythmModel.settings = require("sphere.models.ConfigModel.settings")
	rhythmModel.timings = rhythmModel.settings.gameplay.timings
	rhythmModel.hp = rhythmModel.settings.gameplay.hp

	noteChartModel.noteChart = noteChart
	noteChartModel.load = function() end
	noteChartModel.loadNoteChart = function() return noteChart end

	noteChartModel.noteChartDataEntry = noteChartDataEntry

	fastplayController.game = game

	modifierModel:setConfig(replay.modifiers)
	modifierModel:fixOldFormat(replay.modifiers, not replay.timings)

	if replay.timings then
		rhythmModel.timings = replay.timings
	else
		rhythmModel.timings = ResultController.oldTimings
	end
	replayModel.replay = replay
	replayModel:setMode("replay")
	rhythmModel.inputManager:setMode("internal")

	fastplayController:play()

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
