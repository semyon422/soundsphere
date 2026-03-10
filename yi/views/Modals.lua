local View = require("yi.views.View")

---@class yi.Modals : yi.View
---@operator call: yi.Modals
local Modals = View + {}

local imgui_ctx = {}

function Modals:new()
	View.new(self)
	self:setWidth("100%")
	self:setHeight("100%")
end

---@param m function?
function Modals:setImguiModal(m)
	imgui_ctx.game = self:getGame()

	if m == nil or self.imgui_modal == m then
		self.imgui_modal = nil
		self.handles_keyboard_input = false
		self.handles_mouse_input = false
	else
		self.imgui_modal = m
		self.handles_keyboard_input = true
		self.handles_mouse_input = true
	end
end

function Modals:onKeyDown(e)
	if e.key == "escape" then
		self:setImguiModal()
	end
	return true
end

function Modals:draw()
	if self.imgui_modal then
		self.imgui_modal(imgui_ctx)
	end
end

return Modals
