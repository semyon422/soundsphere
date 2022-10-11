local just = require("just")
local spherefonts		= require("sphere.assets.fonts")
local gfx_util		= require("gfx_util")
local time_util = require("time_util")
local loop = require("loop")

local IconButtonImView = require("sphere.imviews.IconButtonImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local LabelImView = require("sphere.imviews.LabelImView")
local TextInputImView = require("sphere.imviews.TextInputImView")
local SpoilerListImView = require("sphere.imviews.SpoilerListImView")
local BackgroundView = require("sphere.views.BackgroundView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoImView = require("sphere.imviews.LogoImView")
local ScoreListView	= require("sphere.views.SelectView.ScoreListView")

local NoteChartSetListView = require("sphere.views.SelectView.NoteChartSetListView")
local NoteChartListView = require("sphere.views.SelectView.NoteChartListView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local CollectionListView = require("sphere.views.SelectView.CollectionListView")
local OsudirectListView = require("sphere.views.SelectView.OsudirectListView")
local OsudirectDifficultiesListView = require("sphere.views.SelectView.OsudirectDifficultiesListView")
local OsudirectProcessingListView = require("sphere.views.SelectView.OsudirectProcessingListView")
local CacheView = require("sphere.views.SelectView.CacheView")
local BarCellImView = require("sphere.imviews.BarCellImView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local Format = require("sphere.views.Format")
local ScrollBarImView = require("sphere.imviews.ScrollBarImView")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local Layout = require("sphere.views.SelectView.Layout")

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

local Frames = {draw = function(self)
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local w, h = Layout:move("base", "header")
	drawFrameRect(w, h, 0)

	local w, h = Layout:move("base", "footer")
	drawFrameRect(w, h, 0)
end}

local invertShader, baseShader, inFrame
local SelectFrame = function()
	if inFrame then
		love.graphics.setShader(baseShader)
		love.graphics.setCanvas()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.origin()
		love.graphics.setBlendMode("alpha", "premultiplied")
		love.graphics.draw(gfx_util.getCanvas(1))
		love.graphics.setBlendMode("alpha")
		inFrame = false
		return
	end
	inFrame = true

	invertShader = invertShader or love.graphics.newShader[[
		extern vec4 rect;
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
			vec4 pixel = Texel(texture, texture_coords);
			if (screen_coords.x > rect.x && screen_coords.x < rect.x + rect.z && screen_coords.y > rect.y && screen_coords.y < rect.y + rect.w) {
				pixel.r = 1 - pixel.r;
				pixel.g = 1 - pixel.g;
				pixel.b = 1 - pixel.b;
			}
			return pixel;
		}
	]]

	local tf = gfx_util.transform(Layout.transform)
	love.graphics.replaceTransform(tf)

	local x, y, w, h = unpack(Layout.column3)
	h = h / 11
	y = y + 5 * h

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas({gfx_util.getCanvas(1), stencil = true})
	love.graphics.clear()

	love.graphics.setColor(1, 0.7, 0.2, 1)
	love.graphics.rectangle("fill", x, y, w, h, h / 2)
	love.graphics.setColor(1, 1, 1, 1)

	baseShader = love.graphics.getShader()
	love.graphics.setShader(invertShader)

	local _x, _y = love.graphics.transformPoint(x, y)
	local _xw, _yh = love.graphics.transformPoint(x + w, y + h)
	local _w, _h = _xw - _x, _yh - _y

	invertShader:send("rect", {_x, _y, _w, _h})
end

local Cache = {
	subscreen = "collections",
	draw = function(self)
		local w, h = Layout:move("column2row2row1")
		drawFrameRect(w, h)

		love.graphics.translate(h / 2, 0)

		CacheView.game = self.game
		CacheView:draw(w - h, h)
	end,
}

local OsudirectList = {
	subscreen = "osudirect",
	draw = function(self)
		local w, h = Layout:move("column3")
		drawFrameRect(w, h)

		SelectFrame()
		local w, h = Layout:move("column3")

		OsudirectListView.game = self.game
		OsudirectListView:draw(w, h)
		SelectFrame()

		local w, h = Layout:move("column3")
		love.graphics.translate(w - 16, 0)

		local list = OsudirectListView
		local count = #list.items - 1
		local pos = (list.visualItemIndex - 1) / count
		local newScroll = ScrollBarImView("osudirect_sb", pos, 16, h, count / list.rows)
		if newScroll then
			list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
		end
	end,
}

local OsudirectDifficultiesList = {
	subscreen = "osudirect",
	draw = function(self)
		local w, h = Layout:move("column2row2")
		drawFrameRect(w, h)

		local w, h = Layout:move("column2row2row1")
		drawFrameRect2(w, h)

		local w, h = Layout:move("column2row2row2")

		OsudirectDifficultiesListView.game = self.game
		OsudirectDifficultiesListView:draw(w, h)
	end,
}

local OsudirectProcessingList = {
	subscreen = "osudirect",
	draw = function(self)
		local w, h = Layout:move("column1")
		drawFrameRect(w, h)

		OsudirectProcessingListView.game = self.game
		OsudirectProcessingListView:draw(w, h)
	end,
}

local ScoreList = {
	subscreen = "notecharts",
	draw = function(self)
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
		local newScroll = ScrollBarImView("score_sb", pos, 16, h, count / list.rows)
		if newScroll then
			list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
		end
	end,
}

local CollectionList = {
	subscreen = "collections",
	draw = function(self)
		local w, h = Layout:move("column3")
		drawFrameRect(w, h)

		SelectFrame()
		local w, h = Layout:move("column3")

		CollectionListView.game = self.game
		CollectionListView:draw(w, h)
		SelectFrame()

		local w, h = Layout:move("column3")
		love.graphics.translate(w - 16, 0)

		local list = CollectionListView
		local count = #list.items - 1
		local pos = (list.visualItemIndex - 1) / count
		local newScroll = ScrollBarImView("collection_sb", pos, 16, h, count / list.rows)
		if newScroll then
			list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
		end
	end,
}

local NoteChartSetList = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = Layout:move("column3")
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, w, h, 36)

		SelectFrame()
		local w, h = Layout:move("column3")

		NoteChartSetListView.game = self.game
		NoteChartSetListView:draw(w, h)
		SelectFrame()

		local w, h = Layout:move("column3")
		love.graphics.translate(w - 16, 0)

		local list = NoteChartSetListView
		local count = #list.items - 1
		local pos = (list.visualItemIndex - 1) / count
		local newScroll = ScrollBarImView("ncs_sb", pos, 16, h, count / list.rows)
		if newScroll then
			list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
		end
	end,
}

local NoteChartList = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = Layout:move("column2row2")
		drawFrameRect(w, h)

		local w, h = Layout:move("column2row2row1")
		drawFrameRect2(w, h)

		local w, h = Layout:move("column2row2row2")

		love.graphics.setColor(1, 1, 1, 0.8)
		love.graphics.polygon("fill",
			0, 72 * 2.2,
			36 * 0.6, 72 * 2.5,
			0, 72 * 2.8
		)

		NoteChartListView.game = self.game
		NoteChartListView:draw(w, h)
	end,
}

