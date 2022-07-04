local _transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local just = require("just")
local spherefonts		= require("sphere.assets.fonts")
local getCanvas		= require("aqua.graphics.canvas")
local rtime = require("aqua.util.rtime")
local time_ago_in_words = require("aqua.util").time_ago_in_words
local newGradient = require("aqua.graphics.newGradient")

local ScrollBarView = require("sphere.views.ScrollBarView")
local IconButtonView = require("sphere.views.IconButtonView")
local RectangleView = require("sphere.views.RectangleView")
local LineView = require("sphere.views.LineView")
local ScreenMenuView = require("sphere.views.ScreenMenuView")
local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoView = require("sphere.views.LogoView")
local SwitchView = require("sphere.views.SwitchView")
local ScoreListView	= require("sphere.views.ResultView.ScoreListView")

local NoteChartSetListView = require("sphere.views.SelectView.NoteChartSetListView")
local NoteChartListView = require("sphere.views.SelectView.NoteChartListView")
local SearchFieldView = require("sphere.views.SelectView.SearchFieldView")
local SortStepperView = require("sphere.views.SelectView.SortStepperView")
local StageInfoView = require("sphere.views.SelectView.StageInfoView")
local ModifierIconGridView = require("sphere.views.SelectView.ModifierIconGridView")
local CollectionListView = require("sphere.views.SelectView.CollectionListView")
local OsudirectListView = require("sphere.views.SelectView.OsudirectListView")
local OsudirectDifficultiesListView = require("sphere.views.SelectView.OsudirectDifficultiesListView")
local CacheView = require("sphere.views.SelectView.CacheView")
local CellView = require("sphere.views.SelectView.CellView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local formatScore = function(score)
	score = tonumber(score) or math.huge
	if score >= 0.1 then
		return "100+"
	end
	return ("%2.2f"):format(score * 1000)
end

local formatDifficulty = function(difficulty)
	if difficulty ~= difficulty then
		return "nan"
	end
	local format = "%.2f"
	if not difficulty then
		return ""
	elseif difficulty >= 10000 then
		format = "%s"
		difficulty = "????"
	elseif difficulty >= 100 then
		format = "%d"
	elseif difficulty > 9.995 then
		format = "%.1f"
	end
	return format:format(difficulty)
end

local formatTimeRate = function(timeRate)
	local exp = 10 * math.log(timeRate) / math.log(2)
	local roundedExp = math.floor(exp + 0.5)
	if math.abs(exp - roundedExp) % 1 < 1e-2 and math.abs(exp) > 1e-2 then
		return ("%dQ"):format(roundedExp)
	end
	return ("%.2f"):format(timeRate)
end

local Layout = {
	header = {},
	footer = {},
	subheader = {},
	column1 = {},
	column2 = {},
	column3 = {},
	column2row1 = {},
	column2row2 = {},
	column2row2row1 = {},
	column2row2row2 = {},
	column1row1 = {},
	column1row2 = {},
	column1row3 = {},
	column1row1row1 = {},
	column1row1row2 = {},
}

local function setRect(t, x, y, w, h)
	t.x = assert(x)
	t.y = assert(y)
	t.w = assert(w)
	t.h = assert(h)
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

local function addPoint(points, x, y)
	table.insert(points, x)
	table.insert(points, y)
end
local function rectangle2(mode, x, y, w, h, r)
	local points = {}
	addPoint(points, x + r, y)
	addPoint(points, x + w - r, y)
	for a = -math.pi / 2, 0, math.pi / 64 do
		addPoint(points, x + w - r + math.cos(a) * r, y + r + math.sin(a) * r)
	end
	addPoint(points, x + w, y + h)
	addPoint(points, x, y + h)
	addPoint(points, x, y + r)
	for a = -math.pi, -math.pi / 2, math.pi / 64 do
		addPoint(points, x + r + math.cos(a) * r, y + r + math.sin(a) * r)
	end
	love.graphics.polygon(mode, points)

	points = {}
	addPoint(points, x + w, y + h)
	addPoint(points, x + w, y + h + r)
	for a = 0, -math.pi / 2, -math.pi / 64 do
		addPoint(points, x + w - r + math.cos(a) * r, y + h + r + math.sin(a) * r)
	end
	addPoint(points, x + w - r, y + h)
	love.graphics.polygon(mode, points)

	points = {}
	addPoint(points, x, y + h)
	addPoint(points, x + r, y + h)
	for a = -math.pi / 2, -math.pi, -math.pi / 64 do
		addPoint(points, x + r + math.cos(a) * r, y + h + r + math.sin(a) * r)
	end
	addPoint(points, x, y + h + r)
	love.graphics.polygon(mode, points)
end

local function drawFrame(rect)
	local x, y, w, h = getRect(nil, rect)
	love.graphics.rectangle("fill", x, y, w, h, 36)
end

local Frames = {draw = function()
	local width, height = love.graphics.getDimensions()
	love.graphics.origin()

	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, width, height)

	love.graphics.replaceTransform(_transform(transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
	local _w, _h = _xw - _x, _yh - _y

	Layout.x, Layout.x = _x, _y
	Layout.w, Layout.h = _w, _h

	local x_int = 24
	local y_int = 55

	local x0, w0 = just.layout(0, 1920, {1920})
	-- local x1, w1 = just.layout(0, 1920, {24, -1/3, -1/3, -1/3, 24})
	local x1, w1 = just.layout(_x, _w, {y_int, -1/3, x_int, -1/3, x_int, -1/3, y_int})

	local y0, h0 = just.layout(0, 1080, {89, y_int, -1, y_int, 89})

	Layout.x0, Layout.w0 = x0, w0
	Layout.x1, Layout.w1 = x1, w1
	Layout.y0, Layout.h0 = y0, h0

	setRect(Layout.header, x0[1], y0[1], w0[1], h0[1])
	setRect(Layout.footer, x0[1], y0[5], w0[1], h0[5])
	setRect(Layout.subheader, x1[4], y0[2], w1[4], h0[2])

	setRect(Layout.column1, x1[2], y0[3], w1[2], h0[3])
	setRect(Layout.column2, x1[4], y0[3], w1[4], h0[3])
	setRect(Layout.column3, x1[6], y0[3], w1[6], h0[3])

	local y1, h1 = just.layout(Layout.column2.y, Layout.column2.h, {-1, x_int, 72 * 6})

	setRect(Layout.column2row1, x1[4], y1[1], w1[4], h1[1])
	setRect(Layout.column2row2, x1[4], y1[3], w1[4], h1[3])

	local y2, h2 = just.layout(Layout.column2row2.y, Layout.column2row2.h, {72, 72 * 5})

	setRect(Layout.column2row2row1, x1[4], y2[1], w1[4], h2[1])
	setRect(Layout.column2row2row2, x1[4], y2[2], w1[4], h2[2])

	local y3, h3 = just.layout(Layout.column1.y, Layout.column1.h, {72 * 6, x_int, -1, x_int, 72 * 2})

	setRect(Layout.column1row1, x1[2], y3[1], w1[2], h3[1])
	setRect(Layout.column1row2, x1[2], y3[3], w1[2], h3[3])
	setRect(Layout.column1row3, x1[2], y3[5], w1[2], h3[5])

	local y4, h4 = just.layout(Layout.column1row1.y, Layout.column1row1.h, {72, -1})

	setRect(Layout.column1row1row1, x1[2], y4[1], w1[2], h4[1])
	setRect(Layout.column1row1row2, x1[2], y4[2], w1[2], h4[2])

	love.graphics.setColor(0, 0, 0, 0.8)

	drawFrame(Layout.column1row1)
	drawFrame(Layout.column1row2)
	drawFrame(Layout.column1row3)
	drawFrame(Layout.column2row1)
	drawFrame(Layout.column2row2)
	drawFrame(Layout.column3)

	love.graphics.setColor(0.4, 0.4, 0.4, 0.7)

	local x, y, w, h = getRect(nil, Layout.column2row2row1)
	rectangle2("fill", x, y, w, h, 36)

	x, y, w, h = getRect(nil, Layout.column1row1row1)
	rectangle2("fill", x, y, w, h, 36)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", _x, _y, _w, h0[1])
	love.graphics.rectangle("fill", _x, _yh - h0[5], _w, h0[1])
end}

local Cache = CacheView:new({
	subscreen = "collections",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column2)
		self.y = 504
		self.h = 72
		self.__index.draw(self)
	end,
	text = {
		type = "text",
		x = 44,
		baseline = 45,
		limit = 1920,
		align = "left",
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
})

local OsudirectList = OsudirectListView:new({
	subscreen = "osudirect",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column3)
		self.__index.draw(self)
	end,
	rows = 11,
	elements = {
		{
			type = "text",
			key = "title",
			onNew = false,
			x = 44,
			baseline = 45,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "artist",
			onNew = false,
			x = 45,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
	},
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
	rows = 5,
	elements = {
		{
			type = "text",
			key = "name",
			onNew = false,
			x = 116,
			baseline = 45,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "beatmap.creator",
			onNew = true,
			x = 117,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "cs",
			format = "%skey",
			onNew = true,
			x = 17,
			baseline = 19,
			limit = 500,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "sr",
			onNew = false,
			x = 0,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
			format = formatDifficulty
		},
	},
})


local ScoreList = ScoreListView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column1row1row2)
		self.cell.w = self.w / 5
		self.__index.draw(self)
	end,
	drawItem = function(self, itemIndex, w, h)
		local item = self.items[itemIndex]

		CellView:drawCell(self.cell, "text", 1, itemIndex == 1 and "rank" or "", item.rank)
		just.sameline()
		CellView:drawCell(self.cell, "text", 1, itemIndex == 1 and "rating" or "", formatDifficulty(item.rating))
		just.sameline()
		CellView:drawCell(self.cell, "text", 1, itemIndex == 1 and "time rate" or "", formatTimeRate(item.timeRate))
		just.sameline()
		CellView:drawCell(self.cell, "text", 2, item.time ~= 0 and time_ago_in_words(item.time) or "never", item.inputMode)
	end,
	rows = 5,
	cell = {
		h = 72,
		name = {
			x = 22,
			xr = 22,
			baseline = 19,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		value = {
			text = {
				x = 22,
				xr = 22,
				baseline = 45,
				align = "right",
				font = {
					filename = "Noto Sans",
					size = 24,
				},
			},
		}
	},
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
	elements = {
		{
			type = "text",
			key = "name",
			onNew = false,
			x = 116,
			baseline = 45,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "shortPath",
			onNew = false,
			x = 117,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "count",
			onNew = false,
			format = function(value)
				return value ~= 0 and value or ""
			end,
			x = 0,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
		},
	},
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
	elements = {
		{
			type = "text",
			key = "title",
			onNew = false,
			x = 44,
			baseline = 45,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "artist",
			onNew = false,
			x = 45,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "circle",
			key = "lamp",
			onNew = false,
			x = 22,
			y = 36,
			r = 7
		},
	},
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
		self.h = self.h / NoteChartSetList.rows
		self.y = self.y + 5 * self.h

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setCanvas({getCanvas(1), stencil = true})
		love.graphics.clear()

		love.graphics.setColor(1, 0.7, 0.2, 1)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.h / 2)
		love.graphics.setColor(1, 1, 1, 1)

		NoteChartSetSelectFrameOff.shader = love.graphics.getShader()
		love.graphics.setShader(self.invertShader)

		love.graphics.replaceTransform(_transform(transform))

		local _x, _y = love.graphics.transformPoint(self.x, self.y)
		local _xw, _yh = love.graphics.transformPoint(self.x + self.w, self.y + self.h)
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
	elements = {
		{
			type = "text",
			key = "name",
			onNew = false,
			x = 116 + 18,
			baseline = 45,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "creator",
			onNew = true,
			x = 117 + 18,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "inputMode",
			onNew = true,
			x = 17 + 18,
			baseline = 19,
			limit = 500,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			value = function(self, item)
				local baseTimeRate = self.game.rhythmModel.timeEngine.baseTimeRate
				return (item.difficulty or 0) * baseTimeRate
			end,
			onNew = false,
			x = 0 + 18,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
			format = formatDifficulty
		},
		{
			type = "circle",
			key = "lamp",
			onNew = false,
			x = 94 + 18,
			y = 36,
			r = 7
		},
	},
})

