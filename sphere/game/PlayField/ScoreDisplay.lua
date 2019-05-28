local TextDisplay = require("sphere.game.PlayField.TextDisplay")

local ScoreDisplay = TextDisplay:new()

ScoreDisplay.getText = function(self)
	return ("%06d"):format(self.score.score)
end

return ScoreDisplay
