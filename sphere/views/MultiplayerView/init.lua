local ScreenView = require("sphere.views.ScreenView")
local just = require("just")

local MultiplayerViewConfig = require("sphere.views.MultiplayerView.MultiplayerViewConfig")

local MultiplayerView = ScreenView:new()

MultiplayerView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = MultiplayerViewConfig
end

MultiplayerView.load = function(self)
	ScreenView.load(self)
	self.game.selectModel:setChanged()
end

MultiplayerView.draw = function(self)
	just.container("screen container", true)
	ScreenView.draw(self)
	just.container()
end

MultiplayerView.update = function(self, dt)
	self.game.selectController:update(dt)

	local multiplayerModel = self.game.multiplayerModel
	if not self.isChangingScreen then
		if not multiplayerModel.room then
			self:changeScreen("selectView")
		elseif multiplayerModel.isPlaying then
			self:changeScreen("gameplayView")
		end
	end

	ScreenView.update(self, dt)
end

return MultiplayerView
