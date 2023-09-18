local FastplayController = require("sphere.controllers.FastplayController")
local WebNoteChartController = require("sphere.controllers.WebNoteChartController")

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
	local replayModel = ReplayModel()
	local selectModel = {}

	local game = {}
	game.fastplayController = fastplayController
	game.rhythmModel = rhythmModel
	game.modifierModel = modifierModel
	game.difficultyModel = difficultyModel
	game.replayModel = replayModel
	game.selectModel = selectModel

	for n, list in pairs(deps) do
		for _, m in ipairs(list) do
			if game[n] then
				game[n][m] = game[m]
			end
		end
	end

	rhythmModel.judgements = {}
	rhythmModel.settings = require("sphere.models.ConfigModel.settings")
	rhythmModel.timings = rhythmModel.settings.gameplay.timings
	rhythmModel.hp = rhythmModel.settings.gameplay.hp

	selectModel.loadNoteChart = function() return noteChart end
	selectModel.noteChartItem = noteChart.metaData

	fastplayController.game = game

	modifierModel:setConfig(replay.modifiers)
	modifierModel:fixOldFormat(replay.modifiers)

	rhythmModel.timings = replay.timings
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
