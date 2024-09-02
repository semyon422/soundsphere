local ModalImView = require("ui.imviews.ModalImView")
local just = require("just")

local ModifierViewConfig = require("ui.views.ModifierView.ModifierViewConfig")

local activeList = "modifierList"
return ModalImView(function(self, quit)
	if quit then
		return true
	end

	ModifierViewConfig(self)

	if just.keypressed("f1") then
		return true
	end
end)
