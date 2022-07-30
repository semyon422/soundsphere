local ListView = require("sphere.views.ListView")

local OsudirectListView = ListView:new({construct = false})

OsudirectListView.reloadItems = function(self)
	self.items = self.game.osudirectModel.items
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

OsudirectListView.scroll = function(self, count)
	ListView.scroll(self, count)
	self.game.osudirectModel:setBeatmap(self.items[self.targetItemIndex])
end

return OsudirectListView
