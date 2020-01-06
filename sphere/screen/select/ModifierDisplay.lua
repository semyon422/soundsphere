local Button = require("sphere.ui.Button")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")

local ModifierDisplay = Button:new()

ModifierDisplay.update = function(self)
	self.text = ModifierManager.sequence:tostring()
	self:reload()
end

return ModifierDisplay
