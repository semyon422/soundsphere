local ScreenView = require("ui.views.ScreenView")
local just = require("just")

local Layout = require("ui.views.MultiplayerView.Layout")
local MultiplayerViewConfig = require("ui.views.MultiplayerView.MultiplayerViewConfig")

---@class ui.MultiplayerView: ui.ScreenView
---@operator call: ui.MultiplayerView
local MultiplayerView = ScreenView + {}

function MultiplayerView:load()
	self.game.selectModel:setChanged()
end

function MultiplayerView:draw()
	just.container("screen container", true)
	Layout:draw()
	MultiplayerViewConfig(self)
	just.container()
end

---@param dt number
function MultiplayerView:update(dt)
	self.game.selectController:update()

	local multiplayerModel = self.game.multiplayerModel
	if not multiplayerModel.room then
		self:changeScreen("selectView")
	elseif multiplayerModel.isPlaying then
		self:changeScreen("gameplayView")
	end
end

return MultiplayerView
