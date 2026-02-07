local class = require("class")

---@class rizu.GameInteractor
---@operator call: rizu.GameInteractor
local GameInteractor = class()

---@param game sphere.GameController
function GameInteractor:new(game)
	self.game = game
end

function GameInteractor:loadGameplaySelectedChart()
	local game = self.game
	game.gameplayInteractor:loadGameplay(game.selectModel.chartview)
end

---@param itemIndex integer?
function GameInteractor:loadScoreAsync(itemIndex)
	local game = self.game

	local scoreEntry = game.selectModel.scoreItem
	if itemIndex then
		scoreEntry = game.selectModel.scoreLibrary.items[itemIndex]
	end

	game.resultController:replayNoteChartAsync("result", scoreEntry)

	if itemIndex then
		game.selectModel:scrollScore(nil, itemIndex)
	end
end

return GameInteractor
