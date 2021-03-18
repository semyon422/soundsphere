
local Node = require("aqua.util.Node")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ScoreListItemView = Node:new()

ScoreListItemView.init = function(self)
	self:on("draw", self.draw)

	self.fontScore = aquafonts.getFont(spherefonts.NotoMonoRegular, 24)
	self.fontAccuracy = aquafonts.getFont(spherefonts.NotoMonoRegular, 24)
	self.fontCombo = aquafonts.getFont(spherefonts.NotoMonoRegular, 24)
	self.fontDate = aquafonts.getFont(spherefonts.NotoMonoRegular, 16)
	self.fontModifiers = aquafonts.getFont(spherefonts.NotoMonoRegular, 16)
	self.header = aquafonts.getFont(spherefonts.NotoSansRegular, 16)
end

ScoreListItemView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.itemIndex
	local item = self.item

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	local index = self.index
	local scoreEntry = item.scoreEntry

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

	if itemIndex == listView.selectedItem then
		love.graphics.setFont(self.header)
		love.graphics.printf(
			"accuracy",
			x,
			y + (index - 1) * h / listView.itemCount,
			w / cs.one * 1080 / 3,
			"right",
			0,
			cs.one / 1080,
			cs.one / 1080,
			cs:X(22 / cs.one),
			-cs:Y(4 / cs.one)
		)

		love.graphics.setFont(self.header)
		love.graphics.printf(
			"score",
			x + w / 3,
			y + (index - 1) * h / listView.itemCount,
			w / cs.one * 1080 / 3,
			"right",
			0,
			cs.one / 1080,
			cs.one / 1080,
			cs:X(22 / cs.one),
			-cs:Y(4 / cs.one)
		)

		love.graphics.setFont(self.header)
		love.graphics.printf(
			"pp",
			x + 2 * w / 3,
			y + (index - 1) * h / listView.itemCount,
			w / cs.one * 1080 / 3,
			"right",
			0,
			cs.one / 1080,
			cs.one / 1080,
			cs:X(22 / cs.one),
			-cs:Y(4 / cs.one)
		)
	end

	love.graphics.setFont(self.fontScore)
	love.graphics.printf(
		("%0.2f"):format(scoreEntry.accuracy),
		x,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080 / 3,
		"right",
		0,
		cs.one / 1080,
		cs.one / 1080,
		cs:X(22 / cs.one),
		-cs:Y(23 / cs.one)
	)

	love.graphics.setFont(self.fontAccuracy)
	love.graphics.printf(
		math.floor(scoreEntry.score),
		x + w / 3,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080 / 3,
		"right",
		0,
		cs.one / 1080,
		cs.one / 1080,
		cs:X(22 / cs.one),
		-cs:Y(23 / cs.one)
	)

	love.graphics.setFont(self.fontCombo)
	love.graphics.printf(
		"999",
		-- ("%d"):format(scoreEntry.maxCombo),
		x + 2 * w / 3,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080 / 3,
		"right",
		0,
		cs.one / 1080,
		cs.one / 1080,
		cs:X(22 / cs.one),
		-cs:Y(23 / cs.one)
	)

	love.graphics.setFont(self.fontDate)
	love.graphics.printf(
		"10 seconds ago",
		-- os.date("%H:%M:%S %d.%m.%y", scoreEntry.time),
		x,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080 / 2,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(22 / cs.one),
		-cs:Y(50 / cs.one)
	)

	love.graphics.setFont(self.fontModifiers)
	love.graphics.printf(
		scoreEntry.modifiers,
		x + w / 2,
		y + (index - 1) * h / listView.itemCount,
		w / cs.one * 1080 / 2,
		"right",
		0,
		cs.one / 1080,
		cs.one / 1080,
		cs:X(22 / cs.one),
		-cs:Y(50 / cs.one)
	)
end

return ScoreListItemView
