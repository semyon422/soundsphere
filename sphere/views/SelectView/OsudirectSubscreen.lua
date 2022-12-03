local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local OsudirectListView = require("sphere.views.SelectView.OsudirectListView")
local OsudirectDifficultiesListView = require("sphere.views.SelectView.OsudirectDifficultiesListView")
local OsudirectProcessingListView = require("sphere.views.SelectView.OsudirectProcessingListView")
local RoundedRectangle = require("sphere.views.RoundedRectangle")
local imgui = require("imgui")

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

local function OsudirectList(self)
	local w, h = Layout:move("column3")
	drawFrameRect(w, h)

	SelectFrame()
	OsudirectListView.game = self.game
	OsudirectListView:draw(w, h)
	SelectFrame()

	love.graphics.translate(w - 16, 0)

	local list = OsudirectListView
	local count = #list.items - 1
	local pos = (list.visualItemIndex - 1) / count
	local newScroll = imgui.ScrollBar("osudirect_sb", pos, 16, h, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end

local function OsudirectDifficultiesList(self)
	local w, h = Layout:move("column2row2")
	drawFrameRect(w, h)

	local w, h = Layout:move("column2row2row1")
	drawFrameRect2(w, h)

	local w, h = Layout:move("column2row2row2")

	OsudirectDifficultiesListView.game = self.game
	OsudirectDifficultiesListView:draw(w, h)
end

local function OsudirectProcessingList(self)
	local w, h = Layout:move("column1")
	drawFrameRect(w, h)

	OsudirectProcessingListView.game = self.game
	OsudirectProcessingListView:draw(w, h)
end

local function OsudirectSearchField(self)
	if not just.focused_id then
		just.focus("OsudirectSearchField")
	end
	local padding = 15
	love.graphics.setFont(spherefonts.get("Noto Sans", 20))

	local w, h = Layout:move("column3", "header")
	love.graphics.translate(0, padding)

	local delAll = love.keyboard.isDown("lctrl") and love.keyboard.isDown("backspace")

	local text = self.game.osudirectModel.searchString
	local changed, text = imgui.TextInput("OsudirectSearchField", {text, "Search..."}, nil, w, h - padding * 2)
	if changed == "text" then
		if delAll then text = "" end
		self.game.osudirectModel:setSearchString(text)
	end
end

local function OsudirectSubscreen(self)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local w, h = Layout:move("column3", "footer")

	just.row(true)
	if imgui.TextOnlyButton("notecharts", "notecharts", w / 2, h) then
		self:switchToNoteCharts()
	end
	if imgui.TextOnlyButton("collections", "collections", w / 2, h) then
		self:switchToCollections()
	end
	just.row()

	w, h = Layout:move("column2row2row1")

	just.indent(36)
	if imgui.TextOnlyButton("download", "download", w - 72, h) then
		self.game.osudirectModel:downloadBeatmapSet(self.game.osudirectModel.beatmap)
	end
end

return function(self)
	OsudirectList(self)
	OsudirectSearchField(self)
	OsudirectDifficultiesList(self)
	OsudirectProcessingList(self)
	OsudirectSubscreen(self)
end
