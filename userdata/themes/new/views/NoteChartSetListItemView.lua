
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

	local itemIndex = self.index + listView.selectedItem - math.ceil(listView.itemCount / 2)
	if not listView.items[itemIndex] then
		return
	end

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	local index = self.index
	local noteChartDataEntry = listView.items[itemIndex].noteChartDataEntries[1]

	love.graphics.setColor(1, 1, 1, 1)

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
