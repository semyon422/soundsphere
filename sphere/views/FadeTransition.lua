local class = require("class")
local flux = require("flux")
local gfx_util = require("gfx_util")

local FadeTransition = class()

FadeTransition.transiting = false
FadeTransition.alpha = 1
FadeTransition.phase = 0

function FadeTransition:transitIn(callback)
	if self.transiting then
		return
	end
	self.callback = callback
	self.transiting = true
	self.phase = 1
	flux.to(self, 0.2, {alpha = 0}):ease("quadinout")
end

function FadeTransition:transitOut()
	if not self.transiting then
		return
	end
	self.phase = 2
	flux.to(self, 0.2, {alpha = 1}):ease("quadinout")
end

function FadeTransition:update(dt)
	if not self.transiting then
		return
	end

	if self.phase == 1 then
		if self.alpha == 0 then
			self.callback()
		end
	elseif self.phase == 2 then
		if self.alpha == 1 then
			self.transiting = false
		end
	end
end

function FadeTransition:drawBefore()
	if not self.transiting then
		return
	end

	love.graphics.setCanvas({gfx_util.getCanvas("FadeTransition"), stencil = true})
	love.graphics.clear()

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
