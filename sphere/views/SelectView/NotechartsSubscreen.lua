local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local icons = require("sphere.assets.icons")
local gfx_util = require("gfx_util")
local time_util = require("time_util")
local imgui = require("imgui")

local BackgroundView = require("sphere.views.BackgroundView")
local ScoreListView	= require("sphere.views.SelectView.ScoreListView")

local NoteChartSetListView = require("sphere.views.SelectView.NoteChartSetListView")
local NoteChartListView = require("sphere.views.SelectView.NoteChartListView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local BarCellImView = require("sphere.imviews.BarCellImView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local Format = require("sphere.views.Format")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local Layout = require("sphere.views.SelectView.Layout")
local SelectFrame = require("sphere.views.SelectView.SelectFrame")

local function drawFrameRect(w, h, _r)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, _r or 36)
	love.graphics.setColor(r, g, b, a)
end

local function drawFrameRect2(w, h, _r)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
	RoundedRectangle("fill", 0, 0, w, h, _r or 36)
	love.graphics.setColor(r, g, b, a)
end

local function ScoreList(self)
	local w, h = Layout:move("column1row1")
	drawFrameRect(w, h)

	local w, h = Layout:move("column1row1row1")
	drawFrameRect2(w, h)

	local w, h = Layout:move("column1row1row2")

	ScoreListView.game = self.game
	ScoreListView:draw(w, h)

	love.graphics.translate(w - 16, 0)

	local list = ScoreListView
	local count = #list.items - 1
	local pos = (list.visualItemIndex - 1) / count
	local newScroll = imgui.ScrollBar("score_sb", pos, 16, h, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end

local function NoteChartSetList(self)
	local w, h = Layout:move("column3")
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, 36)

	SelectFrame()
	NoteChartSetListView.game = self.game
	NoteChartSetListView:draw(w, h)
	SelectFrame()

	love.graphics.translate(w - 16, 0)

	local list = NoteChartSetListView
	local count = #list.items - 1
	local pos = (list.visualItemIndex - 1) / count
	local newScroll = imgui.ScrollBar("ncs_sb", pos, 16, h, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end

local function NoteChartList(self)
	drawFrameRect(Layout:move("column2row2"))
	drawFrameRect2(Layout:move("column2row2row1"))

	local w, h = Layout:move("column2row2row2")

	love.graphics.setColor(1, 1, 1, 0.8)
	love.graphics.polygon("fill",
		0, 72 * 2.2,
		36 * 0.6, 72 * 2.5,
		0, 72 * 2.8
	)

	NoteChartListView.game = self.game
	NoteChartListView:draw(w, h)
end

local function Cells(self)
	local w, h = Layout:move("column2row1")

	local baseTimeRate = self.game.modifierModel.state.timeRate
	local noteChartItem = self.game.selectModel.noteChartItem
	local scoreItem = self.game.selectModel.scoreItem

	local bpm = 0
	local length = 0
	local noteCount = 0
	local level = 0
	local longNoteRatio = 0
	local localOffset = 0
	if noteChartItem then
		bpm = (noteChartItem.bpm or 0) * baseTimeRate
		length = (noteChartItem.length or 0) / baseTimeRate
		noteCount = noteChartItem.noteCount or 0
		level = noteChartItem.level or 0
		longNoteRatio = noteChartItem.longNoteRatio or 0
		localOffset = noteChartItem.localOffset or 0
	end

	local score = 0
	local difficulty = 0
	local accuracy = 0
	local missCount = 0
	if scoreItem then
		score = scoreItem.score or 0
		difficulty = scoreItem.difficulty or 0
		accuracy = scoreItem.accuracy or 0
		missCount = scoreItem.missCount or 0
		if score ~= score then
			score = 0
		end
	end

	love.graphics.translate(0, h - 118)
	w = (w - 44) / 4
	h = 50

	love.graphics.setColor(1, 1, 1, 1)

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", "bpm", ("%d"):format(bpm))
	TextCellImView(w, h, "right", "duration", time_util.format(length))
	TextCellImView(w, h, "right", "notes", noteCount)
	TextCellImView(w, h, "right", "level", level)

	just.row(true)
	just.indent(22)
	BarCellImView(2 * w, h, "right", "long notes", longNoteRatio)
	TextCellImView(2 * w, h, "right", "local offset", localOffset * 1000)
	just.row()

	w, h = Layout:move("column1row2")
	drawFrameRect(w, h)

	love.graphics.translate(w / 2, 6)
	w = (w - 44) / 4
	h = 50

	just.row(true)
	TextCellImView(w, h, "right", "score", ("%d"):format(score))
	TextCellImView(w, h, "right", "accuracy", Format.accuracy(accuracy))

	just.row(true)
	TextCellImView(w, h, "right", "difficulty", Format.difficulty(difficulty))
	TextCellImView(w, h, "right", "miss count", ("%d"):format(missCount))
	just.row()
end

local bannerGradient
local function BackgroundBanner(self)
	bannerGradient = bannerGradient or gfx_util.newGradient(
		"vertical",
		{0, 0, 0, 0},
		{0, 0, 0, 1}
	)

	local w, h = Layout:move("column2row1")
	drawFrameRect(w, h)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, 36)
	BackgroundView.game = self.game
	BackgroundView:draw(w, h, 0, 0)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bannerGradient, 0, 0, 0, w, h)
	just.clip()
