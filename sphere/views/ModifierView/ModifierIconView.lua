local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
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

ModifierIconView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

ModifierIconView.draw = function(self)
	local config = self.config
	local screen = config.screen
	local cs = self.cs

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(cs:X(config.size / 32 / screen.h))

	self:drawSquareBorder(self.shapes.allArcs)
	if config.modifierSubString then
		self:drawText(self.lines.two, config.modifierString, config.modifierSubString)
	else
		self:drawText(self.lines.one, config.modifierString)
	end
end

ModifierIconView.drawText = function(self, lines, topText, bottomText)
	local config = self.config
	local screen = config.screen
	local cs = self.cs

	local fx = config.x + config.size / 8
	local fy = config.y + config.size / 8
	local fs = config.size * 3 / 4
	local fr = fs / 4

	local font = spherefonts.get("Noto Sans Mono", 32)
	love.graphics.setFont(font)
	if topText then
		love.graphics.printf(
			topText,
			cs:X(fx / screen.h, true),
			cs:Y((fy + lines[1] * fs) / screen.h, true),
			64,
			"center",
			0,
			cs.one / screen.h * fs / 64,
			cs.one / screen.h * fs / 64
		)
	end
	if bottomText then
		love.graphics.printf(
			bottomText,
			cs:X(fx / screen.h, true),
			cs:Y((fy + lines[2] * fs) / screen.h, true),
			64,
			"center",
			0,
			cs.one / screen.h * fs / 64,
			cs.one / screen.h * fs / 64
		)
	end
end

ModifierIconView.drawSquareBorder = function(self, shape)
	local config = self.config
	local screen = config.screen
	local cs = self.cs

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(cs:X(config.size / 40 / screen.h))

	local fx = config.x + config.size / 8
	local fy = config.y + config.size / 8
	local fs = config.size * 3 / 4
	local fr = fs / 4

	local fr1 = shape[5] and fs * shape[5] or fr
	local fr2 = shape[6] and fs * shape[6] or fr
	local fr3 = shape[7] and fs * shape[7] or fr
	local fr4 = shape[8] and fs * shape[8] or fr

	if shape[1] then
		love.graphics.line(
			cs:X(fx / screen.h, true),
			cs:Y((fy + fr1) / screen.h, true),
			cs:X(fx / screen.h, true),
			cs:Y((fy + fs - fr3) / screen.h, true)
		)
	end
	if shape[2] then
		love.graphics.line(
			cs:X((fx + fr3) / screen.h, true),
			cs:Y((fy + fs) / screen.h, true),
			cs:X((fx + fs - fr4) / screen.h, true),
			cs:Y((fy + fs) / screen.h, true)
		)
	end
	if shape[3] then
		love.graphics.line(
			cs:X((fx + fr1) / screen.h, true),
			cs:Y(fy / screen.h, true),
			cs:X((fx + fs - fr2) / screen.h, true),
			cs:Y(fy / screen.h, true)
		)
	end
	if shape[4] then
		love.graphics.line(
			cs:X((fx + fs) / screen.h, true),
			cs:Y((fy + fr2) / screen.h, true),
			cs:X((fx + fs) / screen.h, true),
			cs:Y((fy + fs - fr4) / screen.h, true)
		)
	end

	if shape[5] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fr1) / screen.h, true),
			cs:Y((fy + fr1) / screen.h, true),
			cs:X(fr1 / screen.h),
			-math.pi,
			-math.pi / 2,
			8
		)
	end
	if shape[6] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fs - fr2) / screen.h, true),
			cs:Y((fy + fr2) / screen.h, true),
			cs:X(fr2 / screen.h),
			-math.pi / 2,
			0,
			8
		)
	end
	if shape[7] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fr3) / screen.h, true),
			cs:Y((fy + fs - fr3) / screen.h, true),
			cs:X(fr3 / screen.h),
			math.pi,
			math.pi / 2,
			8
		)
	end
	if shape[8] then
		love.graphics.arc(
			"line",
			"open",
			cs:X((fx + fs - fr4) / screen.h, true),
			cs:Y((fy + fs - fr4) / screen.h, true),
			cs:X(fr4 / screen.h),
			math.pi / 2,
			0,
			8
		)
	end
end

return ModifierIconView