local Cells = CellView:new({
	subscreen = "notecharts",
	transform = transform,
	draw = function(self)
		getRect(self, Layout.column2row1)

		self.smallCell.w = self.w / 4

		local tf = _transform(transform):translate(self.x, self.y + self.h - 118)
		love.graphics.replaceTransform(tf)

		local baseTimeRate = self.game.rhythmModel.timeEngine.baseTimeRate
		local noteChartItem = self.game.selectModel.noteChartItem
		local scoreItem = self.game.selectModel.scoreItem

		local bpm = 0
		local length = 0
		if noteChartItem then
			bpm = (noteChartItem.bpm or 0) * baseTimeRate
			length = (noteChartItem.length or 0) / baseTimeRate
		end

		local score = 0
		local rating = 0
		local difficulty = 0
		local accuracy = 0
		local time = 0
		local missCount = 0
		if scoreItem then
			score = scoreItem.score
			rating = scoreItem.rating
			difficulty = scoreItem.difficulty
			time = scoreItem.time
			missCount = scoreItem.missCount
			if score ~= score then
				score = 0
			end
		end

		self:drawCell(self.smallCell, "text", 1, "bpm", ("%d"):format(bpm))
		just.sameline()
		self:drawCell(self.smallCell, "text", 1, "duration", rtime(length))
		just.sameline()
		self:drawCell(self.smallCell, "text", 1, "notes", noteChartItem.noteCount)
		just.sameline()
		self:drawCell(self.smallCell, "text", 1, "level", noteChartItem.level)
		self:drawCell(self.smallCell, "bar", 2, "long notes", noteChartItem.longNoteRatio)
		just.sameline()
		self:drawCell(self.smallCell, "text", 2, "local offset", (noteChartItem.localOffset or 0) * 1000)

		getRect(self, Layout.column1row2)

		tf = _transform(transform):translate(self.x + self.w / 2, self.y + 6)
		love.graphics.replaceTransform(tf)

		-- self:drawCell(self.smallCell, "text", 1, "rating", formatDifficulty(rating))
		-- just.sameline()
		self:drawCell(self.smallCell, "text", 1, "score", ("%d"):format(score))
		just.sameline()
		self:drawCell(self.smallCell, "text", 1, "accuracy", formatScore(accuracy))

		-- local time_ago = time ~= 0 and time_ago_in_words(time) or "never"
		-- self:drawCell(self.smallCell, "text", 1, "played time ago", time_ago)
		self:drawCell(self.smallCell, "text", 1, "difficulty", formatDifficulty(difficulty))
		just.sameline()

		-- love.graphics.push()
		self:drawCell(self.smallCell, "text", 1, "miss count", ("%d"):format(missCount))
		-- love.graphics.pop()

	end,
	smallCell = {
		w = 90,
		-- w = 113,
		h = 50,
		name = {
			x = 22,
			xr = 22,
			baseline = 18,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		value = {
			text = {
				x = 22,
				xr = 22,
				baseline = 44,
				align = "right",
				font = {
					filename = "Noto Sans",
					size = 24,
				},
			},
			bar = {
				x = 22,
				xr = 22,
				y = 26,
				h = 19
			}
		}
	},
	largeCell = {
		w = 227,
		h = 72,
		name = {
			x = 22,
			xr = 22,
			baseline = 15,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 18,
			},
		},
		value = {
			text = {
				x = 22,
				xr = 22,
				baseline = 49,
				align = "right",
				font = {
					filename = "Noto Sans",
					size = 36,
				},
			}
		}
	}
})

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
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
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
			drawFrame(Layout.column2row1)
		end
		self.gradient = newGradient(
			"vertical",
			{0, 0, 0, 0},
			{0, 0, 0, 1}
		)
		print(self.gradient)
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
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
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
	x = 1641,
	y = 144,
	w = 16,
	h = 792,
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
		font = {
			filename = "Noto Sans",
			size = 20,
		},
	},
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
		font = {
			filename = "Noto Sans",
			size = 20,
		},
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
		font = {
			filename = "Noto Sans",
			size = 20,
		},
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
		font = {
			filename = "Noto Sans",
			size = 20,
		},
	}
})