end

local function SearchField(self)
	if not just.focused_id then
		just.focus("SearchField")
	end
	local padding = 15
	love.graphics.setFont(spherefonts.get("Noto Sans", 20))

	local w, h = Layout:move("column3", "header")
	love.graphics.translate(0, padding)

	local delAll = love.keyboard.isDown("lctrl") and love.keyboard.isDown("backspace")

	local text = self.game.searchModel.filterString
	local changed, text = imgui.TextInput("SearchField", {text, "Filter..."}, nil, w / 2, h - padding * 2)
	if changed == "text" then
		if delAll then text = "" end
		self.game.searchModel:setSearchString("filter", text)
	end

	w, h = Layout:move("column3", "header")
	love.graphics.translate(w / 2, padding)

	local text = self.game.searchModel.lampString
	local changed, text = imgui.TextInput("SearchFieldLamp", {text, "Lamp..."}, nil, w / 2, h - padding * 2)
	if changed == "text" then
		if delAll then text = "" end
		self.game.searchModel:setSearchString("lamp", text)
	end

	w, h = Layout:move("column3", "header")
	love.graphics.translate(w + h / 2, 0)

	if imgui.IconOnlyButton("edit", icons("create"), h, 0.5) then
		self:edit()
	end
end

local function SortDropdown(self)
	local w, h = Layout:move("column2", "header")
	love.graphics.translate(w * 2 / 3, 15)

	local sortModel = self.game.sortModel
	local i = imgui.SpoilerList("SortDropdown", w / 3, h - 30, sortModel.names, sortModel.name)
	if i then
		self.game.selectModel:setSortFunction(sortModel:fromIndexValue(i), true)
	end
end

local function filter_to_string(f)
	return f.name
end
local function NotechartFilterDropdown(self)
	local w, h = Layout:move("column3")

	local size = 1 / 4
	h = 60
	love.graphics.translate(w * (1 - size) - 26, (72 - h) / 2)

	local filters = self.game.configModel.configs.filters.notechart
	local config = self.game.configModel.configs.select
	local i = imgui.SpoilerList("NotechartFilterDropdown", w * size, h, filters, config.filterName, filter_to_string)
	if i then
		config.filterName = filters[i].name
		self.game.selectModel:noDebouncePullNoteChartSet()
	end
end

local function ScoreFilterDropdown(self)
	local w, h = Layout:move("column1")

	local size = 1 / 4
	h = 60
	love.graphics.translate(w * (1 - size) - 26, (72 - h) / 2)

	local filters = self.game.configModel.configs.filters.score
	local config = self.game.configModel.configs.select
	local i = imgui.SpoilerList("ScoreFilterDropdown", w * size, h, filters, config.scoreFilterName, filter_to_string)
	if i then
		config.scoreFilterName = filters[i].name
		self.game.selectModel:pullScore()
	end
end

local function ScoreSourceDropdown(self)
	local w, h = Layout:move("column1")

	local size = 1 / 4
	h = 60
	love.graphics.translate(w * (3 / 4 - size) - 26, (72 - h) / 2)

	local sources = self.game.scoreLibraryModel.scoreSources
	local config = self.game.configModel.configs.select
	local i = imgui.SpoilerList("ScoreSourceDropdown", w * size, h, sources, config.scoreSourceName)
	if i then
		config.scoreSourceName = sources[i]
		self.game.selectModel:updateScoreOnline()
	end
