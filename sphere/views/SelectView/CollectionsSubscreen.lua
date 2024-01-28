local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")
local CollectionListView = require("sphere.views.SelectView.CollectionListView")
local CacheView = require("sphere.views.SelectView.CacheView")

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

---@param self table
local function Cache(self)
	local w, h = Layout:move("column2row2row1")
	drawFrameRect(w, h)

	love.graphics.translate(h / 2, 0)

	CacheView.game = self.game
	CacheView:draw(w - h, h)
end

---@param self table
local function CollectionList(self)
	local w, h = Layout:move("column3")
	drawFrameRect(w, h)

	SelectFrame()
	CollectionListView.game = self.game
	CollectionListView:draw(w, h)
	SelectFrame()
end

---@param self table
local function CollectionsSubscreen(self)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local w, h = Layout:move("column3", "footer")

	just.row(true)
	if imgui.TextOnlyButton("notecharts", "notecharts", w / 2, h) then
		self:switchToNoteCharts()
	end
	if imgui.TextOnlyButton("direct", "direct", w / 2, h) then
		self:switchToOsudirect()
	end
	just.row()
end

return function(self)
	CollectionList(self)
	Cache(self)
	CollectionsSubscreen(self)
end
