local LibraryModel = require("sphere.models.LibraryModel")

---@class sphere.NoteChartLibraryModel: sphere.LibraryModel
---@operator call: sphere.NoteChartLibraryModel
local NoteChartLibraryModel = LibraryModel + {}

NoteChartLibraryModel.setId = 1

local NoteChartItem = {}

---@param path string
---@return string
local function evalPath(path)
	return (path:gsub("\\", "/"):gsub("/[^/]-/%.%./", "/"))
end

---@return string?
function NoteChartItem:getBackgroundPath()
	local path = self.path
	if not path or not self.stagePath then
		return
	end

	if path:find("%.ojn$") or path:find("%.mid$") then
		return path
	end

	local directoryPath = path:match("^(.+)/(.-)$") or ""
	local stagePath = self.stagePath

	if stagePath and stagePath ~= "" then
		return evalPath(directoryPath .. "/" .. stagePath)
	end

	return directoryPath
end

---@return string?
---@return number?
function NoteChartItem:getAudioPathPreview()
	if not self.path or not self.audioPath then
		return
	end

	local directoryPath = self.path:match("^(.+)/(.-)$") or ""
	local audioPath = self.audioPath

	if audioPath and audioPath ~= "" then
		return evalPath(directoryPath .. "/" .. audioPath), math.max(0, self.previewTime or 0)
	end

	return directoryPath .. "/preview.ogg", 0
end

---@param k any
---@return any?
function NoteChartItem:__index(k)
	local raw = rawget(NoteChartItem, k)
	if raw then
		return raw
	end
	local model = self.noteChartLibraryModel

	local slice = model.cacheModel.cacheDatabase.noteChartSlices[model.setId]
	if not slice then
		return
	end
	local entry = model.cacheModel.cacheDatabase.noteChartItems[slice.offset + self.itemIndex - 1]
	if k == "key" or k == "noteChartDataId" or k == "noteChartId" or k == "setId" or k == "lamp" then
		return entry[k]
	end
	local noteChart = model.cacheModel.cacheDatabase:getCachedEntry("noteCharts", entry.noteChartId)
	local noteChartData = model.cacheModel.cacheDatabase:getCachedEntry("noteChartDatas", entry.noteChartDataId)
	return noteChartData and noteChartData[k] or noteChart and noteChart[k]
end

---@param itemIndex number
---@return table
function NoteChartLibraryModel:loadObject(itemIndex)
	return setmetatable({
		noteChartLibraryModel = self,
		itemIndex = itemIndex,
	}, NoteChartItem)
end

function NoteChartLibraryModel:clear()
	self.slice = nil
	self.itemsCount = 0
end

---@param setId number
function NoteChartLibraryModel:setNoteChartSetId(setId)
	self.setId = setId
	local slice = self.cacheModel.cacheDatabase.noteChartSlices[setId]
	if not slice then
		self.itemsCount = 0
		return
	end
	self.itemsCount = slice.size
end

---@param noteChartId number?
---@return number
function NoteChartLibraryModel:getItemIndex(noteChartId)
	return (self.cacheModel.cacheDatabase.id_to_local_offset[noteChartId] or 0) + 1
end

return NoteChartLibraryModel
