local TextDisplay = require("sphere.game.PlayField.TextDisplay")

local ScoreDisplay = TextDisplay:new()

ScoreDisplay.getText = function(self)
	return math.floor(self.score.score)
end

return ScoreDisplay
