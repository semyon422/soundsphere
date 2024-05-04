local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local icons = require("sphere.assets.icons")
local imgui = require("imgui")

local BackgroundView = require("sphere.views.BackgroundView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local PointGraphView = require("sphere.views.GameplayView.PointGraphView")
local ScoreListView = require("sphere.views.ResultView.ScoreListView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local MatchPlayersView = require("sphere.views.GameplayView.MatchPlayersView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local Format = require("sphere.views.Format")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local time_util = require("time_util")

---@param self table
---@return boolean
local function showLoadedScore(self)
	local scoreEntry = self.game.playContext.scoreEntry
	local scoreItem = self.game.selectModel.scoreItem
	if not scoreEntry or not scoreItem then
		return false
	end
	return scoreItem.id == scoreEntry.id
end

local Layout = require("sphere.views.ResultView.Layout")

---@param w number
---@param h number
---@param _r number?
local function drawFrameRect(w, h, _r)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, _r or 36)
	love.graphics.setColor(r, g, b, a)
end

---@param w number
---@param h number
---@param _r number?
local function drawFrameRect2(w, h, _r)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
	RoundedRectangle("fill", 0, 0, w, h, _r or 36)
	love.graphics.setColor(r, g, b, a)
end

---@param self table
local function Frames(self)
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("graphs")
	drawFrameRect(w, h)

	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)

	w, h = Layout:move("title_left")
	RoundedRectangle("fill", 0, 0, w, h, 36, false, false, 3)

	w, h = Layout:move("title_sub")
	RoundedRectangle("fill", 0, 0, w, 72, 36, true, true, 2)

	w, h = Layout:move("title_right")
	RoundedRectangle("fill", 0, 0, w, h, 36, false, false, 1)
end

---@param self table
local function Background(self)
	local w, h = Layout:move("base")

	local dim = self.game.configModel.configs.settings.graphics.dim.result
	BackgroundView.game = self.game
	BackgroundView:draw(w, h, dim, 0.01)
end

---@param self table
local function drawGraph(self)
	local w, h = Layout:move("graphs")
	local padding = 18 * math.sqrt(2) / 2
	love.graphics.translate(padding, padding)
	w = w - padding * 2
	h = h - padding * 2
	self.__index.draw(self, w, h)
end

local _ComboGraph = PointGraphView({
	draw = drawGraph,
	radius = 2,
	backgroundColor = { 0, 0, 0, 0.2 },
	backgroundRadius = 4,
	point = function(self, point)
		local y = 1 - point.base.combo / point.base.notesCount
		return y, 1, 1, 0.25, 1
	end,
	show = showLoadedScore,
})

---@param self table
local function ComboGraph(self)
	_ComboGraph.game = self.game
	_ComboGraph:draw()
end

local _EarlyHitGraph = PointGraphView({
	draw = drawGraph,
	radius = 4,
	backgroundColor = { 1, 1, 1, 1 },
	backgroundRadius = 6,
	point = function(self, point)
		if not point.base.isEarlyHit then
			return
		end
		local y = point.misc.deltaTime / 0.16 / 2 + 0.5
		return y, 0.4, 0.35, 0.8, 1
	end,
	show = showLoadedScore,
})

---@param self table
local function EarlyHitGraph(self)
	_EarlyHitGraph.game = self.game
	_EarlyHitGraph:draw()
end

local perfectColor = { 1, 1, 1, 1 }
local notPerfectColor = { 1, 0.6, 0.4, 1 }
local _HitGraph = PointGraphView({
	draw = drawGraph,
	radius = 2,
	backgroundColor = { 0, 0, 0, 0.2 },
	backgroundRadius = 6,
	point = function(self, point)
		if point.base.isMiss then
			return
		end
		local color = notPerfectColor
		if math.abs(point.misc.deltaTime) <= 0.016 then
			color = perfectColor
		end

		local y = point.misc.deltaTime / 0.16 / 2 + 0.5
		return y, unpack(color)
	end,
	show = showLoadedScore,
})

---@param self table
local function HitGraph(self)
	_HitGraph.game = self.game
	_HitGraph:draw()
end

local _MissGraph = PointGraphView({
	draw = drawGraph,
	radius = 4,
	backgroundColor = { 1, 1, 1, 1 },
	backgroundRadius = 6,
	point = function(self, point)
		if not point.base.isMiss then
			return
		end
		local y = point.misc.deltaTime / 0.16 / 2 + 0.5
		return y, 1, 0.2, 0.2, 1
	end,
	show = showLoadedScore,
})

---@param self table
local function MissGraph(self)
	_MissGraph.game = self.game
	_MissGraph:draw()
end

