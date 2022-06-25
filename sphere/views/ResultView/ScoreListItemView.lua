local just = require("just")
local ListItemView = require("sphere.views.ListItemView")

local ScoreListItemView = ListItemView:new({construct = false})

ScoreListItemView.draw = function(self, w, h)
	local scoreEntry = self.listView.game.rhythmModel.scoreEngine.scoreEntry
	local item = self.item

	item.loaded = scoreEntry and scoreEntry.replayHash == item.replayHash

	if just.button_behavior(item, self:isOver(w, h)) then
		self.listView.navigator:loadScore(self.itemIndex)
	end

	return ListItemView.draw(self)
end

return ScoreListItemView
