local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local Rectangle = require("aqua.graphics.Rectangle")
local Stencil = require("aqua.graphics.Stencil")
local utf8 = require("aqua.utf8")
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local Button = require("aqua.ui.Button")
local sign = require("aqua.math").sign
local belong = require("aqua.math").belong

local spherefonts = require("sphere.assets.fonts")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local ScreenManager = require("sphere.screen.ScreenManager")

local NoteChartSetList = {}

NoteChartSetList.visualItemIndex = 1
NoteChartSetList.selectedItemIndex = 1

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 1 - NoteChartSetList.x
NoteChartSetList.h = 1
NoteChartSetList.rectangleColor = {255, 255, 255, 0}
NoteChartSetList.textColor = {255, 255, 255, 255}
NoteChartSetList.selectedRectangleColor = {255, 255, 255, 0}
NoteChartSetList.mode = "fill"
NoteChartSetList.limit = math.huge
NoteChartSetList.textAlign = {
	x = "left", y = "center"
}
NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.basePath = "userdata/charts"

NoteChartSetList.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

NoteChartSetList.observable = Observable:new()
NoteChartSetList.font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

NoteChartSetList.load = function(self)
	self.db = Cache.db
	
	self.selectStatement = self.db:prepare(self.selectRequest)
	
	self.cs:reload()
	self.scrollCurrentDelta = 0
	self:selectCache()
	self:loadOverlay()
	self:updateItems()
	self.visualItemIndex = self.selectedItemIndex
	self:calculateButtons()
end

NoteChartSetList.postLoad = function(self)
	self.currentKey = self.currentKey or self.items[1].cacheData.path
	self:updateCurrentCacheData()
end

NoteChartSetList.draw = function(self)
	-- self.selectionFrame:draw()
	self.stencil:draw()
	self.stencil:set("greater", 0)
	for button in pairs(self.buttons) do
		button:draw()
	end
	self.stencil:set()
end

NoteChartSetList.setBasePath = function(self, path)
	self.basePath = path
	self:selectCache()
	self:updateCurrentCacheData()
	self:updateItems()
	self:unloadButtons()
	self:calculateButtons()
end

local colnames = {
	"path", "hash", "container", "title", "artist", "source", "tags", "name", "level", "creator", "audioPath", "stagePath", "previewTime", "noteCount", "length", "bpm", "inputMode"
}
NoteChartSetList.selectRequest = "SELECT * FROM `cache` WHERE `container` == 1 and INSTR(`path`, ?) == 1 ORDER BY `path`;"
NoteChartSetList.selectCache = function(self)
	self.keyList = {}
	self.cacheDatas = {}
	
	local stmt = self.selectStatement:reset():bind(self.basePath)
	local row = stmt:step()
	while row do
		local cacheData = {}
		for i = 1, #colnames do
			cacheData[colnames[i]] = row[i]
		end
		self.cacheDatas[row[1]] = cacheData
		table.insert(self.keyList, row[1])
		row = stmt:step()
	end
	table.sort(self.keyList)
	
	for keyIndex, key in ipairs(self.keyList) do
		if self.currentKey == key then
			self.selectedItemIndex = keyIndex
			self.visualItemIndex = keyIndex
			break
		end
	end
end

NoteChartSetList.updateCache = function(self)
	local recursive = love.keyboard.isDown("lshift")
	local path = self.currentKey
	Cache:update(path, recursive, function()
		self:selectCache()
		self:updateItems()
		self:unloadButtons()
		self:calculateButtons()
		NotificationLine:notify("Cache updated. (" .. path .. ")")
	end)
end

