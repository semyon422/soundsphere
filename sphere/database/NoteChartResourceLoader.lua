local audio			= require("aqua.audio")
local video			= require("video")
local Video			= require("sphere.database.Video")
local aquathread	= require("aqua.thread")
local JamLoader		= require("sphere.database.JamLoader")
local FileFinder	= require("sphere.filesystem.FileFinder")
local array_update = require("aqua.util.array_update")

local _newSoundDataAsync = aquathread.async(function(path, sample_gain)
	local fileData = love.filesystem.newFileData(path)
	if not fileData then
		return
	end
	local audio = require("aqua.audio")
	local soundData = audio.newSoundData(fileData:getFFIPointer(), fileData:getSize(), sample_gain)
	fileData:release()
	return soundData
end)

local function newSoundDataAsync(path, sample_gain)
	local soundData = _newSoundDataAsync(path, sample_gain)
	if not soundData then return end
	return setmetatable(soundData, {__index = audio.SoundData})
end

local newImageDataAsync = aquathread.async(function(s)
	require("love.image")
	local status, err = pcall(love.image.newImageData, s)
	if not status then return end
	return err
end)

local function newImageAsync(s)
	local imageData = newImageDataAsync(s)
	if not imageData then return end
	return love.graphics.newImage(imageData)
end

local newFileDataAsync = aquathread.async(function(path)
	return love.filesystem.newFileData(path)
end)

local function newVideoAsync(path)
	local fileData = newFileDataAsync(path)
	if not fileData then return end

	local _v = video.open(fileData:getPointer(), fileData:getSize())
	if not _v then
		return
	end

	local v = setmetatable({}, {__index = Video})
	v.video = _v
	v.fileData = fileData
	v.imageData = love.image.newImageData(_v:getDimensions())
	v.image = love.graphics.newImage(v.imageData)

	return v
end

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

	local sample_gain = self.game.configModel.configs.settings.audio.sampleGain
	if self.sample_gain ~= sample_gain then
		self:unloadAudio()
		self.sample_gain = sample_gain
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
		resources.loaded[path] = newSoundDataAsync(path, self.sample_gain)
	elseif fileType == "image" then
		resources.loaded[path] = newImageAsync(path)
	elseif fileType == "video" then
		resources.loaded[path] = newVideoAsync(path)
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
