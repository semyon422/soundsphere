local just = require("just")
local just_print = require("just.print")
local spherefonts		= require("sphere.assets.fonts")
local time_ago_in_words = require("aqua.util").time_ago_in_words
local _transform = require("aqua.graphics.transform")

local ScrollBarView = require("sphere.views.ScrollBarView")
local RectangleView = require("sphere.views.RectangleView")
local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ScoreListView	= require("sphere.views.ResultView.ScoreListView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local StageInfoView = require("sphere.views.SelectView.StageInfoView")
local MatchPlayersView	= require("sphere.views.GameplayView.MatchPlayersView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local BarCellImView = require("sphere.imviews.BarCellImView")
local IconButtonImView = require("sphere.imviews.IconButtonImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local LabelImView = require("sphere.imviews.LabelImView")
local JudgementBarImView = require("sphere.imviews.JudgementBarImView")
local JudgementsDropdownView = require("sphere.views.ResultView.JudgementsDropdownView")
local Format = require("sphere.views.Format")

local inspect = require("inspect")
local rtime = require("aqua.util.rtime")
local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformLeft = {0, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local showLoadedScore = function(self)
	local scoreEntry = self.game.rhythmModel.scoreEngine.scoreEntry
	local scoreItem = self.game.selectModel.scoreItem
	if not scoreEntry or not scoreItem then
		return
	end
	return scoreItem.id == scoreEntry.id
end

local function getRect(out, r)
	if not out then
		return r.x, r.y, r.w, r.h
	end
	out.x = r.x
	out.y = r.y
	out.w = r.w
	out.h = r.h
end

local Layout = require("sphere.views.ResultView.Layout")

local BackgroundBlurSwitch = GaussianBlurView:new({
	blur = {key = "game.configModel.configs.settings.graphics.blur.result"}
})

local Background = BackgroundView:new({
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "game.configModel.configs.settings.graphics.dim.result"},
})

local drawGraph = function(self)
	getRect(self, Layout.graphs)
	local padding = 18 * math.sqrt(2) / 2
	self.x = self.x + padding
	self.y = self.y + padding
	self.w = self.w - padding * 2
	self.h = self.h - padding * 2
	self.__index.draw(self)
end

local ComboGraph = PointGraphView:new({
	transform = transform,
	draw = drawGraph,
	radius = 1.5,
	color = {1, 1, 0.25, 1},
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "base.combo",
	unit = "base.noteCount",
	point = function(time, startTime, endTime, value, unit)
		local x = (time - startTime) / (endTime - startTime)
		local y = -value / unit + 1
		return x, y
	end,
	show = showLoadedScore
})

local perfectColor = {1, 1, 1, 1}
local notPerfectColor = {1, 0.6, 0.4, 1}
local HitGraph = PointGraphView:new({
	transform = transform,
	draw = drawGraph,
	radius = 1.5,
	color = function(time, startTime, endTime, value, unit)
		if math.abs(value) <= 0.016 then
			return perfectColor
		end
		return notPerfectColor
	end,
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "misc.deltaTime",
	unit = 0.16,
	point = function(time, startTime, endTime, value, unit)
		if math.abs(value) > 0.12 then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		local y = value / unit / 2 + 0.5
		return x, y
	end,
	show = showLoadedScore
})

local EarlyLateMissGraph = PointGraphView:new({
	transform = transform,
	draw = drawGraph,
	radius = 3,
	color = {1, 0.2, 0.2, 1},
	background = true,
	backgroundColor = {1, 1, 1, 1},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "misc.deltaTime",
	unit = 0.16,
	point = function(time, startTime, endTime, value, unit)
		if math.abs(value) <= 0.12 or math.abs(value) > 0.16 then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		local y = math.min(math.max(value, -0.16), 0.16) / unit / 2 + 0.5
		return x, y
	end,
	show = showLoadedScore
})

local MissGraph = PointGraphView:new({
	transform = transform,
	draw = drawGraph,
	radius = 1,
	color = {1, 0.6, 0.6, 1},
	background = true,
	backgroundColor = {1, 1, 1, 0},
	backgroundRadius = 3,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "base.isMiss",
	unit = 0.16,
	line = function(time, startTime, endTime, value, unit)
		if not value then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		return x
	end,
	show = showLoadedScore
})

local HpGraph = PointGraphView:new({
	transform = transform,
	draw = drawGraph,
	radius = 1.5,
	color = {0.25, 1, 0.5, 1},
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "hp.hp",
	unit = "hp.allHp",
	point = function(time, startTime, endTime, value, unit)
		local x = (time - startTime) / (endTime - startTime)
		local y = -value / unit + 1
		return x, y
	end,
	show = showLoadedScore
})

local ScoreList = ScoreListView:new({
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3row2)
		love.graphics.replaceTransform(_transform(transform))
		love.graphics.setColor(1, 1, 1, 0.8)
		local h = self.h / self.rows
		local c = math.floor(self.rows / 2)
		love.graphics.polygon("fill",
			self.x, self.y + h * (c + 0.2) + (72 - h) / 2,
			self.x + h / 2 * 0.6, self.y + h * (c + 0.5) + (72 - h) / 2,
			self.x, self.y + h * (c + 0.8) + (72 - h) / 2
		)
		self.__index.draw(self)
	end,
	rows = 5,
})

local ScoreScrollBar = ScrollBarView:new({
	transform = transform,
	list = ScoreList,
	draw = function(self)
		getRect(self, Layout.column3row2)
		self.x = self.x + self.w - 16
		self.w = 16
		self.__index.draw(self)
	end,
	backgroundColor = {1, 1, 1, 0},
	color = {1, 1, 1, 0.66}
})

local Title = {draw = function(self)
	local noteChartDataEntry = self.game.noteChartModel.noteChartDataEntry

	getRect(self, Layout.title_middle)
	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(self.x + 22, self.y)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 36))

	love.graphics.translate(0, 15)
	local artist_title = ("%s — %s"):format(noteChartDataEntry.artist, noteChartDataEntry.title)
	local creator_name = ("%s — %s"):format(noteChartDataEntry.creator, noteChartDataEntry.name)
	just.text(artist_title)
	just.text(creator_name)
end}

