local _transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local just = require("just")
local spherefonts		= require("sphere.assets.fonts")
local getCanvas		= require("aqua.graphics.canvas")
local rtime = require("aqua.util.rtime")
local time_ago_in_words = require("aqua.util").time_ago_in_words
local newGradient = require("aqua.graphics.newGradient")

local ScrollBarView = require("sphere.views.ScrollBarView")
local IconButtonImView = require("sphere.views.IconButtonImView")
local TextButtonImView = require("sphere.views.TextButtonImView")
local CheckboxImView = require("sphere.views.CheckboxImView")
local LabelImView = require("sphere.views.LabelImView")
local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoView = require("sphere.views.LogoView")
local ScoreListView	= require("sphere.views.ResultView.ScoreListView")

local NoteChartSetListView = require("sphere.views.SelectView.NoteChartSetListView")
local NoteChartListView = require("sphere.views.SelectView.NoteChartListView")
local SearchFieldView = require("sphere.views.SelectView.SearchFieldView")
local SortStepperView = require("sphere.views.SelectView.SortStepperView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local CollectionListView = require("sphere.views.SelectView.CollectionListView")
local OsudirectListView = require("sphere.views.SelectView.OsudirectListView")
local OsudirectDifficultiesListView = require("sphere.views.SelectView.OsudirectDifficultiesListView")
local CacheView = require("sphere.views.SelectView.CacheView")
local BarCellImView = require("sphere.views.SelectView.BarCellImView")
local TextCellImView = require("sphere.views.SelectView.TextCellImView")
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
		self.__index.draw(self)
	end,
})

local OsudirectList = OsudirectListView:new({
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

local ScoreList = ScoreListView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1row1row2)
		self.__index.draw(self)
	end,
	drawItem = function(self, i, w, h)
		local item = self.items[i]
		w = (w - 44) / 5

		just.indent(22)
		TextCellImView(w, h, "right", i == 1 and "rank" or "", item.rank)
		just.sameline()
		TextCellImView(w, h, "right", i == 1 and "rating" or "", Format.difficulty(item.rating))
		just.sameline()
		TextCellImView(w, h, "right", i == 1 and "time rate" or "", Format.timeRate(item.timeRate))
		just.sameline()
		TextCellImView(w * 2, h, "right", item.time ~= 0 and time_ago_in_words(item.time) or "never", item.inputMode)
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
	drawItem = function(self, i, w, h)
		local item = self.items[i]

		TextCellImView(72, h, "right", "", item.count ~= 0 and item.count or "", true)
		just.sameline()
		just.indent(44)
		TextCellImView(math.huge, h, "left", item.shortPath, item.name)
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
	drawItem = function(self, i, w, h)
		local item = self.items[i]

		if item.lamp then
			love.graphics.circle("fill", 22, 36, 7)
			love.graphics.circle("line", 22, 36, 7)
		end

		just.indent(44)
		TextCellImView(math.huge, h, "left", item.artist, item.title)
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
	drawItem = function(self, i, w, h)
		local items = self.items
		local item = items[i]

		just.indent(18)

		local baseTimeRate = self.game.rhythmModel.timeEngine.baseTimeRate

		local difficulty = Format.difficulty((item.difficulty or 0) * baseTimeRate)
		local inputMode = item.inputMode
		local name = item.name
		local creator = item.creator
		if items[i - 1] and items[i - 1].inputMode == inputMode then
			inputMode = ""
		end
		if items[i - 1] and items[i - 1].creator == creator then
			creator = ""
		end

		TextCellImView(72, h, "right", inputMode, difficulty, true)
		just.sameline()

		if item.lamp then
			love.graphics.circle("fill", 22, 36, 7)
			love.graphics.circle("line", 22, 36, 7)
		end
		just.indent(44)

		TextCellImView(math.huge, h, "left", creator, name)
	end,
	rows = 5,
})

