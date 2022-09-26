
local Class = require("aqua.util.Class")
local inside = require("aqua.util.inside")

local GaussianBlurView = Class:new()

GaussianBlurView.load = function(self)
	self:setSigma(0)
	self.drawCanvas = love.graphics.newCanvas()
	self.shaderCanvas = love.graphics.newCanvas()
end

GaussianBlurView.draw = function(self)
	local blur = math.ceil(self.blur.value or inside(self, self.blur.key) or 0)
	if blur == 0 then
		return
	end

	self:setSigma(blur)

	if not self.enabled then
		self:enable()
		self.enabled = true
	else
		self:disable()
		self.enabled = false
	end
end

-- https://github.com/vrld/moonshine/blob/master/gaussianblur.lua
GaussianBlurView.createBlurShader = function(self)
	local sigma = self.sigma
	sigma = sigma > 0 and sigma or 1
	local range = math.max(1, math.floor(3 * sigma + 0.5))
	local norm = 0

	local code = {[[
		extern vec2 direction;
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
		{vec4 c = vec4(0.0);
	]]}
	local blur_line = "c += vec4(%f) * Texel(texture, texture_coords + vec2(%f) * direction);"

	for i = -range, range do
		local k = math.exp(-i ^ 2 / (2 * sigma ^ 2))
		norm = norm + k
		table.insert(code, blur_line:format(k, i))
	end

	table.insert(code, ("return c * vec4(%f) * color;}"):format(1 / norm))

	self.shader = love.graphics.newShader(table.concat(code))
	self.direction = {1, 1}
end

GaussianBlurView.setSigma = function(self, sigma)
	if sigma and self.sigma ~= sigma then
		self.sigma = sigma
		self:createBlurShader()
	end
end

GaussianBlurView.enable = function(self)
	local width, height = love.graphics.getDimensions()

	local drawCanvas = self.drawCanvas
	local shaderCanvas = self.shaderCanvas
	local cw, ch = shaderCanvas:getDimensions()
	if cw ~= width or ch ~= height then
		self.drawCanvas = love.graphics.newCanvas(width, height)
		self.shaderCanvas = love.graphics.newCanvas(width, height)
		drawCanvas = self.drawCanvas
		shaderCanvas = self.shaderCanvas
	end

	self.oldShader = love.graphics.getShader()
	self.oldCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(drawCanvas)
	love.graphics.clear(0, 0, 0, 0)
end

GaussianBlurView.disable = function(self)
	local shader = self.shader
	local direction = self.direction
	local drawCanvas = self.drawCanvas
	local shaderCanvas = self.shaderCanvas
	local oldShader = self.oldShader
	local oldCanvas = self.oldCanvas
	local width, height = love.graphics.getDimensions()

	love.graphics.origin()
	love.graphics.setCanvas(shaderCanvas)
	love.graphics.clear(0, 0, 0, 0)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setShader(shader)

	direction[1] = 1 / width
	direction[2] = 0
	shader:send("direction", direction)
	love.graphics.draw(drawCanvas, 0, 0)

	direction[1] = 0
	direction[2] = 1 / height
	shader:send("direction", direction)
	love.graphics.setCanvas(oldCanvas)
	love.graphics.draw(shaderCanvas, 0, 0)
	love.graphics.setShader(oldShader)
end

return GaussianBlurView
