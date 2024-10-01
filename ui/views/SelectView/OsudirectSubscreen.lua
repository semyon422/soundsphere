local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local OsudirectListView = require("ui.views.SelectView.OsudirectListView")
local OsudirectDifficultiesListView = require("ui.views.SelectView.OsudirectDifficultiesListView")
local OsudirectProcessingListView = require("ui.views.SelectView.OsudirectProcessingListView")
local RoundedRectangle = require("ui.views.RoundedRectangle")
local imgui = require("imgui")

local Layout = require("ui.views.SelectView.Layout")
local SelectFrame = require("ui.views.SelectView.SelectFrame")

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

---@param self table
local function OsudirectDifficultiesList(self)
	local w, h = Layout:move("column2row2")
	drawFrameRect(w, h)

	local w, h = Layout:move("column2row2row1")
	drawFrameRect2(w, h)

	local w, h = Layout:move("column2row2row2")

	OsudirectDifficultiesListView.game = self.game
	OsudirectDifficultiesListView:draw(w, h)
end

---@param self table
local function OsudirectProcessingList(self)
	local w, h = Layout:move("column1")
	drawFrameRect(w, h)

	OsudirectProcessingListView.game = self.game
	OsudirectProcessingListView:draw(w, h)
end

---@param self table
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

---@param self table
local function OsudirectRankedStatus(self)
	love.graphics.setFont(spherefonts.get("Noto Sans", 20))

	local w, h = Layout:move("column2", "header")
	love.graphics.translate(w * 2 / 3, 15)

	local osudirectModel = self.game.osudirectModel
	local statusIndex = imgui.SpoilerList("RankedStatusDropdown", w / 3, h - 30, osudirectModel.rankedStatuses, osudirectModel.rankedStatus)
	if statusIndex then
		osudirectModel:setRankedStatus(osudirectModel.rankedStatuses[statusIndex])
	end
end

---@param self table
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

	w, h = Layout:move("column1", "footer")
	if imgui.TextOnlyButton("recache downloads", "recache downloads", w, h) then
		self.game.cacheModel:startUpdate("downloads", 1)
	end

	w, h = Layout:move("column2row2row1")

	local osudirectModel = self.game.osudirectModel
	local set = osudirectModel.beatmap
	if not set then
		return
	end

	local button_id = "download"
	local button_text = set.downloaded and "redownload" or "download"
	if osudirectModel:isLimited() then
		button_id = nil
		button_text = "rate limit, wait a minute"
	end

	just.indent(36)
	if imgui.TextOnlyButton(button_id, button_text, w - 72, h) then
		self.game.osudirectModel:download(set)
	end
end

return function(self)
	OsudirectList(self)
	OsudirectSearchField(self)
	OsudirectRankedStatus(self)
	OsudirectDifficultiesList(self)
	OsudirectProcessingList(self)
	OsudirectSubscreen(self)
end