local Cells = {draw = function(self)
	if not self.navigator:getSubscreen("notecharts") then
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
		noteCount = noteChartItem.noteCount
		level = noteChartItem.level
		longNoteRatio = noteChartItem.longNoteRatio
		localOffset = noteChartItem.localOffset or 0
	end

	local score = 0
	local difficulty = 0
	local accuracy = 0
	local missCount = 0
	if scoreItem then
		score = scoreItem.score
		difficulty = scoreItem.difficulty
		accuracy = scoreItem.accuracy
		missCount = scoreItem.missCount
		if score ~= score then
			score = 0
		end
	end

	local w = (self.w - 44) / 4
	local h = 50

	local tf = _transform(transform):translate(self.x, self.y + self.h - 118)
	love.graphics.replaceTransform(tf)

	just.indent(22)
	TextCellImView(w, h, "right", "bpm", ("%d"):format(bpm))
	just.sameline()
	TextCellImView(w, h, "right", "duration", rtime(length))
	just.sameline()
	TextCellImView(w, h, "right", "notes", noteCount)
	just.sameline()
	TextCellImView(w, h, "right", "level", level)

	just.indent(22)
	BarCellImView(2 * w, h, "right", "long notes", longNoteRatio)
	just.sameline()
	TextCellImView(2 * w, h, "right", "local offset", localOffset * 1000)

	getRect(self, Layout.column1row2)

	tf = _transform(transform):translate(self.x + self.w / 2, self.y + 6)
	love.graphics.replaceTransform(tf)

	TextCellImView(w, h, "right", "score", ("%d"):format(score))
	just.sameline()
	TextCellImView(w, h, "right", "accuracy", Format.accuracy(accuracy))

	TextCellImView(w, h, "right", "difficulty", Format.difficulty(difficulty))
	just.sameline()
	TextCellImView(w, h, "right", "miss count", ("%d"):format(missCount))
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
	rows = 11,
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
	frame = {
		padding = 6,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		baseline = 35,
		limit = math.huge,
		align = "left",
		font = {"Noto Sans", 20},
	},
	placeholder = "Filter...",
	searchString = "game.searchModel.searchFilter",
	searchMode = "filter",
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
	frame = {
		padding = 6,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		baseline = 35,
		limit = math.huge,
		align = "left",
		font = {"Noto Sans", 20},
	},
	placeholder = "Lamp...",
	searchString = "game.searchModel.searchLamp",
	searchMode = "lamp",
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
	frame = {
		padding = 6,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		baseline = 35,
		limit = 454,
		align = "left",
		font = {"Noto Sans", 20},
	},
	searchString = "game.osudirectModel.searchString",
	searchMode = "osudirect",
})

