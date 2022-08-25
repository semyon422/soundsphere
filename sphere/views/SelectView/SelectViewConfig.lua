local _transform = require("aqua.graphics.transform")
local just = require("just")
local spherefonts		= require("sphere.assets.fonts")
local getCanvas		= require("aqua.graphics.canvas")
local rtime = require("aqua.util.rtime")
local time_ago_in_words = require("aqua.util").time_ago_in_words
local newGradient = require("aqua.graphics.newGradient")
local event = require("aqua.event")

local ScrollBarView = require("sphere.views.ScrollBarView")
local IconButtonImView = require("sphere.imviews.IconButtonImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local LabelImView = require("sphere.imviews.LabelImView")
local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoView = require("sphere.views.LogoView")
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

local Layout = require("sphere.views.SelectView.Layout")

local Cache = CacheView:new({
	subscreen = "collections",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column2row2row1)
		self.x = self.x + self.h / 2
		self.w = self.w - self.h
		self.__index.draw(self)
	end,
})

local OsudirectList = OsudirectListView:new({
	id = "OsudirectListView",
	subscreen = "osudirect",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3)
		self.__index.draw(self)
	end,
	drawItem = function(self, i, w, h)
		local item = self.items[i]

		just.indent(44)
		TextCellImView(math.huge, h, "left", item.artist, item.title)
	end,
	rows = 11,
})

local OsudirectScrollBar = ScrollBarView:new({
	subscreen = "osudirect",
	transform = transform,
	list = OsudirectList,
	draw = function(self)
		getRect(self, Layout.column3)
		self.x = self.x + self.w - 16
		self.w = 16
		self.__index.draw(self)
	end,
	rows = 11,
	backgroundColor = {1, 1, 1, 0},
	color = {1, 1, 1, 0.66}
})

local OsudirectDifficultiesList = OsudirectDifficultiesListView:new({
	subscreen = "osudirect",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column2row2row2)
		self.__index.draw(self)
	end,
	drawItem = function(self, i, w, h)
		local item = self.items[i]

		just.indent(22)
		TextCellImView(math.huge, h, "left", item.beatmap.creator, item.name)
	end,
	rows = 5,
})

local OsudirectProcessingList = OsudirectProcessingListView:new({
	subscreen = "osudirect",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1)
		self.__index.draw(self)
	end,
	drawItem = function(self, i, w, h)
		local item = self.items[i]

		just.row(true)
		just.indent(44)
		TextCellImView(w - 88, h, "right", item.status, "")
		just.indent(88 - w)
		TextCellImView(math.huge, h, "left", item.artist, item.title)
		just.row(false)
	end,
	rows = 11,
})

local ScoreList = ScoreListView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1row1row2)
		self.__index.draw(self)
	end,
	rows = 5,
})

local ScoreScrollBar = ScrollBarView:new({
	subscreen = "notecharts",
	transform = transform,
	list = ScoreList,
	draw = function(self)
		getRect(self, Layout.column1row1row2)
		self.x = self.x + self.w - 16
		self.w = 16
		self.__index.draw(self)
	end,
	rows = 11,
	backgroundColor = {1, 1, 1, 0},
	color = {1, 1, 1, 0.66}
})

local CollectionList = CollectionListView:new({
	subscreen = "collections",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3)
		self.__index.draw(self)
	end,
	rows = 11,
})

local CollectionScrollBar = ScrollBarView:new({
	subscreen = "collections",
	transform = transform,
	list = CollectionList,
	draw = function(self)
		getRect(self, Layout.column3)
		self.x = self.x + self.w - 16
		self.w = 16
		self.__index.draw(self)
	end,
	rows = 11,
	backgroundColor = {1, 1, 1, 0},
	color = {1, 1, 1, 0.66}
})

local NoteChartSetList = NoteChartSetListView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3)
		self.__index.draw(self)
	end,
	rows = 11,
})

local NoteChartSetSelectFrameOff = {
	draw = function(self)
		love.graphics.setShader(self.shader)
		love.graphics.setCanvas()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.origin()
		love.graphics.setBlendMode("alpha", "premultiplied")
		love.graphics.draw(getCanvas(1))
		love.graphics.setBlendMode("alpha")
	end,
}

