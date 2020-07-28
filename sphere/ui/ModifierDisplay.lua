local Button = require("sphere.ui.Button")

local ModifierDisplay = Button:new()

ModifierDisplay.update = function(self)
	self.text = self.gui.modifierModel:getString()
	self:reload()
end

return ModifierDisplay
