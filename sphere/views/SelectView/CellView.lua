local just = require("just")
local Class = require("aqua.util.Class")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local CellView = Class:new()

CellView.drawCell = function(self, cellType, valueType, size, name, value)
	if type(value) == "nil" then
		value = 0
	end

	self:drawCellName(cellType, size, name)
	if valueType == "text" then
		self:drawTextCell(cellType, size, value)
	elseif valueType == "bar" then
		self:drawBarCell(cellType, size, value)
	end

	just.nextline(size * cellType.w, cellType.h)
end

CellView.drawCellName = function(self, cellType, size, name)
	love.graphics.setColor(1, 1, 1, 1)

	local t = cellType
	size = size or 1

	local text = t.value.text
	local limit = size * t.w - t.name.x - t.name.xr
	local x = text.x
	if text.align == "right" then
		x = x - t.w
		limit = limit + t.w
	end

	love.graphics.setFont(spherefonts.get(t.name.font))
	baseline_print(
		name,
		x,
		t.name.baseline,
		limit,
		1,
		t.name.align
	)
end

CellView.drawTextCell = function(self, cellType, size, value)
	love.graphics.setColor(1, 1, 1, 1)

	local t = cellType
	size = size or 1

	local text = t.value.text
	local limit = size * t.w - t.name.x - t.name.xr
	local x = text.x
	if text.align == "right" then
		x = x - t.w
		limit = limit + t.w
	end

	love.graphics.setFont(spherefonts.get(text.font))
	baseline_print(
		value,
		x,
		text.baseline,
		limit,
		1,
		text.align
	)
end

CellView.drawBarCell = function(self, cellType, size, value)
	love.graphics.setColor(1, 1, 1, 1)

	local t = cellType
	size = size or 1

	local w = size * t.w
	local bar = t.value.bar

	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle(
		"fill",
		bar.x,
		bar.y,
		w - bar.x - bar.xr,
		bar.h,
		bar.h / 2,
		bar.h / 2
	)

	if value == 0 then
		return
	end

	love.graphics.setColor(1, 1, 1, 0.75)
	love.graphics.rectangle(
		"fill",
		bar.x,
		bar.y,
		(w - bar.x - bar.xr - bar.h) * value + bar.h,
		bar.h,
		bar.h / 2,
		bar.h / 2
	)
end

return CellView