local Judgements = {draw = function(self)
	local show = showLoadedScore(self)
	local scoreEngine = self.game.rhythmModel.scoreEngine
	local scoreItem = self.game.selectModel.scoreItem
	local judgement = scoreEngine.scoreSystem.judgement

	if not judgement or not scoreItem then
		return
	end

	local padding = 24

	getRect(self, Layout.column1row2)
	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(self.x + padding, self.y + padding)

	local w = self.w - padding * 2

	local counterName = self.game.configModel.configs.select.judgements
	local counters = judgement.counters
	local judgementLists = judgement.judgementLists
	local counter = counters[counterName]

	local base = scoreEngine.scoreSystem.base

	local count = counters.all.count

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local perfect = show and counter.perfect or scoreItem.perfect
	local notPerfect = show and counter["not perfect"] or scoreItem.notPerfect
	local miss = show and base.missCount or scoreItem.missCount

	local interval = 5
	local lineHeight = 40

	if show then
		for _, name in ipairs(judgementLists[counterName]) do
			JudgementBarImView(w, lineHeight, counters[counterName][name] / count, name, counters[counterName][name])
			just.emptyline(interval)
		end
	else
		JudgementBarImView(w, lineHeight, perfect / count, "perfect", perfect)
		just.emptyline(interval)
		JudgementBarImView(w, lineHeight, notPerfect / count, "not perfect", notPerfect)
	end

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(self.x + padding, self.y - padding + self.h - lineHeight)

	JudgementBarImView(w, lineHeight, miss / count, "miss", miss)
end}

local JudgementsDropdown = JudgementsDropdownView:new({
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1row1)
		local size = 1 / 3
		self.x = self.x + self.w * (1 - size) - 6 - 20
		self.w = self.w * size
		self.h = 55
		self.y = self.y + (72 - self.h) / 2
		self.__index.draw(self)
	end,
})

