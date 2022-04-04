
local Class = require("aqua.util.Class")
local inside = require("aqua.util.inside")

local GaussianBlurView = Class:new()

GaussianBlurView.sigma = 16

GaussianBlurView.load = function(self)
	local state = self.state

	self:setSigma(self.sigma)
	state.drawCanvas = love.graphics.newCanvas()
	state.shaderCanvas = love.graphics.newCanvas()
end

GaussianBlurView.draw = function(self)
	local config = self.config
	local state = self.state

	local blur = config.blur.value or inside(self, config.blur.key)
	if blur == 0 then
		return
	end

	if state.sigma ~= blur then
		self:setSigma(blur)
	end

	if not state.enabled then
		self:enable()
		state.enabled = true
	else
		self:disable()
		state.enabled = false
	end
end

-- https://github.com/vrld/moonshine/blob/master/gaussianblur.lua
GaussianBlurView.createBlurShader = function(self)
	local state = self.state

	local sigma = state.sigma
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

	state.shader = love.graphics.newShader(table.concat(code))
	state.direction = {1, 1}
end

GaussianBlurView.setSigma = function(self, sigma)
	local state = self.state
	if sigma and state.sigma ~= sigma then
		state.sigma = sigma
		self:createBlurShader()
	end
end

GaussianBlurView.enable = function(self)
	local state = self.state
	local width, height = love.graphics.getDimensions()

	local drawCanvas = state.drawCanvas
	local shaderCanvas = state.shaderCanvas
	local cw, ch = shaderCanvas:getDimensions()
	if cw ~= width or ch ~= height then
		state.drawCanvas = love.graphics.newCanvas(width, height)
		state.shaderCanvas = love.graphics.newCanvas(width, height)
		drawCanvas = state.drawCanvas
		shaderCanvas = state.shaderCanvas
	end

	state.oldShader = love.graphics.getShader()
	state.oldCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(drawCanvas)
	love.graphics.clear(0, 0, 0, 0)
end

GaussianBlurView.disable = function(self)
	local state = self.state

	local shader = state.shader
	local direction = state.direction
	local drawCanvas = state.drawCanvas
	local shaderCanvas = state.shaderCanvas
	local oldShader = state.oldShader
	local oldCanvas = state.oldCanvas
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
