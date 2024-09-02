local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")
local CollectionListView = require("ui.views.SelectView.CollectionListView")

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

---@param self table
local function CollectionList(self)
	local w, h = Layout:move("column3")
	drawFrameRect(w, h)

	SelectFrame()
	CollectionListView.game = self.game
	CollectionListView:draw(w, h)
	SelectFrame()

	love.graphics.translate(w - 16, 0)

	local list = CollectionListView
	local count = #list.items - 1
	local pos = (list.visualItemIndex - 1) / count
	local newScroll = imgui.ScrollBar("ncs_sb", pos, 16, h, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
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

	w, h = Layout:move("column3", "header")

	local padding = 15
	love.graphics.translate(0, padding)

	local config = self.game.configModel.configs.settings.select
	if imgui.Checkbox("locs_in_colls cb", config.locations_in_collections, h - padding * 2) then
		config.locations_in_collections = not config.locations_in_collections
		self.game.selectModel.collectionLibrary:load(config.locations_in_collections)
	end
	just.sameline()
	imgui.Label("locs_in_colls cb", "show locations", h - padding * 2)
end

return function(self)
	CollectionList(self)
	CollectionsSubscreen(self)
end
