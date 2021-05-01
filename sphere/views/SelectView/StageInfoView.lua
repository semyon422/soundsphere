local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local StageInfoView = Class:new()

StageInfoView.construct = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

StageInfoView.draw = function(self)
    for _, cell in ipairs(self.config.cells) do
        self:drawCell(cell)
    end
end

StageInfoView.drawCell = function(self, cell)
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

	local fontName = aquafonts.getFont(spherefonts.NotoSansRegular, cell.type.name.fontSize)
	love.graphics.setFont(fontName)
	love.graphics.printf(
		cell.name,
		cs:X((config.x + cx + cell.type.name.x) / screen.h, true),
		cs:Y((config.y + cell.type.y[cell.y] + cell.type.name.y) / screen.h, true),
		cell.type.name.w + dcw,
		cell.type.name.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)

	local fontValue = aquafonts.getFont(spherefonts.NotoSansRegular, cell.type.value.fontSize)
	love.graphics.setFont(fontValue)
	love.graphics.printf(
		"0",
		cs:X((config.x + cx + cell.type.value.x) / screen.h, true),
		cs:Y((config.y + cell.type.y[cell.y] + cell.type.value.y) / screen.h, true),
		cell.type.value.w + dcw,
		cell.type.value.align,
		0,
		cs.one / screen.h,
		cs.one / screen.h
	)
end

return StageInfoView
