local transform = require("gfx_util").transform
local ProgressView = require("sphere.views.GameplayView.ProgressView")

---@class sphere.CircleProgressView: sphere.ProgressView
---@operator call: sphere.CircleProgressView
local CircleProgressView = ProgressView + {}

function CircleProgressView:draw()
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	local x, y, r = self.x, self.y, self.r
    local a1, a2 = self:getArc()

	love.graphics.setLineWidth(1)

	love.graphics.setColor(self.backgroundColor)
	love.graphics.arc("fill", "pie", x, y, r, a1, a2, 36)
	love.graphics.setColor(self.foregroundColor)
	love.graphics.circle("line", x, y, r)
end

---@return number
---@return number
function CircleProgressView:getArc()
	local a, b = self:getForm()
	return (a - 1 / 4) * math.pi * 2, (b + a - 1 / 4) * math.pi * 2
end

return CircleProgressView
