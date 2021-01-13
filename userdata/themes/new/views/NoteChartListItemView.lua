
local Node = require("aqua.util.Node")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local NoteChartListItemView = Node:new()

NoteChartListItemView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	self.fontCreator = aquafonts.getFont(spherefonts.NotoSansRegular, 16)
	self.fontInputMode = aquafonts.getFont(spherefonts.NotoSansRegular, 16)
	self.fontDifficulty = aquafonts.getFont(spherefonts.NotoMonoRegular, 24)
end

NoteChartListItemView.draw = function(self)
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
	local noteChartDataEntry = listView.items[itemIndex].noteChartDataEntry

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(self.fontName)
	love.graphics.printf(
		noteChartDataEntry.name,
		x,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(120 / cs.one),
		-cs:Y(18 / cs.one)
	)

	love.graphics.setFont(self.fontCreator)
	love.graphics.printf(
		noteChartDataEntry.creator,
		x,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(120 / cs.one),
		-cs:Y(4 / cs.one)
	)

	love.graphics.setFont(self.fontInputMode)
	love.graphics.printf(
		noteChartDataEntry.inputMode,
		x,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(15 / cs.one),
		-cs:Y(4 / cs.one)
	)

	love.graphics.setFont(self.fontDifficulty)
	love.graphics.printf(
		("%.2f"):format(noteChartDataEntry.noteCount / noteChartDataEntry.length / 3),
		x,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(15 / cs.one),
		-cs:Y(23 / cs.one)
	)
end

return NoteChartListItemView
