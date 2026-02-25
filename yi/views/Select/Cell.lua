local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Colors = require("yi.Colors")

---@class yi.SongSelectCell : yi.View
---@operator call: yi.SongSelectCell
local Cell = View + {}

---@param label_text string
function Cell:new(label_text)
	View.new(self)
	self:setHeight(70)
	self:setWidth(140)
	self:setBackgroundColor(Colors.panels)
	self.label_text = label_text
end

function Cell:load()
	View.load(self)
	local res = self:getResources()

	self.top = self:add(Label(res:getFont("regular", 16), self.label_text), {
		x = 15, y = 5
	})

	self.bottom = self:add(Label(res:getFont("bold", 36), "XXX"), {
		x = 15, y = 5 + 14
	})
end

---@param v string
function Cell:setValueText(v)
	self.bottom:setText(v)
end

function Cell:draw()
	local h = self:getCalculatedHeight()
	love.graphics.setColor(Colors.accent)
	love.graphics.setLineWidth(4)
	love.graphics.line(2, 0, 2, h)
end

return Cell
