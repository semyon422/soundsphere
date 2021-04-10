local TextDisplay = require("sphere.ui.TextDisplay")

local ScoreDisplay = TextDisplay:new()

ScoreDisplay.getText = function(self)
	if self.type == "boolean" then
		return self.scoreSystem:get(self.field) and self.trueValue or self.falseValue
	end
	return (self.format):format(self.scoreSystem:get(self.field) or self.defaultValue)
end

return ScoreDisplay
