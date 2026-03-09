local View = require("yi.views.View")
local Colors = require("yi.Colors")

---@class yi.Checkbox : yi.View
---@overload fun(checked: boolean, on_change: fun(checked: boolean)): yi.Checkbox
local Checkbox = View + {}

---@param checked boolean
---@param on_change fun(checked: boolean)
function Checkbox:new(checked, on_change)
	View.new(self)
	self:setup({
		w = 24,
		h = 24,
		mouse = true,
	})

	self.checked = checked or false
	self.on_change = on_change
	self.hovered = false
end

function Checkbox:onHover()
	self.hovered = true
end

function Checkbox:onHoverLost()
	self.hovered = false
end

function Checkbox:onMouseClick()
	self.checked = not self.checked
	if self.on_change then
		self.on_change(self.checked)
	end
end

function Checkbox:draw()
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()

	if self.hovered then
		love.graphics.setColor(Colors.button_hover)
	else
		love.graphics.setColor(Colors.button)
	end
	love.graphics.rectangle("fill", 0, 0, w, h)

	love.graphics.setColor(Colors.outline)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", 0, 0, w, h)

	if self.checked then
		love.graphics.setColor(Colors.accent)
		local padding = 6
		love.graphics.rectangle("fill", padding, padding, w - padding * 2, h - padding * 2)
	end
end

return Checkbox