local _HpGraph = PointGraphView({
	draw = drawGraph,
	radius = 2,
	backgroundColor = { 0, 0, 0, 0.2 },
	backgroundRadius = 4,
	point = function(self, point)
		local value = 0
		local _hp = self.game.rhythmModel.scoreEngine.scoreSystem.hp
		local hp = point.hp
		for _, h in ipairs(hp) do
			if h.value > 0 then
				value = h.value / _hp.max
				break
			end
		end

		return 1 - value, 0.25, 1, 0.5, 1
	end,
	show = showLoadedScore,
})

---@param self table
local function HpGraph(self)
	_HpGraph.game = self.game
	_HpGraph:draw()
end

---@param self table
local function ScoreList(self)
	local w, h = Layout:move("column3")
	drawFrameRect(w, h)
	love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
	w, h = Layout:move("column3row1")
	drawFrameRect2(w, h)
	love.graphics.setColor(1, 1, 1, 1)

	w, h = Layout:move("column3row2")

	ScoreListView.game = self.game
	ScoreListView.screenView = self
	ScoreListView:draw(w, h)

	love.graphics.setColor(1, 1, 1, 0.8)
	h = h / ScoreListView.rows
	local c = math.floor(ScoreListView.rows / 2)
	love.graphics.polygon(
		"fill",
		0,
		h * (c + 0.2) + (72 - h) / 2,
		h / 2 * 0.6,
		h * (c + 0.5) + (72 - h) / 2,
		0,
		h * (c + 0.8) + (72 - h) / 2
	)

	w, h = Layout:move("column3row2")
	love.graphics.translate(w - 16, 0)

	local list = ScoreListView
	local count = #list.items - 1
	local pos = (list.visualItemIndex - 1) / count
	local newScroll = imgui.ScrollBar("slsb", pos, 16, h, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end

---@param self table
local function Title(self)
	local chartview = self.game.selectModel.chartview

	local w, h = Layout:move("title_middle")
	drawFrameRect(w, h)
	love.graphics.translate(22, 15)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 36))

	local artist_title = ("%s — %s"):format(chartview.artist, chartview.title)
	local creator_name = ("%s — %s"):format(chartview.creator, chartview.name)
	just.text(artist_title)
	just.text(creator_name)
end

---@param self table
local function Judgements(self)
	local show = showLoadedScore(self)
	local scoreEngine = self.game.rhythmModel.scoreEngine
	local scoreItem = self.game.selectModel.scoreItem

	if not self.judgements or not scoreItem then
		return
	end

	local padding = 24

	local w, h = Layout:move("column1")
	drawFrameRect(w, h)
	love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
	w, h = Layout:move("column1row1")
	drawFrameRect2(w, h)
	love.graphics.setColor(1, 1, 1, 1)

	local w, h = Layout:move("column1row2")
	love.graphics.translate(padding, padding)

	w = w - padding * 2

	local judgeName = self.game.configModel.configs.select.judgements
	local judge = self.judgements[judgeName]

	local judgementLists = judge.orderedCounters
	local counters = judge.counters

	local perfect = show and counters.perfect or scoreItem.perfect or 0
	local notPerfect = show and counters["not perfect"] or scoreItem.not_perfect or 0
	local miss = show and judge.counters.miss or scoreItem.miss or 0

	local notes = perfect + notPerfect + miss

	if show then -- LR2 mash can be higher than total count of notes
		notes = 0
		for _, counter in pairs(judge.counters) do
			notes = notes + counter
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local interval = 5
	local lineHeight = 40

	if show then
		for _, name in ipairs(judgementLists) do
			imgui.ValueBar(w, lineHeight, counters[name] / notes, name, counters[name])
			just.emptyline(interval)
		end
	else
		imgui.ValueBar(w, lineHeight, perfect / notes, "perfect", perfect)
		just.emptyline(interval)
		imgui.ValueBar(w, lineHeight, notPerfect / notes, "not perfect", notPerfect)
	end

	Layout:move("column1row2")
	love.graphics.translate(padding, -padding + h - lineHeight)

	imgui.ValueBar(w, lineHeight, miss / notes, "miss", miss)
end

local selectorState = {}

---@param item table
---@param w number
---@param h number
---@return string?
local function JudgementSelector(item, w, h)
	local name = item.name
	if not item.range then
		return imgui.TextOnlyButton(name .. "judgement", name, w, h, "center") and name
	end

	selectorState[name] = selectorState[name] or item.range[1]
	local v = selectorState[name]

	local text = name:format(selectorState[name])

	if item.rangeValueAlias then
		text = name:format(item.rangeValueAlias[v])
	end

	local ret
	just.row(true)
	if imgui.TextOnlyButton(name .. "judgement", text, w - h * 2, h, "center") then
		ret = text
		if item.rangeValueAlias then
			ret = name:format(item.rangeValueAlias[v])
		end
	end
	if imgui.TextOnlyButton(name .. "judgement<", "<", h, h, "center") and v > item.range[1] then
		selectorState[name] = v - 1
	end
	if imgui.TextOnlyButton(name .. "judgement>", ">", h, h, "center") and v < item.range[2] then
		selectorState[name] = v + 1
	end
	just.row()

	return ret
