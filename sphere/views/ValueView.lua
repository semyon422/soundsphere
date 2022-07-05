local spherefonts = require("sphere.assets.fonts")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")
local Class = require("aqua.util.Class")

local ValueView = Class:new()

ValueView.load = function(self)
	local font = self.font
	if font.filename then
		font[1], font[2] = font.filename, font.size
	end
	self.fontObject = spherefonts.get(unpack(font))
end

ValueView.draw = function(self)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setFont(self.fontObject)
	love.graphics.setColor(self.color)

	local format = self.format
	local value = self.value or inside(self, self.key)
	if value then
		if type(value) == "function" then
			value = value(self)
		end
		if self.multiplier and tonumber(value) then
			value = value * self.multiplier
		end
		if type(format) == "string" then
			value = format:format(value)
		elseif type(format) == "function" then
			value = format(value)
		end
	end

	baseline_print(
		tostring(value),
		self.x,
		self.baseline,
		self.limit,
		1,
		self.align
	)
end

return ValueView
