local View = require("yi.views.View")

---@class yi.Modals : yi.View
---@operator call: yi.Modals
local Modals = View + {}

local imgui_ctx = {}

function Modals:new()
	View.new(self)
	self:setWidth("100%")
	self:setHeight("100%")
	self.handles_keyboard_input = true
end

---@param m function
function Modals:setImguiModal(m)
	imgui_ctx.game = self:getGame()

	if self.imgui_modal == m then
		self.imgui_modal = nil
	else
		self.imgui_modal = m
	end
end

function Modals:onKeyDown(e)
	if e.key == "escape" then
		self.imgui_modal = nil
	end
end

function Modals:draw()
	if self.imgui_modal then
		self.imgui_modal(imgui_ctx)
	end
end

return Modals