local GroupCheckbox = {
	subscreen = "notecharts",
	draw = function(self)
		getRect(self, Layout.column2)
		self.x = self.x + self.w * 1 / 3
		self.w = self.w / 3
		self.y = Layout.header.y + 17
		self.h = Layout.header.h - 34
		love.graphics.replaceTransform(_transform(transform):translate(self.x, self.y))

		local over = SwitchView:isOver(self.w, self.h)
		local changed = just.button_behavior(self, over)
		if changed then
			self.navigator:changeCollapse()
		end
		local collapse = self.game.noteChartSetLibraryModel.collapse
		SwitchView:draw(self.h, self.h, collapse)

		love.graphics.translate(self.h / 2, 0)

		local text = self.text
		local font = spherefonts.get(text.font)
		love.graphics.setFont(font)
		baseline_print(
			"group",
			text.x,
			text.baseline,
			self.w - text.x - text.xr,
			1,
			text.align
		)
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
		align = "left",
		font = {
			filename = "Noto Sans",
			size = 20,
		},
	}
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
	font = {
		filename = "Noto Sans Mono",
		size = 24,
	},
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
	baseline = 279 + 522 - 6,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {
		filename = "Noto Sans",
		size = 20,
	},
	align = "left",
})

local BottomNotechartsScreenMenu = ScreenMenuView:new({
	subscreen = "notecharts",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
	draw = function(self)
		getRect(self, Layout.footer)
		self.x = Layout.column1.x
		self.w = Layout.column1.w

		local w = Layout.column1.w / 2

		local font = spherefonts.get(self.font)
		love.graphics.setFont(font)

		local tf = _transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		if IconButtonView:draw("settings", "settings", self.h, 0.5) then
			self.navigator:call("openSettings")
		end
		just.sameline()
		if IconButtonView:draw("mounts", "folder_open", self.h, 0.5) then
			self.navigator:call("openMounts")
		end
		just.sameline()

		self:button("modifiers", w, self.h, "changeScreen", "modifierView")
		just.sameline()
		self:button("noteskins", w, self.h, "openNoteSkins")
		just.sameline()
		self:button("input", w, self.h, "openInput")

		local tf = _transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		self:button("collections", Layout.column3.w, Layout.footer.h, "switchToCollections")
	end,
})