end

local function GroupCheckbox(self)
	local w, h = Layout:move("column2", "header")
	w = w / 3

	love.graphics.translate(w, h / 6)
	local collapse = self.game.noteChartSetLibraryModel.collapse
	if imgui.Checkbox(self, collapse, h * 2 / 3) then
		self.game.selectModel:changeCollapse()
	end
	just.sameline()

	love.graphics.setFont(spherefonts.get("Noto Sans", 20))
	imgui.Label(self, "group", h * 2 / 3)
end

local function ModifierIconGrid(self)
	local w, h = Layout:move("column1row3")
	drawFrameRect(w, h)
	love.graphics.translate(21, 4)

	local modifierModel = self.game.modifierModel

	ModifierIconGridView.game = self.game
	ModifierIconGridView:draw(modifierModel.config, w - 42, h, (h - 8) / 2)

	w, h = Layout:move("column1row2")
	love.graphics.translate(21, 4)

	local scoreItem = self.game.selectModel.scoreItem
	if not scoreItem then
		return
	end
	local configModifier = scoreItem.modifiers or (scoreItem.modifierset and scoreItem.modifierset.encoded)

	ModifierIconGridView.game = self.game
	ModifierIconGridView:draw(configModifier, w / 2 - 42, h, (h - 8) / 3, true)
end

local function NotechartsSubscreen(self)
	local _, h = Layout:move("column1", "footer")
	local w = h * 1.5

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local gameView = self.game.gameView
	just.row(true)
	if imgui.IconOnlyButton("settings", icons("settings"), h, 0.5) then
		gameView:setModal(require("sphere.views.SettingsView"))
	end
	if imgui.IconOnlyButton("mounts", icons("folder_open"), h, 0.5) then
		gameView:setModal(require("sphere.views.MountsView"))
	end
	if imgui.TextOnlyButton("modifiers", "mods", w, h) then
		gameView:setModal(require("sphere.views.ModifierView"))
	end
	if imgui.TextOnlyButton("noteskins", "skins", w, h) then
		gameView:setModal(require("sphere.views.NoteSkinView"))
	end
	if imgui.TextOnlyButton("input", "input", w, h) then
		gameView:setModal(require("sphere.views.InputView"))
	end
	if imgui.TextOnlyButton("multi", "multi", w, h) then
		gameView:setModal(require("sphere.views.LobbyView"))
	end
	just.row()

	w, h = Layout:move("column3", "footer")

	just.row(true)
	just.indent(-h)
	if imgui.TextOnlyButton("pause music", "pause", h, h) then
		self.game.previewModel:stop()
	end
	if imgui.TextOnlyButton("collections", "collections", w / 2, h) then
		self:switchToCollections()
	end
	if imgui.TextOnlyButton("direct", "direct", w / 2, h) then
		self:switchToOsudirect()
	end
	just.row()

	w, h = Layout:move("column2row2row1")

	just.row(true)
	just.indent(36)
	if imgui.IconOnlyButton("open directory", icons("folder_open"), h, 0.5) then
		self.game.selectController:openDirectory()
	end
	if imgui.IconOnlyButton("update cache", icons("refresh"), h, 0.5) then
		self.game.selectController:updateCache(true)
	end
	just.offset(w - h * 2 - 36)
	if imgui.IconOnlyButton("result", icons("info_outline"), h, 0.5) then
		self:result()
	end
	if imgui.IconOnlyButton("play", icons("keyboard_arrow_right"), h, 0.5) then
		self:play()
	end
	just.row()

	w, h = Layout:move("column1row1row1")

	just.indent(36)
	if imgui.IconOnlyButton("open notechart page", icons("info_outline"), h, 0.5) then
		self.game.selectController:openWebNotechart()
	end
end

return function(self)
	BackgroundBanner(self)
	NoteChartSetList(self)
	NoteChartList(self)
	ScoreList(self)
	Cells(self)
	SearchField(self)
	SortDropdown(self)
	NotechartFilterDropdown(self)
	ScoreFilterDropdown(self)
	ScoreSourceDropdown(self)
	GroupCheckbox(self)
	ModifierIconGrid(self)
	NotechartsSubscreen(self)
end
