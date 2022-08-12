local Navigator = require("sphere.views.Navigator")

local MultiplayerNavigator = Navigator:new({construct = false})

MultiplayerNavigator.load = function(self)
	Navigator.load(self)
	self.activeList = "modifierList"
end

MultiplayerNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local s = event[2]
	local modifierModel = self.game.modifierModel
	local modifierView = self.game.gameView.modifierView
	if modifierView.isOpen then
		if self.activeList == "modifierList" then
			if s == "up" then modifierModel:scrollModifier(-1)
			elseif s == "down" then modifierModel:scrollModifier(1)
			elseif s == "tab" then self.activeList = "availableModifierList"
			elseif s == "return" then
			elseif s == "backspace" then modifierModel:remove()
			elseif s == "right" then modifierModel:increaseModifierValue(nil, 1)
			elseif s == "left" then modifierModel:increaseModifierValue(nil, -1)
			end
		elseif self.activeList == "availableModifierList" then
			if s == "up" then modifierModel:scrollAvailableModifier(-1)
			elseif s == "down" then modifierModel:scrollAvailableModifier(1)
			elseif s == "tab" then self.activeList = "modifierList"
			elseif s == "return" then modifierModel:add()
			end
		end
		if s == "f1" then modifierView:toggle(false) end
		return
	end
end

return MultiplayerNavigator
