local ListItemView = require("sphere.views.ListItemView")

local ScoreListItemView = ListItemView:new()

ScoreListItemView.draw = function(self)
	local scoreEntry = self.listView.rhythmModel.scoreEngine.scoreEntry
	local item = self.item

	if scoreEntry then
		item.loaded = scoreEntry.replayHash == item.scoreEntry.replayHash
	else
		item.loaded = false
	end

	return ListItemView.draw(self)
end

return ScoreListItemView
