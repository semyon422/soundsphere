local ListView = require("sphere.views.ListView")

local OsudirectDifficultiesListView = ListView:new({construct = false})

OsudirectDifficultiesListView.reloadItems = function(self)
	self.items = self.game.osudirectModel:getDifficulties()
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

return OsudirectDifficultiesListView