local BottomCollectionsScreenMenu = ScreenMenuView:new({
	subscreen = "collections",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
	draw = function(self)
		local font = spherefonts.get(self.font)
		love.graphics.setFont(font)

		local tf = _transform(transform):translate(Layout.column1.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		self:button("calc top scores", Layout.column1.w, Layout.footer.h, "calculateTopScores")

		local tf = _transform(transform):translate(Layout.column2.x + Layout.column2.w / 2, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		self:button("direct", Layout.column2.w / 2, Layout.footer.h, "switchToOsudirect")

		local tf = _transform(transform):translate(Layout.column3.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		self:button("notecharts", Layout.column3.w, Layout.footer.h, "switchToNoteCharts")
	end,
})

local BottomRightOsudirectScreenMenu = ScreenMenuView:new({
	subscreen = "osudirect",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
	draw = function(self)
		local font = spherefonts.get(self.font)
		love.graphics.setFont(font)

		local tf = _transform(transform):translate(Layout.column2.x, Layout.footer.y)
		love.graphics.replaceTransform(tf)

		self:button("download", Layout.column2.w, Layout.footer.h, "downloadBeatmapSet")
		just.sameline()
		self:button("collections", Layout.column3.w, Layout.footer.h, "switchToCollections")
	end,
})

local NoteChartOptionsScreenMenu = {
	subscreen = "notecharts",
	font = {
		filename = "Noto Sans",
		size = 20,
	},
	draw = function(self)
		getRect(self, Layout.column2row2row1)

		local font = spherefonts.get(self.font)
		love.graphics.setFont(font)

		local tf = _transform(transform):translate(self.x, self.y)
		love.graphics.replaceTransform(tf)

		just.indent(36)
		if IconButtonView:draw("open directory", "folder_open", self.h, 0.5) then
			self.navigator:call("openDirectory")
		end
		just.sameline()
		if IconButtonView:draw("update cache", "refresh", self.h, 0.5) then
			self.navigator:call("updateCache", true)
		end
		just.sameline()

		local tf = _transform(transform):translate(self.x + self.w - self.h * 2 - 36, self.y)
		love.graphics.replaceTransform(tf)
		if IconButtonView:draw("result", "info_outline", self.h, 0.5) then
			self.navigator:call("result")
		end
		just.sameline()
		if IconButtonView:draw("play", "keyboard_arrow_right", self.h, 0.5) then
			self.navigator:call("play")
		end
		just.sameline()
	end,
}

local Rectangle = RectangleView:new({
	transform = transform,
	rectangles = {},
})

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
	-- text = {
	-- 	x = 89,
	-- 	baseline = 56,
	-- 	limit = 365,
	-- 	align = "left",
	-- 	font = {
	-- 		filename = "Noto Sans",
	-- 		size = 32,
	-- 	},
	-- }
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
		-- self.x = Layout.x1[5] - Layout.h0[1]
		-- self.y = Layout.y0[1]
		-- self.w = Layout.w1[2]
		-- self.h = Layout.h0[1]
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
		font = {
			filename = "Noto Sans",
			size = 26,
		},
	}
})

local SelectViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	Frames,
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
	Rectangle,
	Logo,
	UserInfo,
	require("sphere.views.DebugInfoViewConfig"),
}

return SelectViewConfig
