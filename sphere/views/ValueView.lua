local spherefonts = require("sphere.assets.fonts")
local gfx_util = require("gfx_util")
local inside = require("table_util").inside
local class = require("class")

---@class sphere.ValueView
---@operator call: sphere.ValueView
local ValueView = class()

function ValueView:load()
	local font = self.font
	if font.filename then
		font[1], font[2] = font.filename, font.size
	end
	self.fontObject = spherefonts.get(unpack(font))
end

function ValueView:draw()
	local tf = gfx_util.transform(self.transform)
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

	gfx_util.printBaseline(
		tostring(value),
		self.x,
		self.baseline,
		self.limit,
		1,
		self.align
	)
end

return ValueView
