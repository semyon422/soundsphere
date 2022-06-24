local transform = require("aqua.graphics.transform")
local ListItemView = require("sphere.views.ListItemView")

local NoteChartListItemView = ListItemView:new({construct = false})

NoteChartListItemView.receive = function(self, event)
	if event.name ~= "mousepressed" then
		return
	end

	local listView = self.listView
	if self.itemIndex ~= listView.game.selectModel.noteChartItemIndex then
		return
	end

	local x, y, w, h = listView:getItemPosition(self.itemIndex)
	local tf = transform(listView.transform):translate(listView.x, listView.y)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	if (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		local button = event[3]
		if button == 1 then
			listView.navigator:play()
		elseif button == 2 then
			listView.navigator:result()
		end
	end
end

return NoteChartListItemView
