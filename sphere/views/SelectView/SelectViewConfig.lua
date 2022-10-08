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
local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoImView = require("sphere.imviews.LogoImView")
local ScoreListView	= require("sphere.views.SelectView.ScoreListView")

local NoteChartSetListView = require("sphere.views.SelectView.NoteChartSetListView")
local NoteChartListView = require("sphere.views.SelectView.NoteChartListView")
local SearchFieldView = require("sphere.views.SelectView.SearchFieldView")
local SortDropdownView = require("sphere.views.SelectView.SortDropdownView")
local NotechartFilterDropdownView = require("sphere.views.SelectView.NotechartFilterDropdownView")
local ScoreFilterDropdownView = require("sphere.views.SelectView.ScoreFilterDropdownView")
local ScoreSourceDropdownView = require("sphere.views.SelectView.ScoreSourceDropdownView")
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

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local function getRect(out, r)
	if not out then
		return r.x, r.y, r.w, r.h
	end
	out.x = r.x
	out.y = r.y
	out.w = r.w
	out.h = r.h
end

local function move(layout_x, layout_y)
	local _
	local x, y, w, h = getRect(nil, layout_x)
	if layout_y then
		_, y, _, h = getRect(nil, layout_y)
	end

	local tf = gfx_util.transform(transform)
	tf:translate(x, y)
	love.graphics.replaceTransform(tf)

	return w, h
end

local Layout = require("sphere.views.SelectView.Layout")

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

	local tf = gfx_util.transform(transform)
	love.graphics.replaceTransform(tf)

	local x, y, w, h = getRect(nil, Layout.column3)
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
		local w, h = move(Layout.column2row2row1)

		love.graphics.translate(h / 2, 0)

		CacheView.game = self.game
		CacheView:draw(w - h, h)
	end,
}

local OsudirectList = {
	subscreen = "osudirect",
	draw = function(self)
		SelectFrame()
		local w, h = move(Layout.column3)

		OsudirectListView.game = self.game
		OsudirectListView:draw(w, h)
		SelectFrame()

		local w, h = move(Layout.column3)
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
		local w, h = move(Layout.column2row2row2)
		OsudirectDifficultiesListView.game = self.game
		OsudirectDifficultiesListView:draw(w, h)
	end,
}

local OsudirectProcessingList = {
	subscreen = "osudirect",
	draw = function(self)
		local w, h = move(Layout.column1)
		OsudirectProcessingListView.game = self.game
		OsudirectProcessingListView:draw(w, h)
	end,
}

local ScoreList = {
	subscreen = "notecharts",
	draw = function(self)
		local w, h = move(Layout.column1row1row2)

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
		SelectFrame()
		local w, h = move(Layout.column3)

		CollectionListView.game = self.game
		CollectionListView:draw(w, h)
		SelectFrame()

		local w, h = move(Layout.column3)
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
		SelectFrame()
		local w, h = move(Layout.column3)

		NoteChartSetListView.game = self.game
		NoteChartSetListView:draw(w, h)
		SelectFrame()

		local w, h = move(Layout.column3)
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
		local w, h = move(Layout.column2row2row2)

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

	local w, h = move(Layout.column2row1)

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

	w, h = move(Layout.column1row2)
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
		local w, h = move(Layout)

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
		local w, h = move(Layout.column2row1)

		just.clip(love.graphics.rectangle, "fill", 0, 0, w, h, 36)
		love.graphics.setColor(1, 1, 1, 1)
		BackgroundView.game = self.game
		BackgroundView:draw(w, h, 0, 0)
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

		local w, h = move(Layout.column3, Layout.header)
		love.graphics.translate(0, padding)

		local delAll = love.keyboard.isDown("lctrl") and love.keyboard.isDown("backspace")

		local text = self.game.searchModel.filterString
		local changed, text = TextInputImView("SearchField", {text, "Filter..."}, nil, w / 2, h - padding * 2)
		if changed == "text" then
			if delAll then text = "" end
			self.game.searchModel:setSearchString("filter", text)
		end

		w, h = move(Layout.column3, Layout.header)
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

		local w, h = move(Layout.column3, Layout.header)
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

local SortDropdown = SortDropdownView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column2)
		self.x = self.x + self.w * 2 / 3
		self.w = self.w / 3
		self.y = Layout.header.y + 17
		self.h = Layout.header.h - 34
		self.__index.draw(self)
	end,
})

local NotechartFilterDropdown = NotechartFilterDropdownView:new({
	subscreen = "notecharts",
	transform = transform,
	closedBackgroundColor = {0, 0, 0, 0.8},
	draw = function(self)
		getRect(self, Layout.column3)
		local size = 1 / 4
		self.x = self.x + self.w * (1 - size) - 6 - 20
		self.w = self.w * size
		self.h = 55
		self.y = self.y + (72 - self.h) / 2
		self.__index.draw(self)
	end,
})

local ScoreFilterDropdown = ScoreFilterDropdownView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1)
		local size = 1 / 4
		self.x = self.x + self.w * (1 - size) - 6 - 20
		self.w = self.w * size
		self.h = 55
		self.y = self.y + (72 - self.h) / 2
		self.__index.draw(self)
	end,
})

local ScoreSourceDropdown = ScoreSourceDropdownView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1)
		local size = 1 / 4
		self.x = self.x + self.w * (3 / 4 - size) - 6 - 20
		self.w = self.w * size
		self.h = 55
		self.y = self.y + (72 - self.h) / 2
		self.__index.draw(self)
	end,
})

