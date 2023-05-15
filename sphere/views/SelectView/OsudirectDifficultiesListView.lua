local ListView = require("sphere.views.ListView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local just = require("just")

local OsudirectDifficultiesListView = ListView:new()

OsudirectDifficultiesListView.rows = 5

OsudirectDifficultiesListView.reloadItems = function(self)
	self.items = self.game.osudirectModel:getDifficulties()
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

OsudirectDifficultiesListView.drawItem = function(self, i, w, h)
	local item = self.items[i]

	just.indent(22)
	TextCellImView(math.huge, h, "left", item.beatmapset.creator, item.version)
end

return OsudirectDifficultiesListView