local JudgementsAccuracy = {
	draw = function(self)
		local show = showLoadedScore(self)
		local scoreEngine = self.game.rhythmModel.scoreEngine
		local scoreItem = self.game.selectModel.scoreItem
		local judgement = scoreEngine.scoreSystem.judgement

		if not show or not judgement or not scoreItem then
			return
		end

		local counterName = self.game.configModel.configs.select.judgements
		local counter = judgement.counters[counterName]
		local judgements = judgement.judgements[counterName]

		if not judgements.accuracy then
			return
		end

		getRect(self, Layout.column1row1)
		local size = 1 / 3
		self.x = self.x + self.w * 1 / 3
		self.w = self.w * size
		love.graphics.replaceTransform(_transform(transform):translate(self.x, self.y))

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(spherefonts.get("Noto Sans Mono", 32))
		LabelImView("j.acc", ("%3.2f%%"):format(judgements.accuracy(counter) * 100), self.h)
	end,
}

local NotechartInfo = {draw = function(self)
	local erfunc = require("libchart.erfunc")
	local ratingHitTimingWindow = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow
	local normalscore = self.game.rhythmModel.scoreEngine.scoreSystem.normalscore

	local noteChartItem = self.game.selectModel.noteChartItem
	local scoreItem = self.game.selectModel.scoreItem
	local scoreEngine = self.game.rhythmModel.scoreEngine

	if not scoreItem then
		return
	end

	local topScoreItem = self.game.scoreLibraryModel.items[1]
	if topScoreItem == scoreItem then
		topScoreItem = self.game.scoreLibraryModel.items[2]
	end
	if not topScoreItem then
		topScoreItem = scoreItem
	end

	local scoreEntry = scoreEngine.scoreEntry
	if not scoreEntry then
		return
	end

	local baseTimeRate = self.game.rhythmModel.timeEngine.baseTimeRate

	local show = showLoadedScore(self)

	local baseBpm = noteChartItem.bpm
	local baseLength = noteChartItem.length
	local baseDifficulty = noteChartItem.difficulty
	local baseInputMode = noteChartItem.inputMode

	local bpm = scoreEngine.bpm
	local length = scoreEngine.length
	local difficulty = show and scoreEngine.enps or scoreItem.difficulty
	local inputMode = show and scoreEngine.inputMode or scoreItem.inputMode

	getRect(self, Layout.title_left)
	love.graphics.replaceTransform(_transform(transform))
	self.x = self.x + 22
	love.graphics.translate(self.x, self.y + 15)

	self.w = self.w - 44
	local wr = 0.70

	TextCellImView(self.w * (1 - wr), 55, "right", "notes", noteChartItem.noteCount)
	just.sameline()
	TextCellImView(self.w * wr, 55, "right", "duration",
		(not show or length == baseLength) and rtime(baseLength) or
		("%s→%s"):format(rtime(baseLength), rtime(length))
	)

	TextCellImView(self.w * (1 - wr), 55, "right", "level", noteChartItem.level)
	just.sameline()
	TextCellImView(self.w * wr, 55, "right", "bpm",
		(not show or bpm == baseBpm) and math.floor(baseBpm) or
		("%d→%d"):format(baseBpm, bpm)
	)

	getRect(self, Layout.title_sub)
	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(self.x, self.y)

	local font = spherefonts.get("Noto Sans Mono", 48)
	font:setFallbacks(spherefonts.get("Noto Sans", 48))
	love.graphics.setFont(font)

	just.indent(36)
	just.text(("%0.2fx"):format(show and baseTimeRate or scoreItem.timeRate))

	local hp = scoreEngine.scoreSystem.hp
	if show and hp and hp.failed then
		just.sameline()
		just.offset(0)

		just.text("fail", self.w - 72, true)
	end

	getRect(self, Layout.middle)
	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(self.x, self.y)

	local score = not show and scoreItem.score or
		erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2))) * 10000
	if score ~= score then
		score = 0
	end
	local accuracyValue = show and normalscore.accuracyAdjusted or scoreItem.accuracy
	local accuracy = Format.accuracy(accuracyValue)

	local rating = scoreItem.rating

	if scoreEntry.id == scoreItem.id then
		local s = erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2)))
		rating = s * scoreEngine.enps
	end

	local bestScore = ("%d"):format(topScoreItem.score)
	local bestAccuracy = Format.accuracy(topScoreItem.accuracy)
	local bestRating = Format.difficulty(topScoreItem.rating)

	local deltaScore = score - topScoreItem.score
	local deltaAccuracy = accuracyValue - topScoreItem.accuracy
	local deltaRating = rating - topScoreItem.rating
	if deltaScore >= 0 then
		deltaScore = "+" .. ("%d"):format(deltaScore)
	else
		deltaScore = ("%d"):format(deltaScore)
	end
	if deltaAccuracy >= 0 then
		deltaAccuracy = "+" .. Format.accuracy(deltaAccuracy)
	else
		deltaAccuracy = Format.accuracy(deltaAccuracy)
	end
	if deltaRating >= 0 then
		deltaRating = "+" .. Format.difficulty(deltaRating)
	else
		deltaRating = Format.difficulty(deltaRating)
	end

	local w = self.w - 42 * 2

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate(self.x + 42, self.y + 5)

	local a, b = 6, 28
	-------------------------------

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	just.text("rating")
	just.sameline()
	just.offset(w - 240)

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 54))
	just.text(" " .. Format.difficulty(rating))
	just.sameline()

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 24))
	just.indent(10)
	local offset = just.offset()
	love.graphics.translate(0, a)
	just.text(bestRating)
	just.sameline()
	just.offset(offset)
	love.graphics.translate(0, b)
	just.text(deltaRating)
	love.graphics.translate(0, -a - b)

	-------------------------------

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	just.text("score")
	just.sameline()
	just.offset(w - 240)

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 54))
	just.text((" %d"):format(score))
	just.sameline()

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 24))
	just.indent(10)
	local offset = just.offset()
	love.graphics.translate(0, a)
	just.text(bestScore)
	just.sameline()
	just.offset(offset)
	love.graphics.translate(0, b)
	just.text(deltaScore)
	love.graphics.translate(0, -a - b)

	-------------------------------

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	just.text("accuracy")
	just.sameline()
	just.offset(w - 240)

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 54))
	just.text(accuracy)
	just.sameline()

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 24))
	just.indent(10)
	local offset = just.offset()
	love.graphics.translate(0, a)
	just.text(bestAccuracy)
	just.sameline()
	just.offset(offset)
	love.graphics.translate(0, b)
	just.text(deltaAccuracy)
	love.graphics.translate(0, -a - b)

	-------------------------------

	local font = spherefonts.get("Noto Sans Mono", 40)
	font:setFallbacks(spherefonts.get("Noto Sans", 40))
	love.graphics.setFont(font)

	local textInputMode = inputMode == baseInputMode and Format.inputMode(baseInputMode) or
		("%s→%s"):format(Format.inputMode(baseInputMode), Format.inputMode(inputMode))
	local textDifficulty = difficulty == baseDifficulty and Format.difficulty(baseDifficulty) or
		("%s→%s"):format(Format.difficulty(baseDifficulty), Format.difficulty(difficulty))

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	just.text("input mode")
	just.sameline()
	just.offset(0)

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 40))
	just.text(textInputMode, w, true)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	just.text("difficulty")
	just.sameline()
	just.offset(0)

	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 40))
	just.text(textDifficulty, w, true)

	getRect(self, Layout.graphs_sup_left)
	love.graphics.replaceTransform(_transform(transform))
	self.x = self.x + 22
	love.graphics.translate(self.x, self.y)

	self.w = self.w - 44
	local w = self.w / 5

	just.row(true)

	local mean = show and normalscore.normalscore.mean or scoreItem.mean
	TextCellImView(w, 55, "right", "mean", ("%0.1f"):format(mean * 1000))

	-- local earlylate = show and scoreEngine.scoreSystem.misc.earlylate or scoreItem.earlylate
	-- if earlylate == 0 or earlylate ~= earlylate then
	-- 	earlylate = "undef"
	-- elseif earlylate > 1 then
	-- 	earlylate = ("-%d%%"):format((earlylate - 1) * 100)
	-- elseif earlylate < 1 then
	-- 	earlylate = ("%d%%"):format((1 / earlylate - 1) * 100)
	-- end
	-- TextCellImView(w, 55, "right", "early/late", earlylate)

	TextCellImView(w, 55, "right", "pauses", scoreItem.pausesCount)

	if show then
		local adjustRatio = normalscore.adjustRatio
		adjustRatio = adjustRatio ~= adjustRatio and "nan" or ("%d%%"):format((1 - adjustRatio) * 100)
		TextCellImView(w, 55, "right", "adjust", adjustRatio)

		TextCellImView(w, 55, "right", "spam", scoreEngine.scoreSystem.base.earlyHitCount)
		TextCellImView(w, 55, "right", "max error", ("%d"):format(scoreEngine.scoreSystem.misc.maxDeltaTime * 1000))
	end

	just.row(false)
