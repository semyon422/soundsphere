local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")

local ModifierIconView = Class:new()

ModifierIconView.shapes = {
	empty = {false, false, false, false, false, false, false, false},
	full = {true, true, true, true, 0.25, 0.25, 0.25, 0.25},
	topBottom = {false, true, true, false, 0.25, 0.25, 0.25, 0.25},
	bottomArcs = {false, false, false, false, nil, nil, 0.25, 0.25},
	fillCircle = {false, false, false, false, 0.5, 0.5, 0.5, 0.5},
	circleBottomRight = {false, true, false, true, 0.5, 0.5, 0.5, 0.15},
	circleTopRight = {false, false, true, true, 0.5, 0.15, 0.5, 0.5},
	allArcs = {false, false, false, false, 0.15, 0.15, 0.15, 0.15},
}

ModifierIconView.lines = {
	one = {10 / 64},
	two = {-6 / 64, 24 / 64},
}

ModifierIconView.font = {
	filename = "Noto Sans Mono",
	size = 32
}

ModifierIconView.draw = function(self)
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(config.size / 32)

	self:drawSquareBorder(self.shapes[config.shape] or self.shapes.allArcs)
	if config.modifierSubString then
		self:drawText(self.lines.two, config.modifierString, config.modifierSubString)
	else
		self:drawText(self.lines.one, config.modifierString)
	end
end

ModifierIconView.drawText = function(self, lines, topText, bottomText)
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)

	local fx = config.size / 8
	local fy = config.size / 8
	local fs = config.size * 3 / 4
	local fr = fs / 4

	local font = spherefonts.get(self.font)
	love.graphics.setFont(font)
	if topText then
		love.graphics.printf(topText, fx, fy + lines[1] * fs, 64, "center", 0, fs / 64, fs / 64)
	end
	if bottomText then
		love.graphics.printf(bottomText, fx, fy + lines[2] * fs, 64, "center", 0, fs / 64, fs / 64)
	end
end

ModifierIconView.drawSquareBorder = function(self, shape)
	local config = self.config

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(config.size / 40)

	local fx = config.size / 8
	local fy = config.size / 8
	local fs = config.size * 3 / 4
	local fr = fs / 4

	local fr1 = shape[5] and fs * shape[5] or fr
	local fr2 = shape[6] and fs * shape[6] or fr
	local fr3 = shape[7] and fs * shape[7] or fr
	local fr4 = shape[8] and fs * shape[8] or fr

	if shape[1] then
		love.graphics.line(fx, fy + fr1, fx, fy + fs - fr3)
	end
	if shape[2] then
		love.graphics.line(fx + fr3, fy + fs, fx + fs - fr4, fy + fs)
	end
	if shape[3] then
		love.graphics.line(fx + fr1, fy, fx + fs - fr2, fy)
	end
	if shape[4] then
		love.graphics.line(fx + fs, fy + fr2, fx + fs, fy + fs - fr4)
	end

	if shape[5] then
		love.graphics.arc("line", "open", fx + fr1, fy + fr1, fr1, -math.pi, -math.pi / 2, 8)
	end
	if shape[6] then
		love.graphics.arc("line", "open", fx + fs - fr2, fy + fr2, fr2, -math.pi / 2, 0, 8)
	end
	if shape[7] then
		love.graphics.arc("line", "open", fx + fr3, fy + fs - fr3, fr3, math.pi, math.pi / 2, 8)
	end
	if shape[8] then
		love.graphics.arc("line", "open", fx + fs - fr4, fy + fs - fr4, fr4 , math.pi / 2, 0, 8)
	end
end

return ModifierIconView
