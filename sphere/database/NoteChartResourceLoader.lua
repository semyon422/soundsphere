local image			= require("aqua.image")
local sound			= require("aqua.sound")
local video			= require("aqua.video")
local JamLoader		= require("sphere.database.JamLoader")
local FileManager	= require("sphere.filesystem.FileManager")
local array_update = require("aqua.util.array_update")

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

	if self.sample_gain ~= sound.sample_gain then
		self:unloadAudio()
		self.sample_gain = sound.sample_gain
	end

	self.path = path
	self.noteChart = noteChart
	self.callback = callback

	FileManager:reset()
	if noteChartType == "bms" then
		FileManager:addPath(directoryPath, 2)
		FileManager:addPath(self.hitSoundsPath, 1)
		self:loadBMS()
	elseif noteChartType == "o2jam" then
		self:loadOJM()
	elseif noteChartType == "midi" then
		FileManager:addPath(self.hitSoundsPath .. "/midi", 1)
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
	local resourceCount = 0
	local resourceCountLoaded = 0

	self.aliases = {}
	local newResources = {}
	for resourceType, name, sequence in self.noteChart:getResourceIterator() do
		for _, path in ipairs(sequence) do
			local filePath, fileType = FileManager:findFile(path)
			if filePath then
				table.insert(newResources, filePath)
				self.aliases[name] = filePath
				resourceCount = resourceCount + 1
				break
			end
		end
	end

	local new, old, all = array_update(newResources, self.resources)
	if #new == 0 then
		return self.callback()
	end

	local resourceLoadedCallback = function()
		resourceCountLoaded = resourceCountLoaded + 1
		if resourceCountLoaded == resourceCount then
			self.callback()
			self.resources = all
		end
	end

	for _, path in ipairs(new) do
		local fileType = FileManager:getType(path)
		if fileType == "image" then
			image.load(path, resourceLoadedCallback)
		elseif fileType == "audio" then
			sound.load(path, resourceLoadedCallback)
		elseif fileType == "video" then
			resourceLoadedCallback()
			-- video.load(path, resourceLoadedCallback)
		end
	end

	for _, path in ipairs(old) do
		local fileType = FileManager:getType(path)
		if fileType == "image" then
			image.unload(path, function() end)
		elseif fileType == "audio" then
			sound.unload(path, function() end)
		elseif fileType == "video" then
			video.unload(path, function() end)
		end
	end
end

NoteChartResourceLoader.unloadAudio = function(self)
	local audios = {}
	for _, path in ipairs(self.resources) do
		local fileType = FileManager:getType(path)
		if fileType == "audio" then
			table.insert(audios, path)
			sound.unload(path, function() end)
		end
	end

	local new, old, all = array_update(audios, self.resources)
	self.resources = old
end

return NoteChartResourceLoader
