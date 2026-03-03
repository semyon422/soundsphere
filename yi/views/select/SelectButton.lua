local View = require("yi.views.View")
local Colors = require("yi.Colors")

---@class yi.SelectButton : yi.View
---@overload fun(): yi.Button
---@field callback function?
---@field icon string?
---@field text string?
local SelectButton = View + {}

local GAP = 5

function SelectButton:load()
	View.load(self)
	self.handles_mouse_input = true

	local res = self:getResources()
	self.icon_batch = love.graphics.newText(res:getFont("icons", 24), self.icon)
	self.text_batch = love.graphics.newText(res:getFont("bold", 16), self.text)
	self.icon_x = 0
	self.icon_y = 0
	self.text_x = 0
	self.text_y = 0
end

function SelectButton:updateTransforms()
	View.updateTransforms(self)
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()

	local iw, ih = self.icon_batch:getDimensions()
	local tw, th = self.text_batch:getDimensions()

	local gap = (iw > 0 and tw > 0) and GAP or 0
	local total_w = iw + gap + tw
	self.icon_x = math.floor((w - total_w) / 2)
	self.icon_y = math.floor((h - ih) / 2)

	self.text_x = self.icon_x + iw + gap
	self.text_y = math.floor((h - th) / 2)
end

function SelectButton:onMouseDown(_)
	if self.callback then
		self.callback()
	end
	return true
end

function SelectButton:draw()
	local r = Colors.accent[1]
	local g = Colors.accent[2]
	local b = Colors.accent[3]
	local a = 1

	if not self.mouse_over then
		a = 0.5
	end

	love.graphics.setColor(r, g, b, a)
	love.graphics.rectangle("fill", 0, 0, self:getCalculatedWidth(), self:getCalculatedHeight(), 8, 8)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.draw(self.icon_batch, self.icon_x, self.icon_y)
	love.graphics.draw(self.text_batch, self.text_x, self.text_y)
end

SelectButton.Setters = setmetatable({
	callback = true,
	icon = true,
	text = true,
}, {__index = View.Setters})

return SelectButton
