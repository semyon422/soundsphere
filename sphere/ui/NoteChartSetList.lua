local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Observable		= require("aqua.util.Observable")
local CacheManager				= require("sphere.database.CacheManager")
local SearchManager		= require("sphere.database.SearchManager")
local CacheList			= require("sphere.ui.CacheList")
local PreviewManager	= require("sphere.ui.PreviewManager")

local NoteChartSetList = CacheList:new()

NoteChartSetList.x = 0.6
NoteChartSetList.y = 0
NoteChartSetList.w = 0.4
NoteChartSetList.h = 1

NoteChartSetList.sender = NoteChartSetList
NoteChartSetList.searchString = ""

NoteChartSetList.buttonCount = 17
NoteChartSetList.middleOffset = 9
NoteChartSetList.startOffset = 9
NoteChartSetList.endOffset = 9

NoteChartSetList.basePath = "userdata/charts"
NoteChartSetList.keyControl = true
NoteChartSetList.needItemsSort = true
NoteChartSetList.needSearch = false

NoteChartSetList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

NoteChartSetList.send = function(self, event)
	return CacheList.send(self, event)
end

NoteChartSetList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = false
		end
	elseif event.name == "keyreleased" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = true
		end
	end

	return CacheList.receive(self, event)
end

NoteChartSetList.checkNoteChartSetEntry = function(self, entry)
	local base = entry.path:find(self.basePath, 1, true)
	if not base then return false end
	if not self.needSearch then return true end

	local list = CacheManager:getNoteChartsAtSet(entry.id)
	if not list or not list[1] then
		return
	end

	for i = 1, #list do
		local entries = CacheManager:getAllNoteChartDataEntries(list[i].hash)
		for _, entry in pairs(entries) do
			local found = SearchManager:check(entry, self.searchString)
			if found == true then
				return true
			end
		end
	end
end

NoteChartSetList.sortItemsFunction = function(a, b)
	return a.noteChartSetEntry.path < b.noteChartSetEntry.path
end

NoteChartSetList.getItemName = function(self, entry)
	local list = CacheManager:getNoteChartsAtSet(entry.id)
	if list and list[1] then
		local noteChartDataEntry = CacheManager:getNoteChartDataEntry(list[1].hash, 1)
		if noteChartDataEntry then
			return noteChartDataEntry.title
		end
	end
	return entry.path:match(".+/(.-)$")
end

NoteChartSetList.selectCache = function(self)
	local items = {}

	local noteChartSetEntries = CacheManager:getNoteChartSets()
	for i = 1, #noteChartSetEntries do
		local noteChartSetEntry = noteChartSetEntries[i]
		if self:checkNoteChartSetEntry(noteChartSetEntry) then
			items[#items + 1] = {
				noteChartSetEntry = noteChartSetEntry,
				name = self:getItemName(noteChartSetEntry)
			}
		end
	end

	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end

	return self:setItems(items)
end

NoteChartSetList.getItemIndex = function(self, entry)
	if not entry then
		return 1
	end

	local items = self.items
	for i = 1, #items do
		if items[i].noteChartSetEntry == entry then
			return i
		end
	end

	return 1
end

NoteChartSetList:init()

return NoteChartSetList
