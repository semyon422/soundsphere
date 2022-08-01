local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.views.SelectView.TextCellImView")
local Format = require("sphere.views.Format")
local time_ago_in_words = require("aqua.util").time_ago_in_words

local ScoreListView = ListView:new({construct = false})

ScoreListView.reloadItems = function(self)
	self.stateCounter = self.game.selectModel.scoreStateCounter
	self.items = self.game.scoreLibraryModel.items
end

ScoreListView.getItemIndex = function(self)
	return self.game.selectModel.scoreItemIndex
end

ScoreListView.scroll = function(self, delta)
	self.game.selectModel:scrollScore(delta)
end

ScoreListView.drawItem = function(self, i, w, h)
	local item = self.items[i]
	w = (w - 44) / 5

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", i == 1 and "rank" or "", item.rank)
	TextCellImView(w, h, "right", i == 1 and "rating" or "", Format.difficulty(item.rating))
	TextCellImView(w, h, "right", i == 1 and "time rate" or "", Format.timeRate(item.timeRate))
	if just.mouse_over(i .. "a", just.is_over(-w, h), "mouse") then
		self.game.gameView.tooltipView.text = ("%0.2fX"):format(item.timeRate)
	end
	TextCellImView(w * 2, h, "right", item.time ~= 0 and time_ago_in_words(item.time) or "never", Format.inputMode(item.inputMode))
	if just.mouse_over(i .. "b", just.is_over(-w * 2, h), "mouse") then
		self.game.gameView.tooltipView.text = os.date("%c", item.time)
	end
	just.row(false)
end

return ScoreListView
