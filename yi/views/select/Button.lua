local View = require("yi.views.View")
local Colors = require("yi.Colors")

---@class yi.Button : yi.View
---@overload fun(callback: function): yi.Button
---@field visual_margin number
local Button = View + {}

---@param callback function
function Button:new(callback)
	View.new(self)
	self.callback = callback
	self.handles_mouse_input = true
end

function Button:onMouseDown(_)
	self.callback()
	return true
end

function Button:draw()
	if self.mouse_over then
		love.graphics.setColor(Colors.button_hover)
	else
		love.graphics.setColor(Colors.button)
	end

	love.graphics.rectangle("fill", 0, 0, self:getCalculatedWidth(), self:getCalculatedHeight(), 8, 8)
end

return Button
