local Class = require("aqua.util.Class")
local TextTooltipImView = require("sphere.views.TextTooltipImView")

local TooltipView = Class:new()

TooltipView.draw = function(self)
	if self.text then
		TextTooltipImView(self.text)
	end
	self.text = nil
end

return TooltipView
