local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local ListItemView = require("sphere.views.ListItemView")
local OsudirectDifficultyListItemView = ListItemView:new({construct = false})

local OsudirectDifficultiesListView = ListView:new({construct = false})

OsudirectDifficultiesListView.construct = function(self)
	ListView.construct(self)
	self.itemView = OsudirectDifficultyListItemView:new()
	self.itemView.listView = self
end

OsudirectDifficultiesListView.reloadItems = function(self)
	self.state.items = self.gameController.osudirectModel:getDifficulties()
end

OsudirectDifficultiesListView.getItemIndex = function(self)
	return self.navigator.osudirectDifficultyItemIndex or 1
end

OsudirectDifficultiesListView.scrollUp = function(self)
	self.navigator:scrollOsudirectDifficulty("up")
end

OsudirectDifficultiesListView.scrollDown = function(self)
	self.navigator:scrollOsudirectDifficulty("down")
end

return OsudirectDifficultiesListView
