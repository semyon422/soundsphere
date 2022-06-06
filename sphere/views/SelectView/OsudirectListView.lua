local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local ListItemView = require("sphere.views.ListItemView")
local OsudirectListItemView = ListItemView:new({construct = false})

local OsudirectListView = ListView:new({construct = false})

OsudirectListView.construct = function(self)
	ListView.construct(self)
	self.itemView = OsudirectListItemView:new()
	self.itemView.listView = self
end

OsudirectListView.reloadItems = function(self)
	self.state.items = self.game.osudirectModel.items
	if self.navigator.osudirectItemIndex > #self.state.items then
		self.navigator.osudirectItemIndex = 1
		self.state.stateCounter = (self.state.stateCounter or 0) + 1
	end
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
