local View = require("yi.views.View")
local Colors = require("yi.Colors")

---@class yi.TabButton : yi.View
---@overload fun(tab: table, callback: function): yi.TabButton
local TabButton = View + {}

---@param tab table Tab definition with icon, text, content
---@param callback function Called when button is clicked
function TabButton:new(tab, callback)
	View.new(self)
	self.tab = tab
	self.callback = callback
	self.is_active = false
	self.handles_mouse_input = true
end

function TabButton:load()
	self:setup({
		arrange = "flex_row",
		align_items = "center",
		padding = {10, 10, 10, 10},
		gap = 5
	})

	if self.tab.icon then
		self:add(self.tab.icon)
	end
	if self.tab.text then
		self:add(self.tab.text)
	end
end

function TabButton:onMouseDown()
	self.callback()
	return true
end

function TabButton:draw()
	if self.is_active then
		love.graphics.setColor(Colors.accent)
	elseif self.mouse_over then
		love.graphics.setColor(Colors.button_hover)
	else
		love.graphics.setColor(Colors.button)
	end
	love.graphics.rectangle("fill", 0, 0, self:getCalculatedWidth(), self:getCalculatedHeight())
end

---@param active boolean
function TabButton:setActive(active)
	self.is_active = active
end

return TabButton
