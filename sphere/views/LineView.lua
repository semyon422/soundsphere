
local class = require("class")
local transform = require("gfx_util").transform

---@class sphere.LineView
---@operator call: sphere.LineView
local LineView = class()

function LineView:draw()
	for _, line in ipairs(self.lines) do
		self:drawLine(line)
	end
end

---@param line table
function LineView:drawLine(line)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(line.color)
	love.graphics.setLineWidth(line.lineWidth)
	love.graphics.setLineStyle(line.lineStyle)
	love.graphics.line(line.x1, line.y1, line.x2, line.y2)
end

return LineView
