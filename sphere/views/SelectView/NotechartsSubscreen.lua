local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local icons = require("sphere.assets.icons")
local gfx_util = require("gfx_util")
local time_util = require("time_util")
local imgui = require("imgui")

local BackgroundView = require("sphere.views.BackgroundView")
local ScoreListView = require("sphere.views.SelectView.ScoreListView")

local NoteChartSetListView = require("sphere.views.SelectView.NoteChartSetListView")
local NoteChartListView = require("sphere.views.SelectView.NoteChartListView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local BarCellImView = require("sphere.imviews.BarCellImView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local Format = require("sphere.views.Format")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local Layout = require("sphere.views.SelectView.Layout")
local SelectFrame = require("sphere.views.SelectView.SelectFrame")

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

---@param self table
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

---@param self table
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

---@param self table
local function Cells(self)
	local w, h = Layout:move("column2row1")

	local baseTimeRate = self.game.playContext.rate
	local noteChartItem = self.game.selectModel.noteChartItem
	local scoreItem = self.game.selectModel.scoreItem

	local bpm = 0
	local length = 0
	local notes_count = 0
	local level = 0
	local longNoteRatio = 0
	local localOffset = 0
	local format = ""
	if noteChartItem then
		bpm = (noteChartItem.bpm or 0) * baseTimeRate
		length = (noteChartItem.length or 0) / baseTimeRate
		notes_count = noteChartItem.notes_count or 0
		level = noteChartItem.level or 0
		longNoteRatio = noteChartItem.longNoteRatio or 0
		localOffset = noteChartItem.localOffset or 0
		format = noteChartItem.format or ""
	end

	local score = 0
	local difficulty = 0
	local accuracy = 0
	local missCount = 0
	local rate = 1
	local const = false
	if scoreItem then
		score = scoreItem.score or 0
		difficulty = scoreItem.difficulty or 0
		accuracy = scoreItem.accuracy or 0
		missCount = scoreItem.miss or 0
		rate = scoreItem.rate or 1
		const = scoreItem.const or false
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
	TextCellImView(w, h, "right", "bpm", math.floor(bpm + 0.5))
	TextCellImView(w, h, "right", "duration", time_util.format(length))
	TextCellImView(w, h, "right", "notes", notes_count)
	TextCellImView(w, h, "right", "level", level)

	just.row(true)
	just.indent(22)
	BarCellImView(2 * w, h, "right", "long notes", longNoteRatio)
	TextCellImView(w, h, "right", "offset", localOffset * 1000)
	TextCellImView(w, h, "right", "format", format)
	just.row()

	w, h = Layout:move("column1row2")
	drawFrameRect(w, h)

	love.graphics.translate(w / 2, 6)
	w = (w - 44) / 4
	h = 50

	just.row(true)
	TextCellImView(w, h, "right", "score", math.floor(score))
	TextCellImView(w, h, "right", "accuracy", Format.accuracy(accuracy))

	just.row(true)
	TextCellImView(w, h, "right", "difficulty", Format.difficulty(difficulty))
	TextCellImView(w, h, "right", "miss count", missCount)

	just.row(true)
	local const_str = ""
	if const then
		const_str = "const"
	end
	TextCellImView(w, h, "right", "", const_str)
	TextCellImView(w, h, "right", "rate", Format.timeRate(rate))
	just.row()

	if self.game.multiplayerModel.room then
		return
	end

	w, h = Layout:move("column2row1")
	love.graphics.translate(0, h / 2 - 55)
	if imgui.TextOnlyButton("play auto", "AP", 55, 55) then
		self.game.rhythmModel:setAutoplay(true)
		self:play()
	end
	if imgui.TextOnlyButton("play pro", "PM", 55, 55) then
		self.game.rhythmModel:setPromode(true)
		self:play()
	end
end

local bannerGradient

---@param self table
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

---@param self table
local function SearchField(self)
	if not just.focused_id then
		just.focus("SearchField")
	end
	local padding = 15
	love.graphics.setFont(spherefonts.get("Noto Sans", 20))

	local w, h = Layout:move("column3", "header")
	love.graphics.translate(0, padding)

	local delAll = love.keyboard.isDown("lctrl") and love.keyboard.isDown("backspace")

	local config = self.game.configModel.configs.select
	local selectModel = self.game.selectModel

	local changed, text = imgui.TextInput("SearchField", {config.filterString, "Filter..."}, nil, w / 2, h - padding * 2)
	if changed == "text" then
		if delAll then text = "" end
		config.filterString = text
		selectModel:debouncePullNoteChartSet()
	end

	w, h = Layout:move("column3", "header")
	love.graphics.translate(w / 2, padding)

	local changed, text = imgui.TextInput("SearchFieldLamp", {config.lampString, "Lamp..."}, nil, w / 2, h - padding * 2)
	if changed == "text" then
		if delAll then text = "" end
		config.lampString = text
		selectModel:debouncePullNoteChartSet()
	end

	w, h = Layout:move("column3", "header")
	love.graphics.translate(w + h / 2, 0)
end

---@param self table
local function SortDropdown(self)
	local w, h = Layout:move("column2", "header")
	love.graphics.translate(w * 2 / 3, 15)

	local sortFunction = self.game.configModel.configs.select.sortFunction
	local sortModel = self.game.selectModel.sortModel
	local i = imgui.SpoilerList("SortDropdown", w / 3, h - 30, sortModel.names, sortFunction)
	local name = sortModel.names[i]
	if name then
		self.game.selectModel:setSortFunction(name)
	end
end

---@param f table
---@return string
local function filter_to_string(f)
	return f.name
end

---@param self table
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

---@param self table
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

---@param self table
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

---@param self table
local function GroupCheckbox(self)
	local w, h = Layout:move("column2", "header")
	w = w / 3

	love.graphics.translate(w - h / 6, 0)

	local count = #self.game.selectModel.noteChartSetLibrary.items

	love.graphics.setFont(spherefonts.get("Noto Sans", 20))

	local text = "charts: " .. count
	gfx_util.printFrame(text, 0, 0, w, h, "right", "center")
	just.next(w, h)
end

---@param self table
local function ModifierIconGrid(self)
	local w, h = Layout:move("column1row3")
	drawFrameRect(w, h)

	local right_w = h * 0.9

	love.graphics.translate(w - 21 - right_w, 4)

	imgui.setSize(right_w, h - 8, right_w / 2, (h - 8) / 2)

	local configs = self.game.configModel.configs
	local g = configs.settings.gameplay

	local timeRateModel = self.game.timeRateModel
	local range = timeRateModel.range[g.rateType]
	local format = timeRateModel.format[g.rateType]
	local newRate = imgui.knob(
		"rate knob",
		timeRateModel:get(),
		range[1], range[2], range[3], 1000,
		format:format(timeRateModel:get())
	)

	if newRate ~= timeRateModel:get() then
		self.game.modifierSelectModel:change()
	end
	timeRateModel:set(newRate)

	local w, h = Layout:move("column1row3")
	love.graphics.translate(21, 4)

	ModifierIconGridView.game = self.game
	ModifierIconGridView:draw(self.game.playContext.modifiers, w - 42 - right_w, h, (h - 8) / 2)

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

---@param self table
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

	local fullWidth = w - 72
	local num_buttons = 5

	local y_offset = 0
	if h * num_buttons > fullWidth then
		y_offset = (h - fullWidth / num_buttons) / 2
		h = fullWidth / num_buttons
	end

	just.emptyline(y_offset)
	just.row(true)
	just.indent(36)
	if imgui.IconOnlyButton("open directory", icons("folder_open"), h, 0.5) then
		self.game.selectController:openDirectory()
	end
	if imgui.IconOnlyButton("update cache", icons("refresh"), h, 0.5) then
		self.game.selectController:updateCache(true)
	end
	just.offset(w - h * 3 - 36)
	if imgui.IconOnlyButton("editor button", icons("create"), h, 0.5) then
		self:edit()
	end
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
