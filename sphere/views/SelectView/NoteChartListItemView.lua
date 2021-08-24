local ListItemView = require("sphere.views.ListItemView")
local transform = require("aqua.graphics.transform")

local NoteChartListItemView = ListItemView:new()

NoteChartListItemView.draw = function(self)
	local config = self.listView.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)
	love.graphics.setColor(1, 1, 1, 1)

	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntry

	local prevItem = self.prevItem
	local nextItem = self.nextItem

	self:drawValue(config.name, noteChartDataEntry.name)

	if not prevItem or prevItem.noteChartDataEntry.creator ~= item.noteChartDataEntry.creator then
		self:drawValue(config.creator, noteChartDataEntry.creator)
	end

	if not prevItem or prevItem.noteChartDataEntry.inputMode ~= item.noteChartDataEntry.inputMode then
		self:drawValue(config.inputMode, noteChartDataEntry.inputMode)
	end

	local difficulty = noteChartDataEntry.noteCount / noteChartDataEntry.length / 3
	local format = "%.2f"
	if difficulty >= 10 then
		format = "%.1f"
	elseif difficulty >= 100 then
		format = "%d"
	elseif difficulty >= 1000 then
		format = "%s"
		difficulty = "???"
	end
	self:drawValue(config.difficulty, format:format(difficulty))

	if item.tagged then
		self:drawTaggedCircle(config.point)
	end
end

return NoteChartListItemView