local Cells = {draw = function(self)
	if self.screenView.subscreen ~= "notecharts" then
		return
	end

	local w, h = Layout:move("column2row1")

	local baseTimeRate = self.game.rhythmModel.timeEngine.baseTimeRate
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
	just.row(false)

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
	just.row(false)
end}

local BackgroundBlurSwitch = GaussianBlurView:new({
	blur = {key = "game.configModel.configs.settings.graphics.blur.select"}
})

local Background = {
	draw = function(self)
		local w, h = Layout:move("base")

		local dim = self.game.configModel.configs.settings.graphics.dim.select
		BackgroundView.game = self.game
		BackgroundView:draw(w, h, dim, 0.01)
	end,
}

local BackgroundBanner = {
	subscreen = "notecharts",
	load = function(self)
		self.gradient = gfx_util.newGradient(
			"vertical",
			{0, 0, 0, 0},
			{0, 0, 0, 1}
		)
	end,
	draw = function(self)
		local w, h = Layout:move("column2row1")
		drawFrameRect(w, h)

		just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, 36)
		BackgroundView.game = self.game
		BackgroundView:draw(w, h, 0, 0)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.gradient, 0, 0, 0, w, h)
		just.clip()
	end,
}

local SearchField = {
	subscreen = "notecharts",
	draw = function(self)
		if not just.focused_id then
			just.focus("SearchField")
		end
		local padding = 15
		love.graphics.setFont(spherefonts.get("Noto Sans", 20))

		local w, h = Layout:move("column3", "header")
		love.graphics.translate(0, padding)

		local delAll = love.keyboard.isDown("lctrl") and love.keyboard.isDown("backspace")

		local text = self.game.searchModel.filterString
		local changed, text = TextInputImView("SearchField", {text, "Filter..."}, nil, w / 2, h - padding * 2)
		if changed == "text" then
			if delAll then text = "" end
			self.game.searchModel:setSearchString("filter", text)
		end

		w, h = Layout:move("column3", "header")
		love.graphics.translate(w / 2, padding)

		local text = self.game.searchModel.lampString
		local changed, text = TextInputImView("SearchFieldLamp", {text, "Lamp..."}, nil, w / 2, h - padding * 2)
		if changed == "text" then
			if delAll then text = "" end
			self.game.searchModel:setSearchString("lamp", text)
		end
	end,
}

