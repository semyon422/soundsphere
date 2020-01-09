local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local CustomList		= require("sphere.ui.CustomList")
local NoteSkinManager	= require("sphere.noteskin.NoteSkinManager")
local NoteChartList  	= require("sphere.screen.select.NoteChartList")
local Cache				= require("sphere.database.Cache")

local NoteChartMenuList = CustomList:new()

NoteChartMenuList.x = 0
NoteChartMenuList.y = 0
NoteChartMenuList.w = 1
NoteChartMenuList.h = 1

NoteChartMenuList.textAlign = {x = "center", y = "center"}

NoteChartMenuList.sender = "NoteChartMenuList"
NoteChartMenuList.needFocusToInteract = false

NoteChartMenuList.buttonCount = 17
NoteChartMenuList.middleOffset = 9
NoteChartMenuList.startOffset = 9
NoteChartMenuList.endOffset = 9

NoteChartMenuList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")
end

NoteChartMenuList.load = function(self)
	self:addItems()
	self:reload()
end

NoteChartMenuList.send = function(self, event)
	if event.action == "buttonInteract" and event.button == 1 then
		local metaData = self.items[event.itemIndex].metaData
		NoteSkinManager:setDefaultNoteSkin(self:getSelectedInputMode(), metaData)
	end
	
	CustomList.send(self, event)
end

NoteChartMenuList.getSelectedInputMode = function(self)
	if
		not NoteChartList.items or
		not NoteChartList.focusedItemIndex or
		not NoteChartList.items[NoteChartList.focusedItemIndex] or
		not NoteChartList.items[NoteChartList.focusedItemIndex].cacheData or
		not NoteChartList.items[NoteChartList.focusedItemIndex].cacheData.inputMode
	then
		return ""
	end
	
	return NoteChartList.items[NoteChartList.focusedItemIndex].cacheData.inputMode
end

NoteChartMenuList.addItems = function(self)
	local NoteChartMenu	= require("sphere.screen.select.NoteChartMenu")
	local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")

	local cacheData = NoteChartSetList.items[NoteChartSetList.focusedItemIndex].cacheData

	local items = {
		{
			name = "open folder",
			onClick = function()
				love.system.openURL("file://" .. love.filesystem.getSource() .. "/" .. cacheData.path)
				NoteChartMenu:hide()
			end
		},
		{
			name = "recache",
			onClick = function()
				Cache:update(cacheData.path)
				NoteChartMenu:hide()
			end
		}
	}
	
	return self:setItems(items)
end

return NoteChartMenuList
