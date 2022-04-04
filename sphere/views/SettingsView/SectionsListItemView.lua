local viewspackage = (...):match("^(.-%.views%.)")

local ListItemView = require(viewspackage .. "ListItemView")

local SectionsListItemView = ListItemView:new()

SectionsListItemView.draw = function(self)
	local item = self.item
	item.section = item[1].section

	ListItemView.draw(self)
end

return SectionsListItemView
