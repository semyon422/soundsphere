local ModalImView = require("sphere.imviews.ModalImView")
local just = require("just")

local ModifierViewConfig = require("sphere.views.ModifierView.ModifierViewConfig")

local activeList = "modifierList"
return ModalImView(function(self)
	if not self then
		return true
	end

	ModifierViewConfig(self)

	if just.keypressed("f1") then
		return true
	end
end)
