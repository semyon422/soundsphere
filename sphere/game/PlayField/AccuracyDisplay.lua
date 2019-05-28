local TextDisplay = require("sphere.game.PlayField.TextDisplay")

local AccuracyDisplay = TextDisplay:new()

AccuracyDisplay.getText = function(self)
	return ("%0.2f"):format(self.score.accuracy)
end

return AccuracyDisplay
