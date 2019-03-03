local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local Rectangle = require("aqua.graphics.Rectangle")
local Stencil = require("aqua.graphics.Stencil")
local utf8 = require("aqua.utf8")
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local Button = require("aqua.ui.Button")
local leftequal = require("aqua.table").leftequal
local sign = require("aqua.math").sign

local spherefonts = require("sphere.assets.fonts")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local ScreenManager = require("sphere.screen.ScreenManager")

local MapList = {}

MapList.visualItemIndex = 1
MapList.selectedItemIndex = 1

MapList.x = 0
MapList.y = 0
MapList.w = 1
MapList.h = 1
MapList.layer = 2
MapList.rectangleColor = {255, 255, 255, 0}
MapList.textColor = {255, 255, 255, 255}
MapList.selectedRectangleColor = {255, 255, 255, 0}
MapList.mode = "fill"
MapList.limit = 2
MapList.textAlign = {
	x = "left", y = "center"
}
MapList.buttonCount = 17

MapList.currentCacheData = {path = "userdata/charts"}
MapList.selectionKey = MapList.currentCacheData.path:split("/")

MapList.cs = CS:new({
	bx = 0.5,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

MapList.load = function(self)
	self.observable = Observable:new()
	
	self.db = Cache.db
	self.db:setscalar("CHECKCACHE", function(...) return self:checkCache(...) end)
	
	self.cs:reload()
	
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 28)
	
	self.scrollCurrentDelta = 0

	self:selectCache()
	
	self:loadOverlay()
	self:updateItems()
	self.visualItemIndex = self.selectedItemIndex
	
	self:calculateButtons()
end

MapList.draw = function(self)
	-- self.selectionFrame:draw()
	self.stencil:draw()
	self.stencil:set("greater", 0)
	for button in pairs(self.buttons) do
		button:draw()
	end
	self.stencil:set()
end

MapList.checkCache = function(self, path)
	local subkey = path:split("/")
	table.remove(subkey, #subkey)
	if leftequal(subkey, self.selectionKey) then
		return 1
	else
		return 0
	end
end

MapList.selectRequest = "SELECT * FROM `cache` WHERE %s ORDER BY `path`;"
MapList.selectCache = function(self)
	self.selectionList = {}
	self.cacheDatas = {}
	local result = self.db:exec(self.selectRequest:format("CHECKCACHE(path)"))
	if not result then return end
	
	local row = 1
	while result.path[row] do
		self.cacheDatas[result.path[row]] = {
			path = result.path[row],
			hash = result.hash[row],
			container = result.container[row],
			title = result.title[row],
			artist = result.artist[row],
			source = result.source[row],
			tags = result.tags[row],
			name = result.name[row],
			creator = result.creator[row],
			audioPath = result.audioPath[row],
			stagePath = result.stagePath[row],
			previewTime = result.previewTime[row],
			noteCount = result.noteCount[row],
			length = result.length[row],
			bpm = result.bpm[row],
			inputMode = result.inputMode[row]
		}
		table.insert(self.selectionList, result.path[row])
		row = row + 1
	end
	table.sort(self.selectionList)
	for i, path in ipairs(self.selectionList) do
		self.selectionList[i] = path:split("/")
	end
	
	for selectionKeyIndex, selectionKey in ipairs(self.selectionList) do
		if leftequal(self.selectionKey, selectionKey) then
			self.selectedItemIndex = selectionKeyIndex
			self.visualItemIndex = selectionKeyIndex
			break
		end
	end
	
	BackgroundManager:loadDrawableBackground(table.concat(self.selectionKey, "/") .. "/background.jpg")
end

MapList.updateCache = function(self)
	local recursive = love.keyboard.isDown("lshift")
	local path = table.concat(self.selectionKey, "/")
	Cache:update(path, recursive, function()
		self:selectCache()
		self:updateItems()
		self:unloadButtons()
		self:calculateButtons()
		NotificationLine:notify("Cache updated. (" .. path .. ")")
	end)
end

MapList.updateCurrentCacheData = function(self)
	if self.cacheDatas[table.concat(self.selectionKey, "/")] then
		self.currentCacheData = self.cacheDatas[table.concat(self.selectionKey, "/")]
	end
end

local validate = utf8.validate
MapList.updateItems = function(self)
	self.items = {}
	
	for _, selectionKey in ipairs(self.selectionList) do
		self:addItem(selectionKey)
	end
	
	if self.selectedItemIndex > #self.items then
		self.selectedItemIndex = #self.items
		self.visualItemIndex = #self.items
	end
end

MapList.getItemName = function(self, cacheData)
	if cacheData.name and cacheData.name ~= "" then
		return cacheData.name
	elseif cacheData.container == 0 then
		return "."
	else
		return cacheData.path
	end
end

MapList.addItem = function(self, selectionKey)
	local item = {}
	item.index = #self.items + 1
	item.selectionKey = selectionKey
	item.cacheData = self.cacheDatas[table.concat(selectionKey, "/")]
	item.text = ("    "):rep(#selectionKey - 1) .. self:getItemName(item.cacheData)
	item.onClick = function()
		if item.index == self.selectedItemIndex then
			self.selectionKey = selectionKey
			self:selectCache()
			self:updateCurrentCacheData()
			self:updateItems()
			self:unloadButtons()
			self:calculateButtons()
			if item.cacheData and item.cacheData.container == 0 then
				ScreenManager:set(require("sphere.screen.GameplayScreen"))
			end
		else
			self:scrollToItemIndex(item.index)
		end
	end
	item.onSelect = function()
		self.selectionKey = selectionKey
		self:updateCurrentCacheData()
	end
	
	self.items[#self.items + 1] = item
end

MapList.unload = function(self)
	self:unloadButtons()
	self:unloadOverlay()
end

MapList.getMiddleOffset = function(self)
	return math.ceil(self.buttonCount / 2)
end

MapList.update = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	local sign = sign(self.scrollCurrentDelta)
	local scrollCurrentDelta = sign * math.max(math.abs(self.scrollCurrentDelta), 1) * 8 * dt
	
	if self.selectedItemIndex < 1 then
		self.selectedItemIndex = 1
	elseif self.selectedItemIndex > #self.items then
		self.selectedItemIndex = #self.items
	end
	
	if (scrollCurrentDelta > 0 and self.visualItemIndex + scrollCurrentDelta > self.selectedItemIndex)
	or (scrollCurrentDelta < 0 and self.visualItemIndex + scrollCurrentDelta < self.selectedItemIndex)
	then
		self.visualItemIndex = self.selectedItemIndex
		self.scrollCurrentDelta = 0
	else
		self.visualItemIndex = self.visualItemIndex + scrollCurrentDelta
	end
	
	self:calculateButtons()
end

MapList.send = function(self, event)
	return self.observable:send(event)
end

MapList.receive = function(self, event)
	for button in pairs(self.buttons) do
		button:receive(event)
	end
	
	if event.name == "resize" then
		self.cs:reload()
		self.selectionFrame:reload()
		self.buttonsFrame:reload()
	elseif event.name == "wheelmoved" then
		self:scrollBy(-event.args[2])
	elseif event.name == "keypressed" then
		local key = event.args[1]
		if key == "up" then
			self:scrollBy(-1)
		elseif key == "down" then
			self:scrollBy(1)
		elseif key == "return" then
			for button in pairs(self.buttons) do
				if button.item.index == self.selectedItemIndex then
					button.item.onClick()
					break
				end
			end
		elseif key == "escape" and #self.selectionKey > 2 then
			self.selectionKey[#self.selectionKey] = nil
			self:selectCache()
			self:updateItems()
			self:unloadButtons()
		elseif key == "f5" then
			self:updateCache()
		end
	end
end

MapList.getStartItemIndex = function(self)
	return math.floor(self.visualItemIndex) - self:getMiddleOffset()
end

MapList.getEndItemIndex = function(self)
	return math.ceil(self.visualItemIndex) + self:getMiddleOffset()
end

MapList.loadOverlay = function(self)
	self.selectionFrame = Rectangle:new({
		x = self.x, y = self.y + (self:getMiddleOffset() - 1) * (self.h / self.buttonCount),
		w = -0.01, h = self.h / self.buttonCount,
		cs = self.cs,
		color = {255, 255, 255, 127},
		mode = "fill"
	})
	self.selectionFrame:reload()
	
	self.buttonsFrame = Rectangle:new({
		x = self.x, y = 2 / self.buttonCount,
		w = self.w, h = (self.buttonCount - 4) / self.buttonCount,
		cs = self.cs,
		color = {255, 255, 255, 255},
		mode = "fill"
	})
	self.buttonsFrame:reload()
	
	local stencilfunction = function()
		self.buttonsFrame:draw()
	end
	self.stencil = Stencil:new({
		stencilfunction = stencilfunction,
		action = "replace",
		value = 1,
		keepvalues = false
	})
	self.stencil:reload()
end

MapList.scrollToItemIndex = function(self, itemIndex)
	if self.items[itemIndex] then
		self.selectedItemIndex = itemIndex
		self:send({
			cacheData = self.items[itemIndex].cacheData
		})
	end
	
	self.scrollCurrentDelta = (self.selectedItemIndex - self.visualItemIndex)
end

MapList.scrollBy = function(self, scrollDelta)
	self:scrollToItemIndex(self.selectedItemIndex + scrollDelta)
end

MapList.calculateButtons = function(self)
	self.buttons = self.buttons or {}
	
	local itemIndexKeys = {}
	for button in pairs(self.buttons) do
		button:update()
		itemIndexKeys[button.item.index] = button
	end
	
	for itemIndex = self:getStartItemIndex(), self:getEndItemIndex() do
		local item = self.items[itemIndex]
		if item and not itemIndexKeys[itemIndex] then
			self:addButton(item)
		end
	end
end

MapList.addButton = function(self, item)
	local button = self.Button:new({
		item = item,
		text = item.text,
		interact = item.onClick,
		
		x = self.x, y = self.y,
		w = self.w, h = self.h / self.buttonCount,
		cs = self.cs,
		rectangleColor = self.rectangleColor,
		mode = self.mode,
		limit = self.limit,
		textAlign = self.textAlign,
		textColor = self.textColor,
		font = self.font,
		list = self,
	})
	button:reload()
	button:update()
	
	self.buttons[button] = button
end

MapList.unloadButtons = function(self)
	self.buttons = nil
end

MapList.Button = Button:new()

MapList.Button.update = function(self)
	self.x = self.list.x
	self.y = self.list.y + (self.list:getMiddleOffset() - 1 + self.item.index - self.list.visualItemIndex) * (self.list.h / self.list.buttonCount)
	
	
	if self.item.index == self.list.selectedItemIndex then
		self.rectangleColor = self.list.selectedRectangleColor
		if not self.selected and self.item.onSelect then
			self.item.onSelect(self)
			self.selected = true
		end
	else
		self.selected = false
		self.rectangleColor = self.list.rectangleColor
	end
	
	if self.item.index < self.list:getStartItemIndex() or
		self.item.index > self.list:getEndItemIndex()
	then
		self.list.buttons[self] = nil
	else
		self:reload()
	end
end

return MapList