local SortStepper = SortStepperView:new({
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
	frame = {
		padding = 6,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		xr = 27,
		baseline = 35,
		align = "center",
		font = {"Noto Sans", 20},
	}
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
			self.navigator:changeCollapse()
		end
		just.sameline()

		love.graphics.setFont(spherefonts.get("Noto Sans", 20))
		LabelImView("group", self.h, "left")
	end,
}

local ModifierIconGrid = ModifierIconGridView:new({
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
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1row2)
		self.y = self.y + 4
		self.x = self.x + 21
		self.w = self.w / 2 - 21 * 2
		self.size = (self.h - 8) / 3
		self.__index.draw(self)
	end,
	config = "game.selectModel.scoreItem.modifiers",
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

local SessionTime = ValueView:new({
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column2)
		self.x = self.x + 10
		self.baseline = Layout.header.y + Layout.header.h / 2 + 7
		self.__index.draw(self)
	end,
	value = function()
		local event = require("aqua.event")
		local rtime = require("aqua.util.rtime")
		return rtime(event.time - event.startTime)
	end,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {"Noto Sans", 20},
	align = "left",
})

local BottomNotechartsScreenMenu = {
	subscreen = "notecharts",
	draw = function(self)
		getRect(self, Layout.footer)
		self.x = Layout.column1.x
		self.w = Layout.column1.w

		local w = Layout.column1.w / 2

		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = _transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		if IconButtonImView("settings", "settings", self.h, 0.5) then
			self.navigator:call("openSettings")
		end
		just.sameline()
		if IconButtonImView("mounts", "folder_open", self.h, 0.5) then
			self.navigator:call("openMounts")
		end
		just.sameline()
		if TextButtonImView("modifiers", "modifiers", w, self.h) then
			self.navigator:call("changeScreen", "modifierView")
		end
		just.sameline()
		if TextButtonImView("noteskins", "noteskins", w, self.h) then
			self.navigator:call("openNoteSkins")
		end
		just.sameline()
		if TextButtonImView("input", "input", w, self.h) then
			self.navigator:call("openInput")
		end

		local tf = _transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		if TextButtonImView("collections", "collections", Layout.column3.w, Layout.footer.h) then
			self.navigator:call("switchToCollections")
		end
	end,
}

local BottomCollectionsScreenMenu = {
	subscreen = "collections",
	draw = function(self)
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = _transform(transform):translate(Layout.column1.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		if TextButtonImView("calc top scores", "calc top scores", Layout.column1.w, Layout.footer.h) then
			self.navigator:call("calculateTopScores")
		end

		local tf = _transform(transform):translate(Layout.column2.x + Layout.column2.w / 2, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		if TextButtonImView("direct", "direct", Layout.column2.w / 2, Layout.footer.h) then
			self.navigator:call("switchToOsudirect")
		end

		local tf = _transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		if TextButtonImView("notecharts", "notecharts", Layout.column3.w, Layout.footer.h) then
			self.navigator:call("switchToNoteCharts")
		end
	end,
}

local BottomRightOsudirectScreenMenu = {
	subscreen = "osudirect",
	draw = function(self)
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = _transform(transform):translate(Layout.column2.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		if TextButtonImView("download", "download", Layout.column2.w, Layout.footer.h) then
			self.navigator:call("downloadBeatmapSet")
		end
		just.sameline()
		if TextButtonImView("collections", "collections", Layout.column3.w, Layout.footer.h) then
			self.navigator:call("switchToCollections")
		end
	end,
}

local NoteChartOptionsScreenMenu = {
	subscreen = "notecharts",
	draw = function(self)
		getRect(self, Layout.column2row2row1)

		love.graphics.setFont(spherefonts.get("Noto Sans", 20))

		local tf = _transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		just.indent(36)
		if IconButtonImView("open directory", "folder_open", self.h, 0.5) then
			self.navigator:call("openDirectory")
		end
		just.sameline()
		if IconButtonImView("update cache", "refresh", self.h, 0.5) then
			self.navigator:call("updateCache", true)
		end
		just.sameline()

		local tf = _transform(transform):translate(self.x + self.w - self.h * 2 - 36, self.y)
		love.graphics.replaceTransform(tf)
		if IconButtonImView("result", "info_outline", self.h, 0.5) then
			self.navigator:call("result")
		end
		just.sameline()
		if IconButtonImView("play", "keyboard_arrow_right", self.h, 0.5) then
			self.navigator:call("play")
		end
		just.sameline()
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
	image = {
		x = 21,
		y = 20,
		w = 48,
		h = 48
	},
})

local UserInfo = UserInfoView:new({
	transform = transform,
	username = "game.configModel.configs.online.user.name",
	session = "game.configModel.configs.online.session",
	file = "userdata/avatar.png",
	action = "openOnline",
	draw = function(self)
		getRect(self, Layout.column1)
		self.x = self.x + self.w - Layout.header.h
		self.y = 0
		self.h = Layout.header.h
		self.__index.draw(self)
	end,
	image = {
		x = 21,
		y = 20,
		w = 48,
		h = 48
	},
	marker = {
		x = 97,
		y = 44,
		r = 8,
	},
	text = {
		x = -454 + 89,
		baseline = 54,
		limit = 365,
		align = "right",
		font = {"Noto Sans", 26},
	}
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
	SortStepper,
	GroupCheckbox,
	ModifierIconGrid,
	StageInfoModifierIconGrid,
	OsudirectDifficultiesList,
	BottomNotechartsScreenMenu,
	BottomCollectionsScreenMenu,
	BottomRightOsudirectScreenMenu,
	NoteChartOptionsScreenMenu,
	UpdateStatus,
	SessionTime,
	Logo,
	UserInfo,
	require("sphere.views.DebugInfoViewConfig"),
}

return SelectViewConfig
