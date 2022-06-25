local just = require("just")
local ListItemView = require("sphere.views.ListItemView")

local NoteChartListItemView = ListItemView:new({construct = false})

NoteChartListItemView.draw = function(self, w, h)
	local changed, active, hovered = just.button_behavior(self.item, self:isOver(w, h))

	local navigator = self.listView.navigator
	if changed == 1 then
		navigator:play()
	elseif changed == 2 then
		navigator:result()
	end

	ListItemView.draw(self)
end

return NoteChartListItemView
