local View = require("yi.views.View")
local Label = require("yi.views.Label")

---@class yi.JudgeCell : yi.View
---@operator call: yi.JudgeCell
local JudgeCell = View + {}

---@param cell_color yi.Color
---@param value number
function JudgeCell:new(cell_color, value)
	View.new(self)
	self.cell_color = cell_color
	self.value = tostring(value)
end

function JudgeCell:load()
	View.load(self)
	self:setWidth(133)
	self:setHeight(55)

	local c = self.cell_color
	c[4] = 0.3
	self:setBackgroundColor(c)
	c[4] = 1

	local res = self:getResources()

	self.label = self:add(Label(res:getFont("bold", 24), self.value), {
		justify_self = "center",
		align_self = "center",
	})

	self:add(View(), {
		w = "100%",
		justify_self = "end",
		h = 8,
		background_color = c
	})
end

---@param v string
function JudgeCell:setText(v)
	self.label:setText(v)
end

return JudgeCell
