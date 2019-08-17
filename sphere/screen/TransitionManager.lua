local tween = require("tween")

local TransitionManager = {}

TransitionManager.shaderText = [[
	extern number alpha;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords);
		return pixel * color * alpha;
	}
]]

TransitionManager.isTransiting = false
TransitionManager.needTransit = false
TransitionManager.alpha = 1
TransitionManager.phase = 0

TransitionManager.init = function(self)
	self.shader = love.graphics.newShader(self.shaderText)
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
