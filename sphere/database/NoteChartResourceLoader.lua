local image			= require("aqua.image")
local sound			= require("aqua.sound")
local aquathread	= require("aqua.thread")
local aquatimer	= require("aqua.timer")
local JamLoader		= require("sphere.database.JamLoader")
local FileFinder	= require("sphere.filesystem.FileFinder")
local array_update = require("aqua.util.array_update")

local NoteChartResourceLoader = {}

NoteChartResourceLoader.sample_gain = 0
NoteChartResourceLoader.aliases = {}

local resources = {
	loaded = {},
	loading = {},
	not_loaded = {},
}
NoteChartResourceLoader.resources = resources.loaded

local NoteChartTypes = {
	bms = {"bms", "osu", "quaver", "ksm", "sm", "midi"},
	o2jam = {"o2jam"},
}
local NoteChartTypeMap = {}
for t, list in pairs(NoteChartTypes) do
	for i = 1, #list do
		NoteChartTypeMap[list[i]] = t
	end
end

NoteChartResourceLoader.load = function(self, chartPath, noteChart, callback)
	local noteChartType = NoteChartTypeMap[noteChart.type]

	if self.sample_gain ~= sound.sample_gain then
		self:unloadAudio()
		self.sample_gain = sound.sample_gain
	end

	self.callback = callback
	self.aliases = {}

	local loaded = {}
	for path in pairs(resources.loaded) do
		table.insert(loaded, path)
	end

	if noteChartType == "bms" then
		local newResources = {}
		for _, name, sequence in noteChart:getResourceIterator() do
			for _, path in ipairs(sequence) do
				local filePath = FileFinder:findFile(path)
				if filePath then
					table.insert(newResources, filePath)
					self.aliases[name] = filePath
					break
				end
			end
		end
		self:loadResources(loaded, newResources)
	elseif noteChartType == "o2jam" then
		self:loadOJM(loaded, chartPath:match("^(.+)n$") .. "m")
	end

	self:process()
end

NoteChartResourceLoader.loadResource = function(self, path)
	local fileType = FileFinder:getType(path)
	if fileType == "audio" then
		resources.loaded[path] = sound.newSoundDataAsync(path)
	elseif fileType == "image" then
		resources.loaded[path] = image.newImageDataAsync(path)
	elseif path:lower():find("%.ojm$") then
		local soundDatas = JamLoader:loadAsync(path)
		if soundDatas then
			for name, soundData in pairs(soundDatas) do
				self.aliases[name] = path .. ":" .. name
				resources.loaded[path .. ":" .. name] = soundData
			end
		end
	end
end

NoteChartResourceLoader.loadOJM = function(self, loaded, ojmPath)
	for _, path in ipairs(loaded) do
		if not path:find(ojmPath, 1, true) then
			resources.loaded[path]:release()
			resources.loaded[path] = nil
		end
	end

	resources.not_loaded = {[ojmPath] = true}
end

NoteChartResourceLoader.loadResources = function(self, loaded, newResources)
	local new, old, all = array_update(newResources, loaded)

	for _, path in ipairs(old) do
		resources.loaded[path]:release()
		resources.loaded[path] = nil
	end

	resources.not_loaded = {}
	for _, path in ipairs(new) do
		resources.not_loaded[path] = true
	end
end

local isProcessing = false
NoteChartResourceLoader.process = aquathread.coro(function(self)
	if isProcessing then
		return
	end
	isProcessing = true

	local path = next(resources.not_loaded)
	while path do
		resources.not_loaded[path] = nil
		resources.loading[path] = true

		self:loadResource(path)

		resources.loading[path] = nil

		path = next(resources.not_loaded)
	end
	self.callback()

	isProcessing = false
end)

NoteChartResourceLoader.unloadAudio = function(self)
	local path = next(resources.loaded)
	while path do
		local fileType = FileFinder:getType(path)
		if not fileType or fileType == "audio" then
			resources.loaded[path]:release()
			resources.loaded[path] = nil
		end
		path = next(resources.loaded)
	end
end

return NoteChartResourceLoader
