local ListItemView = require("sphere.views.ListItemView")
local transform = require("aqua.graphics.transform")

local NoteChartSetListItemView = ListItemView:new()

NoteChartSetListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntries[1]

	self:drawValue(config.artist, noteChartDataEntry.artist)
	self:drawValue(config.title, noteChartDataEntry.title)

	if item.tagged then
		self:drawTaggedCircle(config.point)
	end
end

return NoteChartSetListItemView
