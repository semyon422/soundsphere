local image			= require("aqua.image")
local sound			= require("aqua.sound")
local video			= require("aqua.video")
local Group			= require("aqua.util.Group")
local JamLoader		= require("sphere.database.JamLoader")
local FileManager	= require("sphere.filesystem.FileManager")

local NoteChartResourceLoader = {}

NoteChartResourceLoader.hitSoundsPath = "userdata/hitsounds"
NoteChartResourceLoader.sample_gain = 0
NoteChartResourceLoader.aliases = {}
NoteChartResourceLoader.resources = {}

local NoteChartTypes = {
	bms = {"bms", "osu", "quaver", "ksm", "sm"},
	o2jam = {"o2jam"},
	midi = {"midi"},
}
local NoteChartTypeMap = {}
for t, list in pairs(NoteChartTypes) do
	for i = 1, #list do
		NoteChartTypeMap[list[i]] = t
	end
end

NoteChartResourceLoader.load = function(self, path, noteChart, callback)
	local directoryPath = path:match("^(.+)/.-$")
	local noteChartType = NoteChartTypeMap[noteChart.type]

	if self.noteChart and self.sample_gain ~= sound.sample_gain then
		self:unloadAll()
		self.sample_gain = sound.sample_gain
	end

	if noteChartType == "bms" then
		if self.directoryPath and self.directoryPath ~= directoryPath then
			self:unloadAll()
		end
	elseif noteChartType == "o2jam" then
		if self.path and self.path ~= path then
			self:unloadAll()
		end
	end

	self.directoryPath = directoryPath
	self.path = path
	self.noteChart = noteChart
	self.callback = callback

	if noteChartType == "bms" then
		self:loadBMS()
	elseif noteChartType == "o2jam" then
		self:loadOJM()
	elseif noteChartType == "midi" then
		self.hitSoundsPath = self.hitSoundsPath .. "/midi"
		self:loadBMS()
	end
end

NoteChartResourceLoader.loadOJM = function(self)
	local path = self.path:match("^(.+)n$") .. "m"
	JamLoader:load(path, function(samples)
		for name in pairs(samples) do
			self.aliases[name] = path .. "/" .. name
		end
		self.callback()
	end)
end

NoteChartResourceLoader.loadBMS = function(self)
	FileManager:addPath(self.directoryPath, 1)
	FileManager:addPath(self.hitSoundsPath, 0)

	self.resourceCount = 0
	self.resourceCountLoaded = 0
	self.soundGroup = Group:new()
	self.imageGroup = Group:new()
	self.videoGroup = Group:new()
	for resourceType, name, sequence in self.noteChart:getResourceIterator() do
		for _, path in ipairs(sequence) do
			local filePath, fileType = FileManager:findFile(path)
			if filePath then
				if fileType == "audio" then
					self.soundGroup:add(filePath)
				elseif fileType == "image" then
					self.imageGroup:add(filePath)
				elseif fileType == "video" then
					self.videoGroup:add(filePath)
				end
				self.aliases[name] = filePath
				self.resourceCount = self.resourceCount + 1
				break
			end
		end
	end

	local resourceLoadedCallback = function()
		self.resourceCountLoaded = self.resourceCountLoaded + 1
		if self.resourceCountLoaded == self.resourceCount then
			self.callback()
		end
	end

	local directoryPath = self.directoryPath
	self.soundGroup:call(function(soundFilePath)
		if self.directoryPath == directoryPath then
			return sound.load(soundFilePath, resourceLoadedCallback)
		end
	end)
	self.imageGroup:call(function(imageFilePath)
		if self.directoryPath == directoryPath then
			return image.load(imageFilePath, resourceLoadedCallback)
		end
	end)
	self.videoGroup:call(function(videoFilePath)
		if self.directoryPath == directoryPath then
			resourceLoadedCallback()
		end
	end)
end

NoteChartResourceLoader.unloadAll = function(self)
	self:unload()
	self.aliases = {}
end

NoteChartResourceLoader.unload = function(self)
	local noteChartType = NoteChartTypeMap[self.noteChart.type]
	if noteChartType == "bms" then
		self:unloadBMS()
	end
end

NoteChartResourceLoader.unloadBMS = function(self)
	FileManager:removePath(self.directoryPath)
	FileManager:removePath(self.hitSoundsPath)

	self.soundGroup:call(function(soundFilePath)
		return sound.unload(soundFilePath, function() end)
	end)
	self.imageGroup:call(function(imageFilePath)
		return image.unload(imageFilePath, function() end)
	end)
	self.videoGroup:call(function(videoFilePath)
		return video.unload(videoFilePath, function() end)
	end)
end

return NoteChartResourceLoader
