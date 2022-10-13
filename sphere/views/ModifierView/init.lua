local ModalImView = require("sphere.imviews.ModalImView")
local just = require("just")

local ModifierViewConfig = require("sphere.views.ModifierView.ModifierViewConfig")

local activeList = "modifierList"
return ModalImView(function(self)
	if not self then
		return true
	end

	ModifierViewConfig(self)

	local kp = just.keypressed

	local close
	local modifierModel = self.game.modifierModel
	if activeList == "modifierList" then
		if kp("up") then modifierModel:scrollModifier(-1)
		elseif kp("down") then modifierModel:scrollModifier(1)
		elseif kp("tab") then activeList = "availableModifierList"
		elseif kp("return") then
		elseif kp("backspace") then modifierModel:remove()
		elseif kp("right") then modifierModel:increaseModifierValue(nil, 1)
		elseif kp("left") then modifierModel:increaseModifierValue(nil, -1)
		end
	elseif activeList == "availableModifierList" then
		if kp("up") then modifierModel:scrollAvailableModifier(-1)
		elseif kp("down") then modifierModel:scrollAvailableModifier(1)
		elseif kp("tab") then activeList = "modifierList"
		elseif kp("return") then modifierModel:add()
		end
	end
	if kp("f1") then close = true end

	return close
end)
