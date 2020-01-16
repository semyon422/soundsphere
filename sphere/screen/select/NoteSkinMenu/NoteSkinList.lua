local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local CustomList		= require("sphere.ui.CustomList")
local NoteSkinManager	= require("sphere.noteskin.NoteSkinManager")
local NoteChartList  	= require("sphere.screen.select.NoteChartList")

local NoteSkinList = CustomList:new()

NoteSkinList.x = 0
NoteSkinList.y = 0
NoteSkinList.w = 1
NoteSkinList.h = 1

NoteSkinList.textAlign = {x = "center", y = "center"}

NoteSkinList.sender = "NoteSkinList"
NoteSkinList.needFocusToInteract = false

NoteSkinList.buttonCount = 17
NoteSkinList.middleOffset = 9
NoteSkinList.startOffset = 9
NoteSkinList.endOffset = 9

NoteSkinList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")
end

NoteSkinList.load = function(self)
	self:addItems()
	self:reload()
end

NoteSkinList.send = function(self, event)
	if event.action == "buttonInteract" and event.button == 1 then
		local metaData = self.items[event.itemIndex].metaData
		NoteSkinManager:setDefaultNoteSkin(self:getSelectedInputMode(), metaData)
	end
	
	CustomList.send(self, event)
end

NoteSkinList.getSelectedInputMode = function(self)
	if
		not NoteChartList.items or
		not NoteChartList.focusedItemIndex or
		not NoteChartList.items[NoteChartList.focusedItemIndex] or
		not NoteChartList.items[NoteChartList.focusedItemIndex].noteChartDataEntry or
		not NoteChartList.items[NoteChartList.focusedItemIndex].noteChartDataEntry.inputMode
	then
		return ""
	end
	
	return NoteChartList.items[NoteChartList.focusedItemIndex].noteChartDataEntry.inputMode
end

NoteSkinList.addItems = function(self)
	local items = {}
	
	local list = NoteSkinManager:getMetaDataList(self:getSelectedInputMode())
	local selectedMetaData = NoteSkinManager:getMetaData(self:getSelectedInputMode())

	for _, metaData in ipairs(list) do
		local name = metaData.name
		if name == selectedMetaData.name then
			name = "★ " .. name
		end
		items[#items + 1] = {
			metaData = metaData,
			name = name
		}
	end
	
	return self:setItems(items)
end

return NoteSkinList
