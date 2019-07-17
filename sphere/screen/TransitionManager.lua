local Rectangle = require("aqua.graphics.Rectangle")
local CS = require("aqua.graphics.CS")
local Stencil = require("aqua.graphics.Stencil")
local tween = require("tween")

local TransitionManager = {}

TransitionManager.shader = love.graphics.newShader([[
extern number alpha;
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	vec4 pixel = Texel(texture, texture_coords);
	return pixel * color * alpha;
}
]])

TransitionManager.isTransiting = false
TransitionManager.needTransit = false
TransitionManager.alpha = 1
TransitionManager.phase = 0
TransitionManager.stencilColor = {0, 0, 0, 255}
TransitionManager.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

TransitionManager.init = function(self)
	self.stencilFrame = Rectangle:new({
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		cs = self.cs,
		mode = "fill",
		color = self.stencilColor
	})
	
	self:reload()
end

TransitionManager.reload = function(self)
	self.cs:reload()
	self.stencilFrame:reload()
end

TransitionManager.receive = function(self, event)
	if event.name == "resize" then
		return self:reload()
	end
end

TransitionManager.update = function(self, dt)
	if self.phase == 0 then
		return
	end
	
	if self.phase == 1 then
		self.phase = 2
		self.tween = tween.new(0.1, self, {alpha = 0}, "inOutQuad")
	end
	if self.phase == 2 then
		self.tween:update(dt)
		if self.alpha == 0 then
			self.phase = 3
			if self.callbackMiddle then
				self.callbackMiddle()
				self.callbackMiddle = false
			end
		end
	end
	if self.phase == 3 then
		self.phase = 4
		self.tween = tween.new(0.1, self, {alpha = 1}, "inOutQuad")
	end
	if self.phase == 4 then
		self.tween:update(dt)
		if self.alpha == 1 then
			self.phase = 0
			self.needTransit = false
			if self.callbackEnd then
				self.callbackEnd()
				self.callbackEnd = false
			end
		end
	end
	
	self.stencilFrame.color[4] = self.alpha
end

TransitionManager.transit = function(self, callbackMiddle, callbackEnd)
	if self.needTransit then
		return
	end
	
	self.callbackMiddle = callbackMiddle
	self.callbackEnd = callbackEnd
	
	self.needTransit = true
	self.phase = 1
end

TransitionManager.drawBefore = function(self)
	if not self.needTransit then
		return
	end
	self.isTransiting = true
	
	love.graphics.setShader(self.shader)
	self.shader:send("alpha", self.alpha)
end

TransitionManager.drawAfter = function(self)
	if not self.isTransiting then
		return
	end
	
	love.graphics.setShader()
	self.isTransiting = false
end

return TransitionManager