local GroupCheckbox = {
	subscreen = "notecharts",
	draw = function(self)
		getRect(self, Layout.column2)
		self.x = self.x + self.w * 1 / 3
		self.w = self.w / 3
		self.y = Layout.header.y
		self.h = Layout.header.h
		love.graphics.replaceTransform(gfx_util.transform(transform):translate(self.x, self.y))

		local collapse = self.game.noteChartSetLibraryModel.collapse
		if CheckboxImView(self, collapse, self.h, 0.4) then
			self.game.selectModel:changeCollapse()
		end
		just.sameline()

		love.graphics.setFont(spherefonts.get("Noto Sans", 20))
		LabelImView(self, "group", self.h)
	end,
}

local ModifierIconGrid = ModifierIconGridView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1row3)
		self.y = self.y + 4
		self.x = self.x + 21
		self.w = self.w - 21 * 2
		self.size = (self.h - 8) / 2
		self.__index.draw(self)
	end,
	config = "game.modifierModel.config"
})

local StageInfoModifierIconGrid = ModifierIconGridView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1row2)
		self.y = self.y + 4
		self.x = self.x + 21
		self.w = self.w / 2 - 21 * 2
		self.size = (self.h - 8) / 3
		self.__index.draw(self)
	end,
	config = {
		"game.selectModel.scoreItem.modifiers",
		"game.selectModel.scoreItem.modifierset.encoded",
	},
	noModifier = true
})

local UpdateStatus = ValueView:new({
	transform = transform,
	key = "game.updateModel.status",
	x = 0,
	baseline = 1070,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {"Noto Sans Mono", 24},
	align = "left",
})

local SessionTime = {draw = function(self)
	getRect(self, Layout.column2)
	self.x = self.x + 10
	self.y = Layout.header.y + Layout.header.h / 2 - 17

	local tf = gfx_util.transform(transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setFont(spherefonts.get("Noto Sans", 20))
	just.text(time_util.format(loop.time - loop.startTime))
end}

local NotechartsSubscreen = {
	subscreen = "notecharts",
	draw = function(self)
		getRect(self, Layout.footer)
		self.x = Layout.column1.x
		self.w = Layout.column1.w

		local h = self.h
		local w = h * 1.5

		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = gfx_util.transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

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

		local tf = gfx_util.transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		just.row(true)
		if TextButtonImView("collections", "collections", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToCollections()
		end
		if TextButtonImView("direct", "direct", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToOsudirect()
		end
		just.row(false)

		getRect(self, Layout.column2row2row1)
		local tf = gfx_util.transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		h = self.h

		just.row(true)
		just.indent(36)
		if IconButtonImView("open directory", "folder_open", h, 0.5) then
			self.game.selectController:openDirectory()
		end
		if IconButtonImView("update cache", "refresh", h, 0.5) then
			self.game.selectController:updateCache(true)
		end
		just.offset(self.w - h * 2 - 36)
		if IconButtonImView("result", "info_outline", h, 0.5) then
			self.screenView:result()
		end
		if IconButtonImView("play", "keyboard_arrow_right", h, 0.5) then
			self.screenView:play()
		end
		just.row(false)

		getRect(self, Layout.column1row1row1)
		local tf = gfx_util.transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		just.indent(36)
		if IconButtonImView("open notechart page", "info_outline", self.h, 0.5) then
			self.game.selectController:openWebNotechart()
		end
	end,
}

local CollectionsSubscreen = {
	subscreen = "collections",
	draw = function(self)
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = gfx_util.transform(transform):translate(Layout.column1.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		if TextButtonImView("calc top scores", "calc top scores", Layout.column1.w / 2, Layout.footer.h) then
			self.game.scoreModel:asyncCalculateTopScores()
		end

		local tf = gfx_util.transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		just.row(true)
		if TextButtonImView("notecharts", "notecharts", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToNoteCharts()
		end
		if TextButtonImView("direct", "direct", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToOsudirect()
		end
		just.row(false)
	end,
}

local OsudirectSubscreen = {
	subscreen = "osudirect",
	draw = function(self)
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = gfx_util.transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		just.row(true)
		if TextButtonImView("notecharts", "notecharts", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToNoteCharts()
		end
		if TextButtonImView("collections", "collections", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToCollections()
		end
		just.row(false)

		local tf = gfx_util.transform(transform):translate(Layout.column2row2row1.x, Layout.column2row2row1.y)
		love.graphics.replaceTransform(tf)

		just.indent(36)
		if TextButtonImView("download", "download", Layout.column2.w - 72, Layout.column2row2row1.h) then
			self.game.osudirectModel:downloadBeatmapSet(self.game.osudirectModel.beatmap)
		end
	end,
}

local Header = {draw = function(self)
	local w, h = move(Layout.header)
	love.graphics.translate(Layout.column1.x, 0)

	just.row(true)
	LogoImView("logo", h, 0.5)
	if IconButtonImView("quit game", "clear", h, 0.5) then
		love.event.quit()
	end
	just.row(false)
end}

local UserInfo = UserInfoView:new({
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1)
		self.x = self.x + self.w - Layout.header.h
		self.y = 0
		self.h = Layout.header.h
		self.__index.draw(self)
	end,
})

local SelectViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	Layout,
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
	StageInfoModifierIconGrid,
	OsudirectDifficultiesList,
	OsudirectProcessingList,
	NotechartsSubscreen,
	CollectionsSubscreen,
	OsudirectSubscreen,
	UpdateStatus,
	SessionTime,
	Header,
	UserInfo,
	require("sphere.views.DebugInfoViewConfig"),
}

return SelectViewConfig
