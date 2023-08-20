local class = require("class")

---@class sphere.StepperView
---@operator call: sphere.StepperView
local StepperView = class()

---@param w number
---@param h number
---@return boolean
---@return boolean
---@return boolean
function StepperView:isOver(w, h)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	local inh = 0 <= my and my <= h
	return
		0 <= mx and mx <= w and inh,
		0 <= mx and mx <= h and inh,
		w - h <= mx and mx <= w and inh
end

---@param w number
---@param h number
---@param value number
---@param count number
function StepperView:draw(w, h, value, count)
	love.graphics.setColor(1, 1, 1, 1)

	local ty = h / 3
	local by = 2 * h / 3
	local my = h / 2

	local rx1 = h / 2
	local lx1 = rx1 - h / 6

	local lx2 = rx1 + w - h
	local rx2 = lx2 + h / 6

    if value > 1 then
		love.graphics.polygon(
			"fill",
			rx1, ty,
			lx1, my,
			rx1, by
		)
    end
    if value < count then
		love.graphics.polygon(
			"fill",
			lx2, ty,
			rx2, my,
			lx2, by
		)
    end
end

return StepperView
