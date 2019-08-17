local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")

local TableMenu = Class:new()

TableMenu.x = 0
TableMenu.y = 0
TableMenu.w = 1
TableMenu.h = 1
TableMenu.cols = 1
TableMenu.rows = 1
TableMenu.padding = 0

TableMenu.construct = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

TableMenu.apply = function(self, object, colStart, rowStart, colEnd, rowEnd, padding)
	padding = padding or self.padding
	rowEnd = rowEnd or rowStart
	colEnd = colEnd or colStart
	local colWidth = self.w / self.cols
	local rowHeight = self.h / self.rows
	
	object.cs = self.cs
	object.x = (colStart - 1) * colWidth + padding
	object.y = (rowStart - 1) * rowHeight + padding
	object.w = colWidth * (colEnd - colStart + 1) - 2 * padding
	object.h = rowHeight * (rowEnd - rowStart + 1) - 2 * padding
end

return TableMenu
