local TextDisplay = require("sphere.ui.TextDisplay")

local JudgeDisplay = TextDisplay:new()

JudgeDisplay.defaultValue = 0

JudgeDisplay.loadGui = function(self)
	self.timegateNames = self.data.timegateNames
	
	return TextDisplay.loadGui(self)
end

JudgeDisplay.getText = function(self)
	local timegates = self.scoreSystem.scoreTable.timegates
	local values = {}

	for _, name in ipairs(self.timegateNames) do
		values[#values + 1] = timegates[name] or self.defaultValue
	end

	return (self.format):format(unpack(values))
end

return JudgeDisplay
