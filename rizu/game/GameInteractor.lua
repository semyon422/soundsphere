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

return GameInteractor
