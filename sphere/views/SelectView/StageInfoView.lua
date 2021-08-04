local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")

local StageInfoView = Class:new()

StageInfoView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

StageInfoView.draw = function(self)
	for _, cell in ipairs(self.config.cells) do
		self:drawCellName(cell)
		if cell.valueType == "text" then
			self:drawTextCell(cell)
		elseif cell.valueType == "bar" then
			self:drawBarCell(cell)
		end
	end
end

StageInfoView.drawCellName = function(self, cell)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)

	local cx, dcw
	if type(cell.x) == "table" then
		cx = cell.type.x[cell.x[1]]
		dcw = cell.type.x[cell.x[2]] - cell.type.x[cell.x[1]]
	else
		cx = cell.type.x[cell.x]
		dcw = 0
	end

	local fontName = spherefonts.get(cell.type.name.fontFamily, cell.type.name.fontSize)
	love.graphics.setFont(fontName)
	baseline_print(
		cell.name,
		cs:X((config.x + cx + cell.type.name.x) / screen.h, true),
		cs:Y((config.y + cell.type.y[cell.y] + cell.type.name.baseline) / screen.h, true),
		cell.type.name.limit + dcw,
		cs.one / screen.h,
		cell.type.name.align
	)
end

StageInfoView.drawTextCell = function(self, cell)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)

	local cx, dcw
	if type(cell.x) == "table" then
		cx = cell.type.x[cell.x[1]]
		dcw = cell.type.x[cell.x[2]] - cell.type.x[cell.x[1]]
	else
		cx = cell.type.x[cell.x]
		dcw = 0
	end

	local fontValue = spherefonts.get(cell.type.value.text.fontFamily, cell.type.value.text.fontSize)
	love.graphics.setFont(fontValue)
	baseline_print(
		"0",
		cs:X((config.x + cx + cell.type.value.text.x) / screen.h, true),
		cs:Y((config.y + cell.type.y[cell.y] + cell.type.value.text.baseline) / screen.h, true),
		cell.type.value.text.limit + dcw,
		cs.one / screen.h,
		cell.type.value.text.align
	)
end

StageInfoView.drawBarCell = function(self, cell)
	local cs = self.cs
	local config = self.config
	local screen = self.config.screen

	love.graphics.setColor(1, 1, 1, 1)

	local cx, dcw
	if type(cell.x) == "table" then
		cx = cell.type.x[cell.x[1]]
		dcw = cell.type.x[cell.x[2]] - cell.type.x[cell.x[1]]
	else
		cx = cell.type.x[cell.x]
		dcw = 0
	end

	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle(
		"fill",
		cs:X((config.x + cx + cell.type.value.bar.x) / screen.h, true),
		cs:Y((config.y + cell.type.y[cell.y] + cell.type.value.bar.y) / screen.h, true),
		cs:X((cell.type.value.bar.w + dcw) / screen.h),
		cs:Y(cell.type.value.bar.h / screen.h),
		cs:X(cell.type.value.bar.h / 2 / screen.h),
		cs:Y(cell.type.value.bar.h / 2 / screen.h)
	)

	love.graphics.setColor(1, 1, 1, 0.75)
	love.graphics.rectangle(
		"fill",
		cs:X((config.x + cx + cell.type.value.bar.x) / screen.h, true),
		cs:Y((config.y + cell.type.y[cell.y] + cell.type.value.bar.y) / screen.h, true),
		cs:X((cell.type.value.bar.w + dcw) / 3 / screen.h),
		cs:Y(cell.type.value.bar.h / screen.h),
		cs:X(cell.type.value.bar.h / 2 / screen.h),
		cs:Y(cell.type.value.bar.h / 2 / screen.h)
	)
end

return StageInfoView
