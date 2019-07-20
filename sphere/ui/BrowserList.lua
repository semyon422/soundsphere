local CS = require("aqua.graphics.CS")
local Observable = require("aqua.util.Observable")
local CustomList = require("sphere.ui.CustomList")
local NoteChartSetList = require("sphere.ui.NoteChartSetList")
local Cache = require("sphere.game.NoteChartManager.Cache")
local CollectionManager = require("sphere.game.NoteChartManager.CollectionManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local BrowserList = CustomList:new()

BrowserList.sender = "BrowserList"
BrowserList.needFocusToInteract = false

BrowserList.buttonCount = 17
BrowserList.middleOffset = 9
BrowserList.startOffset = 9
BrowserList.endOffset = 9
BrowserList.needItemsSort = true

BrowserList.mode = "filesystem"

BrowserList.observable = Observable:new()

BrowserList.basePath = "userdata/charts"

BrowserList.load = function(self)
	self:selectCache()
	
	return CustomList.load(self)
end

BrowserList.send = function(self, event)
	if event.action == "buttonInteract" then
		local item = self.items[event.itemIndex]
		if event.button == 1 then
			NoteChartSetList:setBasePath(item.path)
		elseif event.button == 2 then
			local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
			local recursive = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
			if shift then
				Cache:update(item.path, recursive)
			else
				love.system.openURL("file://" .. love.filesystem.getSource() .. "/" .. item.path)
			end
		end
	end
	
	return CustomList.send(self, event)
end

BrowserList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f5" then
			Cache:select()
			NotificationLine:notify("Cache reloaded from database")
		elseif key == "f1" then
			self.mode = "filesystem"
			self:selectCache()
			self:unloadButtons()
			self:calculateButtons()
		elseif key == "f2" then
			self.mode = "cache"
			self:selectCache()
			self:unloadButtons()
			self:calculateButtons()
		end
	end
	
	return CustomList.receive(self, event)
end

BrowserList.selectCache = function(self)
	local items = {}
	if self.mode == "filesystem" then
		local directoryItems = love.filesystem.getDirectoryItems("userdata/charts")
		
		items[1] = {
			name = "all",
			path = "userdata/charts"
		}
		for _, name in ipairs(directoryItems) do
			local path = "userdata/charts/" .. name
			if love.filesystem.isDirectory(path) then
				items[#items + 1] = {
					name = name,
					path = path
				}
			end
		end
	elseif self.mode == "cache" then
		local paths = CollectionManager:getPaths()
		
		for _, path in ipairs(paths) do
			items[#items + 1] = {
				name = path,
				path = path
			}
		end
	end
	
	return self:setItems(items)
end

return BrowserList
