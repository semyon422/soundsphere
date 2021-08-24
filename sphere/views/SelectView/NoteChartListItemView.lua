local ListItemView = require("sphere.views.ListItemView")

local NoteChartListItemView = ListItemView:new()

NoteChartListItemView.draw = function(self)
	local item = self.item
	local noteChartDataEntry = item.noteChartDataEntry

	local difficulty = noteChartDataEntry.noteCount / noteChartDataEntry.length / 3
	local format = "%.2f"
	if difficulty >= 10 then
		format = "%.1f"
	elseif difficulty >= 100 then
		format = "%s"
		difficulty = "100+"
	end
	item.difficulty = format:format(difficulty)

	ListItemView.draw(self)
end

return NoteChartListItemView
