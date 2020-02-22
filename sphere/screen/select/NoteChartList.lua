local CoordinateManager		= require("aqua.graphics.CoordinateManager")
local Observable			= require("aqua.util.Observable")
local Cache					= require("sphere.database.Cache")
local SearchManager			= require("sphere.database.SearchManager")
local CacheList				= require("sphere.screen.select.CacheList")
local NoteChartListButton	= require("sphere.screen.select.NoteChartListButton")
local PreviewManager		= require("sphere.screen.select.PreviewManager")
local BackgroundManager		= require("sphere.ui.BackgroundManager")

local NoteChartList = CacheList:new()

NoteChartList.x = 0
NoteChartList.y = 4/17
NoteChartList.w = 0.6
NoteChartList.h = 9/17

NoteChartList.sender = NoteChartList
NoteChartList.searchString = ""

NoteChartList.buttonCount = 9
NoteChartList.middleOffset = 5
NoteChartList.startOffset = 5
NoteChartList.endOffset = 5

NoteChartList.basePath = "?"
NoteChartList.setId = 0
NoteChartList.needItemsSort = true

NoteChartList.Button = NoteChartListButton

NoteChartList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

NoteChartList.send = function(self, event)
	return CacheList.send(self, event)
end

NoteChartList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = true
		end
	elseif event.name == "keyreleased" then
		local key = event.args[1]
		if key == "lctrl" or key == "rctrl" then
			self.keyControl = false
		end
	end
	
	return CacheList.receive(self, event)
end

NoteChartList.sortItemsFunction = function(a, b)
	a, b = a.noteChartDataEntry, b.noteChartDataEntry
	if
		#a.inputMode < #b.inputMode or
		#a.inputMode == #b.inputMode and a.inputMode < b.inputMode or
		a.inputMode == b.inputMode and a.noteCount / a.length < b.noteCount / b.length
	then
		return true
	end
end

NoteChartList.selectCache = function(self)
	local items = {}
	
	local noteChartEntries = Cache:getNoteChartsAtSet(self.setId)
	if not noteChartEntries or not noteChartEntries[1] then
		return self:setItems(items)
	end

	local map = {}
	local noteChartDataEntries = {}
	for i = 1, #noteChartEntries do
		local entries = Cache:getAllNoteChartDataEntries(noteChartEntries[i].hash)
		if not entries then
			entries = {Cache:getEmptyNoteChartDataEntry(noteChartEntries[i].path)}
		end
		for _, entry in pairs(entries) do
			noteChartDataEntries[#noteChartDataEntries + 1] = entry
			map[entry] = noteChartEntries[i]
		end
	end

	local foundList = SearchManager:search(noteChartDataEntries, self.searchString)
	for i = 1, #foundList do
		local noteChartDataEntry = foundList[i]
		items[#items + 1] = {
			noteChartDataEntry = noteChartDataEntry,
			noteChartEntry = map[noteChartDataEntry],
			name = noteChartDataEntry.name
		}
	end
	
	if self.needItemsSort then
		table.sort(items, self.sortItemsFunction)
	end
	
	return self:setItems(items)
end

NoteChartList.getBackgroundPath = function(self, itemIndex)
	local item = self.items[itemIndex]
	local noteChartDataEntry = item.noteChartDataEntry
	local noteChartEntry = item.noteChartEntry
	
	local directoryPath = Cache:getNoteChartSetEntryById(noteChartEntry.setId).path
	local stagePath = noteChartDataEntry.stagePath

	if stagePath and stagePath ~= "" then
		return directoryPath .. "/" .. stagePath
	end
	
	return directoryPath
end

NoteChartList.getAudioPath = function(self, itemIndex)
	local item = self.items[itemIndex]
	local noteChartDataEntry = item.noteChartDataEntry
	local noteChartEntry = item.noteChartEntry
	
	local directoryPath = Cache:getNoteChartSetEntryById(noteChartEntry.setId).path
	local audioPath = noteChartDataEntry.audioPath

	if audioPath and audioPath ~= "" then
		return directoryPath .. "/" .. audioPath, noteChartDataEntry.previewTime
	end

	return directoryPath .. "/preview.ogg", 0
end

NoteChartList.updateBackground = function(self)
	if not self.items[self.focusedItemIndex] then return end
	return BackgroundManager:loadDrawableBackground(self:getBackgroundPath(self.focusedItemIndex))
end

NoteChartList.updateAudio = function(self)
	if not self.items[self.focusedItemIndex] then return end
	return PreviewManager:playAudio(self:getAudioPath(self.focusedItemIndex))
end

NoteChartList.getItemIndex = function(self, entry)
	if not entry then
		return 1
	end
	
	local items = self.items
	for i = 1, #items do
		if items[i].noteChartEntry == entry then
			return i
		end
	end
	
	return 1
end

return NoteChartList
