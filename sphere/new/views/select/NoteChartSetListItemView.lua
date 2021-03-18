
local Node = require("aqua.util.Node")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local NoteChartSetListItemView = Node:new()

NoteChartSetListItemView.init = function(self)
	self:on("draw", self.draw)

	self.fontArtist = aquafonts.getFont(spherefonts.NotoSansRegular, 16)
	self.fontTitle = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
end

NoteChartSetListItemView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.itemIndex
	local item = self.item

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	local index = self.index
	local noteChartDataEntry = item.noteChartDataEntries[1]

	local deltaItemIndex = math.abs(itemIndex - listView.selectedItem)
	if listView.isSelected then
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.66
		)
	else
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.33
		)
	end

	if deltaItemIndex == 0 then
		love.graphics.rectangle(
			"fill",
			x,
			y + (index - 1) * h / listView.itemCount,
			cs:X(4 / cs.one),
			h / listView.itemCount
		)
	end

	love.graphics.setFont(self.fontArtist)
	love.graphics.printf(
		noteChartDataEntry.artist,
		x,
		y + (index - 1) * h / listView.itemCount,
		math.huge,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(15 / cs.one),
		-cs:Y(4 / cs.one)
	)

	love.graphics.setFont(self.fontTitle)
	love.graphics.printf(
		noteChartDataEntry.title,
		x,
		y + (index - 1) * h / listView.itemCount,
		math.huge,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(15 / cs.one),
		-cs:Y(18 / cs.one)
	)
end

return NoteChartSetListItemView
