local Class = require("aqua.util.Class")
local tween = require("tween")

local FadeTransition = Class:new()

FadeTransition.shaderText = [[
	extern number alpha;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords);
		return pixel * color * alpha;
	}
]]

FadeTransition.transiting = false
FadeTransition.needResume = false
FadeTransition.alpha = 1
FadeTransition.phase = 0

FadeTransition.checkShader = function(self)
	if not love.graphics then
		return
	end
	if not self.shader then
		self.shader = love.graphics.newShader(self.shaderText)
	end
	return true
end

FadeTransition.fadeIn = function(self)
	self.transiting = true
	self.phase = 1
	self.needResume = false
	self.tween = tween.new(0.1, self, {alpha = 0}, "inOutQuad")
end

FadeTransition.fadeOut = function(self)
	self.phase = 2
	self.needResume = false
	self.tween = tween.new(0.1, self, {alpha = 1}, "inOutQuad")
end

FadeTransition.update = function(self, dt)
	if not self.transiting then
		return
	end

	self.tween:update(dt)

	if self.phase == 1 then
		if self.alpha == 0 then
			self.needResume = true
		end
	elseif self.phase == 2 then
		if self.alpha == 1 then
			self.transiting = false
			self.needResume = true
		end
	end
end

FadeTransition.drawBefore = function(self)
	if not self.transiting or not self:checkShader() then
		return
	end

	love.graphics.setShader(self.shader)
	self.shader:send("alpha", self.alpha)
end

FadeTransition.drawAfter = function(self)
	if not self.transiting or not self:checkShader() then
		return
	end

	love.graphics.setShader()
end

return FadeTransition