local NoteChartSetSelectFrameOn = {
	load = function(self)
		self.invertShader = self.invertShader or love.graphics.newShader[[
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
	end,
	draw = function(self)
		local tf = _transform(transform)
		love.graphics.replaceTransform(tf)

		getRect(self, Layout.column3)
		local h = self.h / NoteChartSetList.rows
		local y = self.y + 5 * h
		local x, w = self.x, self.w

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setCanvas({getCanvas(1), stencil = true})
		love.graphics.clear()

		love.graphics.setColor(1, 0.7, 0.2, 1)
		love.graphics.rectangle("fill", x, y, w, h, h / 2)
		love.graphics.setColor(1, 1, 1, 1)

		NoteChartSetSelectFrameOff.shader = love.graphics.getShader()
		love.graphics.setShader(self.invertShader)

		love.graphics.replaceTransform(_transform(transform))

		local _x, _y = love.graphics.transformPoint(x, y)
		local _xw, _yh = love.graphics.transformPoint(x + w, y + h)
		local _w, _h = _xw - _x, _yh - _y

		self.invertShader:send("rect", {_x, _y, _w, _h})
	end,
}

local NoteChartList = NoteChartListView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column2row2row2)
		love.graphics.replaceTransform(_transform(transform))
		love.graphics.setColor(1, 1, 1, 0.8)
		love.graphics.polygon("fill",
			self.x, self.y + 72 * 2.2,
			self.x + 36 * 0.6, self.y + 72 * 2.5,
			self.x, self.y + 72 * 2.8
		)
		self.__index.draw(self)
	end,
	rows = 5,
})

local Cells = {draw = function(self)
	if self.screenView.subscreen ~= "notecharts" then
		return
	end

	getRect(self, Layout.column2row1)

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

	local w = (self.w - 44) / 4
	local h = 50

	local tf = _transform(transform):translate(self.x, self.y + self.h - 118)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	just.row(true)
	just.indent(22)
	TextCellImView(w, h, "right", "bpm", ("%d"):format(bpm))
	TextCellImView(w, h, "right", "duration", rtime(length))
	TextCellImView(w, h, "right", "notes", noteCount)
	TextCellImView(w, h, "right", "level", level)

	just.row(true)
	just.indent(22)
	BarCellImView(2 * w, h, "right", "long notes", longNoteRatio)
	TextCellImView(2 * w, h, "right", "local offset", localOffset * 1000)

	getRect(self, Layout.column1row2)

	just.row(false)
	tf = _transform(transform):translate(self.x + self.w / 2, self.y + 6)
	love.graphics.replaceTransform(tf)

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

local Background = BackgroundView:new({
	transform = transform,
	draw = function(self)
		self.x = Layout.x or 0
		self.y = Layout.y or 0
		self.w = Layout.w or 0
		self.h = Layout.h or 0
		self.__index.draw(self)
	end,
	parallax = 0.01,
	dim = {key = "game.configModel.configs.settings.graphics.dim.select"},
})

local BackgroundBanner = BackgroundView:new({
	subscreen = "notecharts",
	transform = transform,
	load = function(self)
		self.stencilFunction = function()
			love.graphics.replaceTransform(_transform(transform))
			love.graphics.setColor(1, 1, 1, 1)
			local x, y, w, h = getRect(nil, Layout.column2row1)
			love.graphics.rectangle("fill", x, y, w, h, 36)
		end
		self.gradient = newGradient(
			"vertical",
			{0, 0, 0, 0},
			{0, 0, 0, 1}
		)
	end,
	draw = function(self)
		getRect(self, Layout.column2row1)
		love.graphics.stencil(self.stencilFunction)
		love.graphics.setStencilTest("greater", 0)
		self.__index.draw(self)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.replaceTransform(_transform(transform))
		love.graphics.draw(self.gradient, self.x, self.y, 0, self.w, self.h)
		love.graphics.setStencilTest()
	end,
	parallax = 0,
	dim = {value = 0},
})

local NoteChartSetScrollBar = ScrollBarView:new({
	subscreen = "notecharts",
	transform = transform,
	list = NoteChartSetList,
	draw = function(self)
		getRect(self, Layout.column3)
		self.x = self.x + self.w - 16
		self.w = 16
		self.__index.draw(self)
	end,
	backgroundColor = {1, 1, 1, 0},
	color = {1, 1, 1, 0.66}
})

local SearchField = SearchFieldView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3)
		self.w = self.w / 2
		self.y = Layout.header.y + 17
		self.h = Layout.header.h - 34
		self.__index.draw(self)
	end,
	text = {
		x = 27,
		baseline = 35,
		limit = math.huge,
		align = "left",
		font = {"Noto Sans", 20},
	},
	placeholder = "Filter...",
	getText = function(self)
		return self.game.searchModel.filterString
	end,
	setText = function(self, text)
		self.game.searchModel:setSearchString("filter", text)
	end,
	update = function(self)
		if not just.focused_id then
			just.focus(self)
		end
	end,
})

local SearchFieldLamp = SearchFieldView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3)
		self.x = self.x + self.w / 2
		self.w = self.w / 2
		self.y = Layout.header.y + 17
		self.h = Layout.header.h - 34
		self.__index.draw(self)
	end,
	text = {
		x = 27,
		baseline = 35,
		limit = math.huge,
		align = "left",
		font = {"Noto Sans", 20},
	},
	placeholder = "Lamp...",
	getText = function(self)
		return self.game.searchModel.lampString
	end,
	setText = function(self, text)
		self.game.searchModel:setSearchString("lamp", text)
	end,
})

