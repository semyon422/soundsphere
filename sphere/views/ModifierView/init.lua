local ScreenView = require("sphere.views.ScreenView")

local ModifierViewConfig = require("sphere.views.ModifierView.ModifierViewConfig")
local ModifierNavigator = require("sphere.views.ModifierView.ModifierNavigator")

local ModifierView = ScreenView:new({construct = false})

ModifierView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = ModifierViewConfig
	self.navigator = ModifierNavigator:new()
end

ModifierView.load = function(self)
	self.game.modifierController:load()
	ScreenView.load(self)
end

ModifierView.unload = function(self)
	self.game.modifierController:unload()
	ScreenView.unload(self)
end

return ModifierView
