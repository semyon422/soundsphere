local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")
local time_util = require("aqua.time_util")

local StageInfoView = Class:new()

StageInfoView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	for _, cell in ipairs(self.cells) do
		if not cell.show or cell.show(self) then
			love.graphics.replaceTransform(tf)
			self:drawCellName(cell)
			love.graphics.replaceTransform(tf)
			if cell.valueType == "text" then
				self:drawTextCell(cell)
			elseif cell.valueType == "bar" then
				self:drawBarCell(cell)
			end
		end
	end
end

StageInfoView.drawCellName = function(self, cell)
	love.graphics.setColor(1, 1, 1, 1)

	local t = cell.type

	local cx = t.x[cell.x]
	local cy = t.y[cell.y]
	local dcw = ((cell.size or 1) - 1) * t.w

	love.graphics.setFont(spherefonts.get(unpack(t.name.font)))
	baseline_print(
		cell.name,
		cx + t.name.x,
		cy + t.name.baseline,
		t.name.limit + dcw,
		1,
		t.name.align
	)
end

StageInfoView.drawTextCell = function(self, cell)
	love.graphics.setColor(1, 1, 1, 1)

	local t = cell.type

	local cx = t.x[cell.x]
	local cy = t.y[cell.y]
	local dcw = ((cell.size or 1) - 1) * t.w

	local value = cell.value or inside(self, cell.key)
	if type(value) == "nil" then
		value = 0
	end
	if type(value) == "function" then
		value = value(self)
	end
	if cell.format then
		local format = cell.format
		if cell.multiplier and tonumber(value) then
			value = value * cell.multiplier
		end
		if type(format) == "string" then
			value = format:format(value)
		elseif type(format) == "function" then
			value = format(value)
		end
	elseif cell.time then
		value = time_util.format(tonumber(value) or 0)
	elseif cell.ago then
		value = tonumber(value) or 0
		value = value ~= 0 and time_util.time_ago_in_words(value, cell.parts, cell.suffix) or "never"
	end

	local text = t.value.text

	love.graphics.setFont(spherefonts.get(unpack(text.font)))
	baseline_print(
		value,
		cx + text.x,
		cy + text.baseline,
		text.limit + dcw,
		1,
		text.align
	)
end

StageInfoView.drawBarCell = function(self, cell)
	love.graphics.setColor(1, 1, 1, 1)

	local t = cell.type

	local cx = t.x[cell.x]
	local cy = t.y[cell.y]
	local dcw = ((cell.size or 1) - 1) * t.w

	local bar = t.value.bar

	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle(
		"fill",
		cx + bar.x,
		cy + bar.y,
		bar.w + dcw,
		bar.h,
		bar.h / 2,
		bar.h / 2
	)

	local value = cell.value or inside(self, cell.key) or 0
	if value == 0 then
		return
	end

	love.graphics.setColor(1, 1, 1, 0.75)
	love.graphics.rectangle(
		"fill",
		cx + bar.x,
		cy + bar.y,
		(bar.w + dcw - bar.h) * value + bar.h,
		bar.h,
		bar.h / 2,
		bar.h / 2
	)
end

return StageInfoView