local OsudirectSearchField = {
	subscreen = "osudirect",
	draw = function(self)
		if not just.focused_id then
			just.focus("OsudirectSearchField")
		end
		local padding = 15
		love.graphics.setFont(spherefonts.get("Noto Sans", 20))

		local w, h = Layout:move("column3", "header")
		love.graphics.translate(0, padding)

		local delAll = love.keyboard.isDown("lctrl") and love.keyboard.isDown("backspace")

		local text = self.game.osudirectModel.searchString
		local changed, text = TextInputImView("OsudirectSearchField", {text, "Search..."}, nil, w, h - padding * 2)
		if changed == "text" then
			if delAll then text = "" end
			self.game.osudirectModel:setSearchString(text)
		end
	end,
}

local SortDropdown = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = Layout:move("column2", "header")
		love.graphics.translate(w * 2 / 3, 15)

		local sortModel = self.game.sortModel
		local i = SpoilerListImView("SortDropdown", w / 3, h - 30, sortModel.names, sortModel.name)
		if i then
			self.game.selectModel:setSortFunction(sortModel:fromIndexValue(i), true)
		end
	end,
}

local function filter_to_string(f)
	return f.name
end
local NotechartFilterDropdown = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = Layout:move("column3")

		local size = 1 / 4
		h = 60
		love.graphics.translate(w * (1 - size) - 26, (72 - h) / 2)

		local filters = self.game.configModel.configs.filters.notechart
		local config = self.game.configModel.configs.select
		local i = SpoilerListImView("NotechartFilterDropdown", w * size, h, filters, config.filterName, filter_to_string)
		if i then
			config.filterName = filters[i].name
			self.game.selectModel:noDebouncePullNoteChartSet()
		end
	end,
}

local ScoreFilterDropdown = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = Layout:move("column1")

		local size = 1 / 4
		h = 60
		love.graphics.translate(w * (1 - size) - 26, (72 - h) / 2)

		local filters = self.game.configModel.configs.filters.score
		local config = self.game.configModel.configs.select
		local i = SpoilerListImView("ScoreFilterDropdown", w * size, h, filters, config.scoreFilterName, filter_to_string)
		if i then
			config.scoreFilterName = filters[i].name
			self.game.selectModel:pullScore()
		end
	end,
}

local ScoreSourceDropdown = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = Layout:move("column1")

		local size = 1 / 4
		h = 60
		love.graphics.translate(w * (3 / 4 - size) - 26, (72 - h) / 2)

		local sources = self.game.scoreLibraryModel.scoreSources
		local config = self.game.configModel.configs.select
		local i = SpoilerListImView("ScoreSourceDropdown", w * size, h, sources, config.scoreSourceName)
		if i then
			config.scoreSourceName = sources[i]
			self.game.selectModel:updateScoreOnline()
		end
	end,
}

local GroupCheckbox = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = Layout:move("column2", "header")
		love.graphics.translate(w / 3, 0)
		w = w / 3

		local collapse = self.game.noteChartSetLibraryModel.collapse
		if CheckboxImView(self, collapse, h, 0.4) then
			self.game.selectModel:changeCollapse()
		end
		just.sameline()

		love.graphics.setFont(spherefonts.get("Noto Sans", 20))
		LabelImView(self, "group", h)
	end,
}

local ModifierIconGrid = {
	subscreen = "notecharts",
	draw = function(self)
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
	end,
}

local SessionTime = {draw = function(self)
	local w, h = Layout:move("column2", "header")

	love.graphics.setFont(spherefonts.get("Noto Sans", 20))
	just.indent(10)
	LabelImView("SessionTime", time_util.format(loop.time - loop.startTime), h)
end}