end}

local ModifierIconGrid = ModifierIconGridView:new({
	transform = transform,
	draw = function(self)
		getRect(self, Layout.middle_sub)
		self.x = self.x + 36
		self.w = self.w - 72
		self.size = self.h
		self.__index.draw(self)
	end,
	noModifier = true,
	config = {
		{"game.modifierModel.config", showLoadedScore},
		"game.selectModel.scoreItem.modifiers"
	},
})

local BottomScreenMenu = {draw = function(self)
	getRect(self, Layout.title_right)
	local tf = _transform(transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.translate(0, 72 / 2)
	if IconButtonImView("back", "clear", 72, 0.618) then
		self.screenView:changeScreen("selectView")
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local scoreItem = self.game.selectModel.scoreItem
	local scoreEngine = self.game.rhythmModel.scoreEngine
	local scoreEntry = scoreEngine.scoreEntry

	getRect(self, Layout.graphs_sup_right)
	local tf = _transform(transform):translate(self.x + 55, self.y)
	love.graphics.replaceTransform(tf)
	just.row(true)
	if TextButtonImView("retry", "retry", 72 * 1.5, self.h) then
		self.screenView:play("retry")
	end
	if TextButtonImView("replay", "watch replay", 72 * 3, self.h) then
		self.screenView:play("replay")
	end
	if scoreItem and scoreEntry and scoreItem.id == scoreEntry.id and not scoreItem.file then
		if TextButtonImView("submit", "resubmit", 72 * 2, self.h) then
			local noteChartModel = self.game.noteChartModel
			self.game.onlineModel.onlineScoreManager:submit(
				noteChartModel.noteChartEntry,
				noteChartModel.noteChartDataEntry,
				scoreItem.replayHash
			)
		end
	end
	just.row(false)
end}

local MatchPlayers = MatchPlayersView:new({
	transform = transformLeft,
	key = "game.multiplayerModel.roomUsers",
	x = 20,
	y = 540,
	font = {"Noto Sans Mono", 24},
})

local InspectScoreSystem = ValueView:new({
	subscreen = "scoreSystemDebug",
	transform = transformLeft,
	key = "game.rhythmModel.scoreEngine.scoreSystem.slice",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {"Noto Sans Mono", 14},
	align = "left",
	color = {1, 1, 1, 1}
})

local InspectCounters = ValueView:new({
	subscreen = "countersDebug",
	transform = transformLeft,
	key = "game.rhythmModel.scoreEngine.scoreSystem.judgement.counters",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {"Noto Sans Mono", 14},
	align = "left",
	color = {1, 1, 1, 1}
})

local InspectScoreEntry = ValueView:new({
	subscreen = "scoreEntryDebug",
	transform = transformLeft,
	key = "game.selectModel.scoreItem",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {"Noto Sans Mono", 14},
	align = "left",
	color = {1, 1, 1, 1}
})

local NoteSkinViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	Layout,
	Title,
	NotechartInfo,
	Judgements,
	JudgementsDropdown,
	JudgementsAccuracy,
	ModifierIconGrid,
	ScoreList,
	ScoreScrollBar,
	MissGraph,
	HitGraph,
	ComboGraph,
	HpGraph,
	EarlyLateMissGraph,
	BottomScreenMenu,
	MatchPlayers,
	InspectScoreSystem,
	InspectCounters,
	InspectScoreEntry,
	require("sphere.views.DebugInfoViewConfig"),
}

return NoteSkinViewConfig
