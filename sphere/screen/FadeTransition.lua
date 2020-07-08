local tween = require("tween")

local FadeTransition = {}

FadeTransition.shaderText = [[
	extern number alpha;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords);
		return pixel * color * alpha;
	}
]]

FadeTransition.isTransiting = false
FadeTransition.needTransit = false
FadeTransition.alpha = 1
FadeTransition.phase = 0

FadeTransition.init = function(self)
	self.shader = love.graphics.newShader(self.shaderText)
end

FadeTransition.update = function(self, dt)
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
end

FadeTransition.transit = function(self, callbackMiddle, callbackEnd)
	if self.needTransit then
		return
	end

	self.callbackMiddle = callbackMiddle
	self.callbackEnd = callbackEnd

	self.needTransit = true
	self.phase = 1
end

FadeTransition.drawBefore = function(self)
	if not self.needTransit then
		return
	end
	self.isTransiting = true

	love.graphics.setShader(self.shader)
	self.shader:send("alpha", self.alpha)
end

FadeTransition.drawAfter = function(self)
	if not self.isTransiting then
		return
	end

	love.graphics.setShader()
	self.isTransiting = false
end

FadeTransition:init()

return FadeTransition
