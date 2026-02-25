local View = require("yi.views.View")
local LayoutEnums = require("ui.layout.Enums")

---@class yi.Label : yi.View
---@overload fun(font: love.Font, text: string): yi.Label
local Label = View + {}

---@param font love.Font
---@param text string
function Label:new(font, text)
	View.new(self)
	self.text_batch = love.graphics.newText(font)
	self.text = text
	self.text_changed = false
	self.prev_w = 0
	self.prev_h = 0
end

function Label:draw()
	love.graphics.draw(self.text_batch)
end

---@param v string
function Label:setText(v)
	self.text = v
	self.text_changed = true
	self.layout_box:markDirty(LayoutEnums.Axis.Both)
end

function Label:updateTransforms()
	View.updateTransforms(self)

	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()

	if self.text_changed or w ~= self.prev_w or h ~= self.prev_h then
		self.text_changed = false
		self.prev_w = w
		self.prev_h = h
		self.text_batch:setf(self.text, w, "left")
	end
end

---@param axis_idx ui.Axis
---@param constraint number?
function Label:getIntrinsicSize(axis_idx, constraint)
	local font = self.text_batch:getFont()
	local text = self.text

	if axis_idx == LayoutEnums.Axis.X then
		return font:getWidth(text)
	else
		local width = constraint or font:getWidth(text)
		local _, lines = font:getWrap(text, width)
		return font:getHeight() * (font:getLineHeight() * (#lines - 1) + 1)
	end
end

return Label
