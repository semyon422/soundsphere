local Class = require("aqua.util.Class")
local Button = require("aqua.ui.Button")

local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")

local JudgeTable = Class:new()

JudgeTable.rowHeight = 0.05
JudgeTable.x = 0.5
JudgeTable.y = 0.25
JudgeTable.load = function(self)
	self.buttons = {}
	for i = 1, #self.score.timegates do
		self.buttons[i] = Button:new({
			cs = self.cs,
			x = self.x,
			y = self.y + (i - 1) * self.rowHeight,
			w = 0.5,
			h = self.rowHeight,
			text = self.score.timegates[i].name .. (self.score.judges[i] or 0),
			rectangleColor = {255, 255, 255, 7},
			textColor = {255, 255, 255, 255},
			mode = "fill",
			limit = 0.5,
			textAlign = {x = "left", y = "center"},
			font = aquafonts.getFont(spherefonts.NotoSansRegular, 16)
		})
		self.buttons[i]:reload()
	end
end

JudgeTable.compute = function(self)

end

JudgeTable.reload = function(self)
	for i = 1, #self.buttons do
		self.buttons[i]:reload()
	end
end

JudgeTable.draw = function(self)
	for i = 1, #self.buttons do
		self.buttons[i]:draw()
	end
end

return JudgeTable
