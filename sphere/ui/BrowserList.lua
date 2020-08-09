local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local NoteChartSetList	= require("sphere.ui.NoteChartSetList")
local CustomList		= require("sphere.ui.CustomList")
local NotificationModel	= require("sphere.models.NotificationModel")

local BrowserList = CustomList:new()

BrowserList.x = 0.6
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

BrowserList.basePath = "userdata/charts"

BrowserList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

BrowserList.load = function(self)
	self:selectCache()
	self:reload()
end

BrowserList.send = function(self, event)
	if event.action == "scrollTarget" then
		local item = self.items[event.itemIndex]
		if not item then return end

		self.basePath = item.path
		NoteChartSetList:setBasePath(item.path)
	end
	
	return CustomList.send(self, event)
end

BrowserList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f5" then
			self.cacheModel.cacheManager:select()
			NotificationModel:notify("Cache reloaded from database")
		end
	end
	
	return CustomList.receive(self, event)
end

BrowserList.selectCache = function(self)
	local items = {}
	
	items[1] = {
		name = "all",
		path = "userdata/charts"
	}
	for _, path in ipairs(self.collectionModel:getPaths()) do
		if not love.filesystem.isFile(path) then
			items[#items + 1] = {
				name = path:match("^.-/.-/(.+)$"),
				path = path
			}
		end
	end
	
	return self:setItems(items)
end

return BrowserList
