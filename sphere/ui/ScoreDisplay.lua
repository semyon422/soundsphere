local TextDisplay = require("sphere.ui.TextDisplay")

local ScoreDisplay = TextDisplay:new()

ScoreDisplay.getText = function(self)
	return (self.format):format(self.scoreSystem.scoreTable[self.field] or self.defaultValue)
end

return ScoreDisplay
