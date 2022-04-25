local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local OsudirectListItemView = require(viewspackage .. "SelectView.OsudirectListItemView")

local OsudirectListView = ListView:new({construct = false})

OsudirectListView.construct = function(self)
	ListView.construct(self)
	self.itemView = OsudirectListItemView:new()
	self.itemView.listView = self
end

OsudirectListView.reloadItems = function(self)
	self.state.items = self.gameController.osudirectModel.items
end

OsudirectListView.getItemIndex = function(self)
	return self.navigator.osudirectItemIndex or 1
end

OsudirectListView.scrollUp = function(self)
	self.navigator:scrollOsudirect("up")
end

OsudirectListView.scrollDown = function(self)
	self.navigator:scrollOsudirect("down")
end

return OsudirectListView
