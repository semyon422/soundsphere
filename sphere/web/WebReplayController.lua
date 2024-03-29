local FastplayController = require("sphere.controllers.FastplayController")
local WebNoteChartController = require("sphere.web.WebNoteChartController")

local Replay = require("sphere.models.ReplayModel.Replay")
local ReplayModel = require("sphere.models.ReplayModel")
local ModifierModel = require("sphere.models.ModifierModel")
local DifficultyModel = require("sphere.models.DifficultyModel")
local RhythmModel = require("sphere.models.RhythmModel")
local PlayContext = require("sphere.models.PlayContext")
local ModifierEncoder = require("sphere.models.ModifierEncoder")

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

	local noteChart, err = WebNoteChartController.getNoteChart(params.notechart)
	if not noteChart then
		return {status = 500, json = {error = err}}
	end

	local replay = WebReplayController.getReplay(params.replay)

	local fastplayController = FastplayController()

	local playContext = PlayContext()
	local rhythmModel = RhythmModel()
	local difficultyModel = DifficultyModel()
	local replayModel = ReplayModel(rhythmModel)
	fastplayController.rhythmModel = rhythmModel
	fastplayController.replayModel = replayModel
	fastplayController.difficultyModel = difficultyModel
	fastplayController.playContext = playContext

	rhythmModel.judgements = {}
	rhythmModel.settings = require("sphere.persistence.ConfigModel.settings")
	rhythmModel.hp = rhythmModel.settings.gameplay.hp

	playContext:load(replay)
	ModifierModel:fixOldFormat(replay.modifiers)

	rhythmModel:setTimings(replay.timings)
	replayModel.replay = replay

	fastplayController:play(noteChart, replay)

	local score = rhythmModel.scoreEngine.scoreSystem:getSlice()

	return {json = {
		score = score,
		inputMode = tostring(noteChart.inputMode),
		playContext = playContext,
		modifiers = replay.modifiers,
		modifiersEncoded = ModifierEncoder:encode(replay.modifiers),
		modifiersHash = ModifierEncoder:hash(replay.modifiers),
		modifiersString = ModifierModel:getString(replay.modifiers),
	}}
end


return WebReplayController
