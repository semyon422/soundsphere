local ListItemView = require("sphere.views.ListItemView")

local NoteChartSetListItemView = ListItemView:new()

NoteChartSetListItemView.draw = function(self)
	local item = self.item
	item.noteChartDataEntry = item.noteChartDataEntries[1]

	ListItemView.draw(self)
end

return NoteChartSetListItemView