NoteChartSetList.updateCurrentCacheData = function(self)
	local path = self.currentKey
	if self.cacheDatas[path] then
		self.currentCacheData = self.cacheDatas[path]
		
		local directoryPath
		if self.currentCacheData.container == 0 then
			local directoryPathTable = path:split("/")
			directoryPathTable[#directoryPathTable] = nil
			directoryPath = table.concat(directoryPathTable, "/")
		else
			directoryPath = path
		end
		
		local stagePath
		if self.currentCacheData.stagePath and self.currentCacheData.stagePath ~= "" then
			stagePath = self.currentCacheData.stagePath
		else
			stagePath = "background.jpg"
		end
		
		self.backgroundPath = directoryPath .. "/" .. stagePath
		
		self:send({
			action = "select",
			cacheData = self.currentCacheData
		})
		self:send({
			backgroundPath = self.backgroundPath
		})
	end
end

local validate = utf8.validate
NoteChartSetList.updateItems = function(self)
	self.items = {}
	
	for _, key in ipairs(self.keyList) do
		self:addItem(key)
	end
	
	if self.selectedItemIndex > #self.items then
		self.selectedItemIndex = #self.items
		self.visualItemIndex = #self.items
	end
end

NoteChartSetList.getItemName = function(self, cacheData)
	if cacheData.name and cacheData.name ~= "" then
		return cacheData.name
	elseif cacheData.title and cacheData.title ~= "" then
		return cacheData.title
	elseif cacheData.container == 0 then
		return "."
	else
		return cacheData.path
	end
end

NoteChartSetList.addItem = function(self, key)
	local item = {}
	item.index = #self.items + 1
	item.key = key
	item.cacheData = self.cacheDatas[key]
	item.text = self:getItemName(item.cacheData)
	item.onClick = function()
		if item.index == self.selectedItemIndex then
			self.currentKey = key
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
		self.currentKey = key
		self:updateCurrentCacheData()
	end
	
	self.items[#self.items + 1] = item
end

NoteChartSetList.unload = function(self)
	self:unloadButtons()
	self:unloadOverlay()
end

NoteChartSetList.update = function(self)
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

NoteChartSetList.send = function(self, event)
	return self.observable:send(event)
end

NoteChartSetList.receive = function(self, event)
	if self.buttons then
		for button in pairs(self.buttons) do
			button:receive(event)
		end
	end
	
	if
		event.action == "select" and
		event.cacheData and
		event.cacheData.container == self.managerContainer
	then
		self:setBasePath(event.cacheData.path)
	end
	
	if event.name == "resize" then
		self.cs:reload()
		self.selectionFrame:reload()
		self.buttonsFrame:reload()
	elseif event.name == "wheelmoved" then
		local mx = self.cs:x(love.mouse.getX(), true)
		local my = self.cs:y(love.mouse.getY(), true)
		if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
			self:scrollBy(-event.args[2])
		end
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
		elseif key == "f5" then
			local mx = self.cs:x(love.mouse.getX(), true)
			local my = self.cs:y(love.mouse.getY(), true)
			if belong(mx, self.x, self.x + self.w) and belong(my, self.y, self.y + self.h) then
				self:updateCache()
			end
		end
	end
end

NoteChartSetList.getStartItemIndex = function(self)
	return math.floor(self.visualItemIndex) - self.startOffset
end

NoteChartSetList.getEndItemIndex = function(self)
	return math.ceil(self.visualItemIndex) + self.endOffset
end

NoteChartSetList.loadOverlay = function(self)
	self.selectionFrame = Rectangle:new({
		x = self.x, y = self.y + (self.middleOffset - 1) * (self.h / self.buttonCount),
		w = -0.01, h = self.h / self.buttonCount,
		cs = self.cs,
		color = {255, 255, 255, 127},
		mode = "fill"
	})
	self.selectionFrame:reload()
	
	self.buttonsFrame = Rectangle:new({
		x = self.x, y = self.y,
		w = self.w, h = self.h,
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

NoteChartSetList.scrollToItemIndex = function(self, itemIndex)
	if self.items[itemIndex] then
		self.selectedItemIndex = itemIndex
		self:send({
			action = "scroll",
			cacheData = self.items[itemIndex].cacheData
		})
	end
	
	self.scrollCurrentDelta = (self.selectedItemIndex - self.visualItemIndex)
end

NoteChartSetList.scrollBy = function(self, scrollDelta)
	self:scrollToItemIndex(self.selectedItemIndex + scrollDelta)
end

NoteChartSetList.calculateButtons = function(self)
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

NoteChartSetList.addButton = function(self, item)
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

NoteChartSetList.unloadButtons = function(self)
	self.buttons = nil
end

NoteChartSetList.Button = Button:new()

NoteChartSetList.Button.update = function(self)
	self.x = self.list.x
	self.y = self.list.y + (self.list.middleOffset - 1 + self.item.index - self.list.visualItemIndex) * (self.list.h / self.list.buttonCount)
	
	
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

return NoteChartSetList