end

---@param self table
local function JudgementsDropdown(self)
	local w, h = Layout:move("column1row1")
	h = 60

	local size = 1 / 2
	love.graphics.translate(w * (1 - size) - 26, (72 - h) / 2)

	local items = self.selectors

	local config = self.game.configModel.configs.select
	local preview = config.judgements
	love.graphics.setFont(spherefonts.get("Noto Sans", 20))

	local s = 0.75
	if imgui.Spoiler("JudgementsDropdown", w * size, h, preview) then
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, w, h * s * #items)
		love.graphics.setColor(1, 1, 1, 1)
		for i, item in ipairs(items) do
			local v = JudgementSelector(item, w * size - h * (1 - s), h * s)
			if v then
				config.judgements = v
				just.focus()
			end
		end
		imgui.Spoiler()
	end
end

---@param self table
local function JudgementsAccuracy(self)
	local show = showLoadedScore(self)
	local scoreItem = self.game.selectModel.scoreItem

	if not show or not scoreItem then
		return
	end

	local counterName = self.game.configModel.configs.select.judgements
	local judge = self.judgements[counterName]

	if not judge.accuracy then
		return
	end

	local w, h = Layout:move("column1row1")
	love.graphics.translate(36, 0)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans Mono", 32))
	imgui.Label("j.acc", ("%3.2f%%"):format(judge.accuracy * 100), h)
end

---@param self table
local function NotechartInfo(self)
	local erfunc = require("libchart.erfunc")
	local ratingHitTimingWindow = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow

	local rhythmModel = self.game.rhythmModel
	local normalscore = rhythmModel.scoreEngine.scoreSystem.normalscore

	local chartview = self.game.selectModel.chartview
	local scoreItem = self.game.selectModel.scoreItem
	local scoreEngine = rhythmModel.scoreEngine
	local playContext = self.game.playContext

	if not scoreItem then
		return
	end

	local topScoreItem = self.game.selectModel.scoreLibrary.items[1]
	if topScoreItem == scoreItem then
		topScoreItem = self.game.selectModel.scoreLibrary.items[2]
	end
	if not topScoreItem then
		topScoreItem = scoreItem
	end

	local scoreEntry = playContext.scoreEntry
	if not scoreEntry then
		return
	end

	local show = showLoadedScore(self)

	local baseTimeRate = show and playContext.rate or scoreItem.rate
	local const = show and playContext.const or scoreItem.const

	local baseBpm = chartview.tempo
	local baseLength = chartview.duration
	local baseDifficulty = chartview.difficulty
	local baseInputMode = chartview.inputmode

	local bpm = scoreItem.tempo
	local length = scoreItem.duration
	local difficulty = show and playContext.chartdiff.enps_diff or scoreItem.difficulty
	local inputMode = show and tostring(rhythmModel.noteChart.inputMode) or scoreItem.inputmode

	local w, h = Layout:move("title_left")
	love.graphics.translate(22, 15)

	w = w - 44
	local wr = 0.70

	TextCellImView(w * (1 - wr), 55, "right", "notes", chartview.notes_count)
	just.sameline()
	TextCellImView(
		w * wr,
		55,
		"right",
		"duration",
		length == baseLength and time_util.format(baseLength)
			or ("%s→%s"):format(time_util.format(baseLength), time_util.format(length))
	)

	TextCellImView(w * (1 - wr), 55, "right", "level", chartview.level)
	just.sameline()
	TextCellImView(
		w * wr,
		55,
		"right",
		"bpm",
		bpm == baseBpm and math.floor(baseBpm + 0.5)
			or ("%d→%d"):format(math.floor(baseBpm + 0.5), math.floor(bpm + 0.5))
	)

	w, h = Layout:move("title_sub")
	love.graphics.translate(0, 8)

	local font = spherefonts.get("Noto Sans Mono", 36)
	font:setFallbacks(spherefonts.get("Noto Sans", 36))
	love.graphics.setFont(font)

	just.indent(36)
	just.text(("%0.3fx"):format(baseTimeRate))
	if const then
		just.sameline()
		just.text("c")
	end

	local hp = scoreEngine.scoreSystem.hp
	if show and hp then
		just.sameline()
		just.offset(0)

		local _h
		if not hp then
			return
		end
		for _, h in ipairs(hp) do
			if h.value > 0 then
				_h = h
				break
			end
		end

		local text = "fail"
		if _h then
			text = _h.notes .. "hp"
		end
		just.text(text, w - 72, true)
	end

	w, h = Layout:move("middle")
	drawFrameRect(w, h)
	love.graphics.setColor(0.4, 0.4, 0.4, 0.3)
	w, h = Layout:move("middle_sub")
	RoundedRectangle("fill", 0, 0, w, 72, 36, false, false, 2)
	love.graphics.setColor(1, 1, 1, 1)

	local score = not show and scoreItem.score
		or erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2))) * 10000
	if score ~= score then
		score = 0
	end
	local accuracyValue = show and normalscore.accuracyAdjusted or scoreItem.accuracy
	local accuracy = Format.accuracy(accuracyValue)

	local rating = scoreItem.rating

	if scoreEntry.id == scoreItem.id then
		local s = erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2)))
		rating = s * playContext.chartdiff.enps_diff
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

	w, h = Layout:move("middle")
	love.graphics.translate(42, 5)
	w = w - 42 * 2

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

	local textInputMode = inputMode == baseInputMode and Format.inputMode(baseInputMode)
		or ("%s→%s"):format(Format.inputMode(baseInputMode), Format.inputMode(inputMode))
	local textDifficulty = difficulty == baseDifficulty and Format.difficulty(baseDifficulty)
		or ("%s→%s"):format(Format.difficulty(baseDifficulty), Format.difficulty(difficulty))

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

	w, h = Layout:move("graphs_sup_left")
	love.graphics.setColor(0, 0, 0, 0.8)
	RoundedRectangle("fill", 0, 0, w, h, { 36, h / 2, 36, h / 2 }, false, true)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.translate(22, 0)

	w = (w - 44) / 5

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

	TextCellImView(w, 55, "right", "pauses", scoreItem.pauses)

	if show then
		local adjustRatio = normalscore.adjustRatio
		adjustRatio = adjustRatio ~= adjustRatio and "nan" or ("%d%%"):format((1 - adjustRatio) * 100)
		TextCellImView(w, 55, "right", "adjust", adjustRatio)

		TextCellImView(w, 55, "right", "spam", scoreEngine.scoreSystem.base.earlyHitCount)
		TextCellImView(w, 55, "right", "max error", ("%d"):format(scoreEngine.scoreSystem.misc.maxDeltaTime * 1000))
	end

	just.row()
