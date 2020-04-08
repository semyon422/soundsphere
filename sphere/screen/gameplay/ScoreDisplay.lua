local TextDisplay = require("sphere.screen.gameplay.TextDisplay")

local ScoreDisplay = TextDisplay:new()

ScoreDisplay.getText = function(self)
	return (self.format):format(self.score.scoreTable[self.field])
end

return ScoreDisplay
