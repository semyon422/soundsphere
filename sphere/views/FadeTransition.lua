local class = require("class")
local flux = require("flux")
local gfx_util = require("gfx_util")

---@class sphere.FadeTransition
---@operator call: sphere.FadeTransition
local FadeTransition = class()

FadeTransition.alpha = 1
FadeTransition.duration = 0.2

---@param cf function
function FadeTransition:transit(cf)
	if self.coroutine then
		return
	end
	self.coroutine = coroutine.create(function()
		cf()
		self.coroutine = nil
	end)
	assert(coroutine.resume(self.coroutine))
end

---@param start_alpha number
---@param target_alpha number
function FadeTransition:transitAsync(start_alpha, target_alpha)
	self.alpha = start_alpha
	self.target_alpha = target_alpha
	flux.to(self, self.duration, {alpha = self.target_alpha}):ease("quadinout")
	coroutine.yield()
end

function FadeTransition:update()
	if self.coroutine and self.target_alpha == self.alpha then
		assert(coroutine.resume(self.coroutine))
	end
end

function FadeTransition:drawBefore()
	if not self.coroutine then
		return
	end

	love.graphics.setCanvas({gfx_util.getCanvas("FadeTransition"), stencil = true})
	love.graphics.clear(0, 0, 0, 1)

	self.isCanvasSet = true
end

function FadeTransition:drawAfter()
	if not self.isCanvasSet then
		return
	end

	love.graphics.setCanvas()
	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, self.alpha)
	love.graphics.draw(gfx_util.getCanvas("FadeTransition"))

	self.isCanvasSet = false
end

return FadeTransition
