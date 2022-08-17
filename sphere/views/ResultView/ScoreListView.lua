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

	local scoreEngine = self.game.rhythmModel.scoreEngine
	local scoreEntry = scoreEngine.scoreEntry
	local loaded = scoreEntry and scoreEntry.replayHash == item.replayHash

	if just.button(item, just.is_over(w, h)) then
		self.screenView:loadScore(i)
	end

	if item.isTop then
		love.graphics.circle("fill", 44, 36, 7)
	end
	if loaded or item.isTop then
		love.graphics.circle("line", 44, 36, 7)
	end

	local rating = item.rating
	local timeRate = item.timeRate
	local inputMode = item.inputMode

	if loaded then
		local erfunc = require("libchart.erfunc")
		local ratingHitTimingWindow = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow
		local normalscore = scoreEngine.scoreSystem.normalscore
		local s = erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2)))
		rating = s * scoreEngine.enps

		timeRate = scoreEngine.timeRate or timeRate
		inputMode = scoreEngine.inputMode or inputMode
	end

	if rating ~= rating then
		rating = "nan"
	end

	local cw = (w - 44) / 5

	local scoreSourceName = self.game.scoreLibraryModel.scoreSourceName
	if scoreSourceName == "online" then
		return self:drawItemOnline(i, w, h)
	end

	just.row(true)
	just.indent(22)
	TextCellImView(cw, h, "right", i == 1 and "rank" or "", item.rank, true)
	TextCellImView(cw, h, "right", i == 1 and "rating" or "", Format.difficulty(rating), true)
	TextCellImView(cw, h, "right", i == 1 and "time rate" or "", Format.timeRate(timeRate), true)
	TextCellImView(cw * 2, h, "right", item.time ~= 0 and time_ago_in_words(item.time) or "never", Format.inputMode(inputMode))
	just.row(false)
end

ScoreListView.drawItemOnline = function(self, i, w, h)
	local item = self.items[i]
	w = (w - 44) / 7

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", i == 1 and "rank" or "", item.rank)
	TextCellImView(w, h, "right", i == 1 and "rating" or "", Format.difficulty(item.rating))
	TextCellImView(w, h, "right", i == 1 and "rate" or "", Format.timeRate(item.modifierset.timerate))
	TextCellImView(w, h, "right", i == 1 and "mode" or "", Format.inputMode(item.inputmode))
	TextCellImView(w * 3, h, "right", item.time ~= 0 and time_ago_in_words(item.created_at) or "never", item.user.name)
	just.row(false)
end

return ScoreListView