local NotechartsSubscreen = {
	subscreen = "notecharts",
	draw = function(self)
		local _, h = Layout:move("column1", "footer")
		local w = h * 1.5

		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local gameView = self.game.gameView
		just.row(true)
		if IconButtonImView("settings", "settings", h, 0.5) then
			gameView:setModal(require("sphere.views.SettingsView"))
		end
		if IconButtonImView("mounts", "folder_open", h, 0.5) then
			gameView:setModal(require("sphere.views.MountsView"))
		end
		if TextButtonImView("modifiers", "mods", w, h) then
			gameView:setModal(require("sphere.views.ModifierView"))
		end
		if TextButtonImView("noteskins", "skins", w, h) then
			self.game.selectController:resetModifiedNoteChart()
			if self.game.noteChartModel.noteChart then
				gameView:setModal(require("sphere.views.NoteSkinView"))
			end
		end
		if TextButtonImView("input", "input", w, h) then
			self.game.selectController:resetModifiedNoteChart()
			if self.game.noteChartModel.noteChart then
				gameView:setModal(require("sphere.views.InputView"))
			end
		end
		if TextButtonImView("multi", "multi", w, h) then
			gameView:setModal(require("sphere.views.LobbyView"))
		end
		just.row(false)

		w, h = Layout:move("column3", "footer")

		just.row(true)
		if TextButtonImView("collections", "collections", w / 2, h) then
			self.screenView:switchToCollections()
		end
		if TextButtonImView("direct", "direct", w / 2, h) then
			self.screenView:switchToOsudirect()
		end
		just.row(false)

		w, h = Layout:move("column2row2row1")

		just.row(true)
		just.indent(36)
		if IconButtonImView("open directory", "folder_open", h, 0.5) then
			self.game.selectController:openDirectory()
		end
		if IconButtonImView("update cache", "refresh", h, 0.5) then
			self.game.selectController:updateCache(true)
		end
		just.offset(w - h * 2 - 36)
		if IconButtonImView("result", "info_outline", h, 0.5) then
			self.screenView:result()
		end
		if IconButtonImView("play", "keyboard_arrow_right", h, 0.5) then
			self.screenView:play()
		end
		just.row(false)

		w, h = Layout:move("column1row1row1")

		just.indent(36)
		if IconButtonImView("open notechart page", "info_outline", h, 0.5) then
			self.game.selectController:openWebNotechart()
		end
	end,
}

local CollectionsSubscreen = {
	subscreen = "collections",
	draw = function(self)
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local w, h = Layout:move("column1", "footer")

		if TextButtonImView("calc top scores", "calc top scores", w / 2, h) then
			self.game.scoreModel:asyncCalculateTopScores()
		end

		w, h = Layout:move("column3", "footer")

		just.row(true)
		if TextButtonImView("notecharts", "notecharts", w / 2, h) then
			self.screenView:switchToNoteCharts()
		end
		if TextButtonImView("direct", "direct", w / 2, h) then
			self.screenView:switchToOsudirect()
		end
		just.row(false)
	end,
}

local OsudirectSubscreen = {
	subscreen = "osudirect",
	draw = function(self)
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local w, h = Layout:move("column3", "footer")

		just.row(true)
		if TextButtonImView("notecharts", "notecharts", w / 2, h) then
			self.screenView:switchToNoteCharts()
		end
		if TextButtonImView("collections", "collections", w / 2, h) then
			self.screenView:switchToCollections()
		end
		just.row(false)

		w, h = Layout:move("column2row2row1")

		just.indent(36)
		if TextButtonImView("download", "download", w - 72, h) then
			self.game.osudirectModel:downloadBeatmapSet(self.game.osudirectModel.beatmap)
		end
	end,
}

local Header = {draw = function(self)
	local w, h = Layout:move("column1", "header")

	local username = self.game.configModel.configs.online.user.name
	local session = self.game.configModel.configs.online.session
	just.row(true)
	if UserInfoView:draw(w, h, username, session and session.active) then
		self.game.gameView:setModal(require("sphere.views.OnlineView"))
	end
	just.offset(0)

	LogoImView("logo", h, 0.5)
	if IconButtonImView("quit game", "clear", h, 0.5) then
		love.event.quit()
	end
	just.row(false)
end}

local SelectViewConfig = {
	Layout,
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	Frames,
	BackgroundBanner,
	NoteChartSetList,
	OsudirectList,
	CollectionList,
	NoteChartList,
	ScoreList,
	Cells,
	Cache,
	SearchField,
	OsudirectSearchField,
	SortDropdown,
	NotechartFilterDropdown,
	ScoreFilterDropdown,
	ScoreSourceDropdown,
	GroupCheckbox,
	ModifierIconGrid,
	OsudirectDifficultiesList,
	OsudirectProcessingList,
	NotechartsSubscreen,
	CollectionsSubscreen,
	OsudirectSubscreen,
	SessionTime,
	Header,
	require("sphere.views.DebugInfoViewConfig"),
}

return SelectViewConfig