local OsudirectSearchField = SearchFieldView:new({
	subscreen = "osudirect",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3)
		self.w = self.w
		self.y = Layout.header.y + 17
		self.h = Layout.header.h - 34
		self.__index.draw(self)
	end,
	text = {
		x = 27,
		baseline = 35,
		limit = 454,
		align = "left",
		font = {"Noto Sans", 20},
	},
	getText = function(self)
		return self.game.osudirectModel.searchString
	end,
	setText = function(self, text)
		self.game.osudirectModel:setSearchString(text)
	end,
})

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
		love.graphics.replaceTransform(_transform(transform):translate(self.x, self.y))

		local collapse = self.game.noteChartSetLibraryModel.collapse
		if CheckboxImView(self, collapse, self.h, 0.4) then
			self.game.selectModel:changeCollapse()
		end
		just.sameline()

		love.graphics.setFont(spherefonts.get("Noto Sans", 20))
		LabelImView(self, "group", self.h, "left")
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

	local tf = _transform(transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setFont(spherefonts.get("Noto Sans", 20))
	just.text(rtime(event.time - event.startTime))
end}

local NotechartsSubscreen = {
	subscreen = "notecharts",
	draw = function(self)
		getRect(self, Layout.footer)
		self.x = Layout.column1.x
		self.w = Layout.column1.w

		local w = Layout.column1.w / 2.5

		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = _transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		local gameView = self.game.gameView
		just.row(true)
		if IconButtonImView("settings", "settings", self.h, 0.5) then
			gameView.settingsView:toggle()
		end
		if IconButtonImView("mounts", "folder_open", self.h, 0.5) then
			gameView.mountsView:toggle()
		end
		if TextButtonImView("modifiers", "modifiers", w, self.h) then
			gameView.modifierView:toggle()
		end
		if TextButtonImView("noteskins", "noteskins", w, self.h) then
			gameView.noteSkinView:toggle()
		end
		if TextButtonImView("input", "input", w, self.h) then
			gameView.inputView:toggle()
		end
		if TextButtonImView("multi", "multi", self.h, self.h) then
			gameView.lobbyView:toggle()
		end
		just.row(false)

		local tf = _transform(transform):translate(Layout.column3.x, Layout.footer.y)
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
		local tf = _transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		just.row(true)
		just.indent(36)
		if IconButtonImView("open directory", "folder_open", self.h, 0.5) then
			self.game.selectController:openDirectory()
		end
		if IconButtonImView("update cache", "refresh", self.h, 0.5) then
			self.game.selectController:updateCache(true)
		end
		just.offset(self.w - self.h * 2 - 36)
		if IconButtonImView("result", "info_outline", self.h, 0.5) then
			self.screenView:result()
		end
		if IconButtonImView("play", "keyboard_arrow_right", self.h, 0.5) then
			self.screenView:play()
		end
		just.row(false)

		getRect(self, Layout.column1row1row1)
		local tf = _transform(transform):translate(self.x, self.y)
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

		local tf = _transform(transform):translate(Layout.column1.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		if TextButtonImView("calc top scores", "calc top scores", Layout.column1.w / 2, Layout.footer.h) then
			self.game.scoreModel:asyncCalculateTopScores()
		end

		local tf = _transform(transform):translate(Layout.column3.x, Layout.footer.y)
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

		local tf = _transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		just.row(true)
		if TextButtonImView("notecharts", "notecharts", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToNoteCharts()
		end
		if TextButtonImView("collections", "collections", Layout.column3.w / 2, Layout.footer.h) then
			self.screenView:switchToCollections()
		end
		just.row(false)

		local tf = _transform(transform):translate(Layout.column2row2row1.x, Layout.column2row2row1.y)
		love.graphics.replaceTransform(tf)

		just.indent(36)
		if TextButtonImView("download", "download", Layout.column2.w - 72, Layout.column2row2row1.h) then
			self.game.osudirectModel:downloadBeatmapSet(self.game.osudirectModel.beatmap)
		end
	end,
}

local Logo = LogoView:new({
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1)
		self.y = 0
		self.h = Layout.header.h
		self.__index.draw(self)
	end,
})

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
	NoteChartSetSelectFrameOn,
	NoteChartSetList,
	OsudirectList,
	CollectionList,
	NoteChartSetSelectFrameOff,
	NoteChartList,
	ScoreList,
	ScoreScrollBar,
	Cells,
	NoteChartSetScrollBar,
	Cache,
	CollectionScrollBar,
	OsudirectScrollBar,
	SearchField,
	SearchFieldLamp,
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
	Logo,
	UserInfo,
	require("sphere.views.DebugInfoViewConfig"),
}

return SelectViewConfig
