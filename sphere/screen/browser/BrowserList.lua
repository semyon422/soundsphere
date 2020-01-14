local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Observable		= require("aqua.util.Observable")
local Cache				= require("sphere.database.Cache")
local CollectionManager	= require("sphere.database.CollectionManager")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local CustomList		= require("sphere.ui.CustomList")
local NotificationLine	= require("sphere.ui.NotificationLine")

local BrowserList = CustomList:new()

BrowserList.x = 1/17
BrowserList.y = 0
BrowserList.w = 10
BrowserList.h = 1

BrowserList.sender = "BrowserList"
BrowserList.needFocusToInteract = false

BrowserList.buttonCount = 17
BrowserList.middleOffset = 9
BrowserList.startOffset = 9
BrowserList.endOffset = 9
BrowserList.needItemsSort = true

BrowserList.mode = "filesystem"
BrowserList.basePath = "userdata/charts"

BrowserList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "h")
end

BrowserList.load = function(self)
	self:selectCache()
	self:reload()
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
		elseif key == "f2" then
			self.mode = "cache"
			self:selectCache()
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
			
			if not love.filesystem.isFile(path) then
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