end

---@param self table
local function ModifierIconGrid(self)
	local w, h = Layout:move("middle_sub")
	-- drawFrameRect(w, h)
	love.graphics.translate(36, 0)

	local selectModel = self.game.selectModel
	local modifiers = self.game.playContext.modifiers
	if not showLoadedScore(self) and selectModel.scoreItem then
		modifiers = selectModel.scoreItem.modifiers
	end

	ModifierIconGridView.game = self.game
	ModifierIconGridView:draw(modifiers, w - 72, h, h, true)
end

---@param self table
local function BottomScreenMenu(self)
	local w, h = Layout:move("title_right")

	love.graphics.translate(0, 72 / 2)
	if imgui.IconOnlyButton("back", icons("clear"), 72, 0.618) then
		self:changeScreen("selectView")
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local scoreItem = self.game.selectModel.scoreItem
	local scoreEntry = self.game.playContext.scoreEntry

	w, h = Layout:move("graphs_sup_right")
	love.graphics.setColor(0, 0, 0, 0.8)
	RoundedRectangle("fill", 0, 0, w, h, { h / 2, 36, h / 2, 36 }, true, false)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.translate(55, 0)

	just.row(true)
	if imgui.TextOnlyButton("retry", "retry", 72 * 1.5, h) then
		self:play("retry")
	end
	if imgui.TextOnlyButton("replay", "watch replay", 72 * 3, h) then
		self:play("replay")
	end
	if scoreItem and scoreEntry and scoreItem.id == scoreEntry.id and not scoreItem.file then
		if imgui.TextOnlyButton("submit", "resubmit", 72 * 2, h) then
			self.game.onlineModel.onlineScoreManager:submit(self.game.selectModel.chartview, scoreItem.replay_hash)
		end
	end
	just.row()
end

---@param self table
local function MatchPlayers(self)
	Layout:move("column1")
	MatchPlayersView.game = self.game
	MatchPlayersView:draw()
end

return function(self)
	GaussianBlurView:draw(self.game.configModel.configs.settings.graphics.blur.result)
	Background(self)
	GaussianBlurView:draw(self.game.configModel.configs.settings.graphics.blur.result)
	Frames(self)
	Title(self)
	NotechartInfo(self)
	ModifierIconGrid(self)
	ScoreList(self)
	HitGraph(self)
	ComboGraph(self)
	HpGraph(self)
	MissGraph(self)
	EarlyHitGraph(self)
	BottomScreenMenu(self)
	Judgements(self)
	JudgementsDropdown(self)
	JudgementsAccuracy(self)
	MatchPlayers(self)
end
