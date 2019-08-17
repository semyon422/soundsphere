local image			= require("aqua.image")
local sound			= require("aqua.sound")
local Group			= require("aqua.util.Group")
local Observable	= require("aqua.util.Observable")
local video			= require("aqua.video")
local JamLoader		= require("sphere.database.JamLoader")
local FileManager	= require("sphere.filesystem.FileManager")

local NoteChartResourceLoader = {}

NoteChartResourceLoader.resourceNames = {}
NoteChartResourceLoader.aliases = {}
NoteChartResourceLoader.hitSoundsPath = "userdata/hitsounds"

NoteChartResourceLoader.init = function(self)
	self.observable = Observable:new()
end

NoteChartResourceLoader.load = function(self, path, noteChart, callback)
	local directoryPath = path:match("^(.+)/")
	if self.directoryPath and self.directoryPath ~= directoryPath then
		self:unload()
	end
	self.directoryPath = directoryPath
	self.path = path
	self.noteChart = noteChart
	self.callback = callback
	
	if self.noteChart.type == "bms" or self.noteChart.type == "osu" or self.noteChart.type == "quaver" or self.noteChart.type == "ksm" then
		self:loadBMS()
	elseif self.noteChart.type == "o2jam" then
		self:loadOJM()
	end
end

NoteChartResourceLoader.loadOJM = function(self)
	local path = self.path:match("(.+)n/%d$") .. "m"
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
		if resourceType == "sound" then
			for _, path in ipairs(sequence) do
				local soundFilePath = FileManager:findFile(path, "audio")
				if soundFilePath then
					if not self.soundGroup.objects[soundFilePath] then
						self.soundGroup:add(soundFilePath)
						self.resourceCount = self.resourceCount + 1
						self.aliases[name] = soundFilePath
					end
					break
				end
			end
		elseif resourceType == "image" then
			for _, path in ipairs(sequence) do
				local imageFilePath = FileManager:findFile(path, "image")
				local videoFilePath = FileManager:findFile(path, "video")
				if imageFilePath then
					if not self.imageGroup.objects[imageFilePath] then
						self.imageGroup:add(imageFilePath)
						self.resourceCount = self.resourceCount + 1
						self.aliases[name] = imageFilePath
					end
					break
				elseif videoFilePath then
					if not self.videoGroup.objects[videoFilePath] then
						self.videoGroup:add(videoFilePath)
						self.resourceCount = self.resourceCount + 1
						self.aliases[name] = videoFilePath
					end
					break
				end
			end
		end
	end
	
	local resourceLoadedCallback = function()
		self.resourceCountLoaded = self.resourceCountLoaded + 1
		if self.resourceCountLoaded == self.resourceCount then
			self.callback()
		end
		
		return self.observable:send({
			name = "notify",
			text = self.resourceCountLoaded .. "/" .. self.resourceCount
		})
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
			return video.load(videoFilePath, resourceLoadedCallback)
		end
	end)
end

NoteChartResourceLoader.unload = function(self)
	if self.noteChart.type == "bms" or self.noteChart.type == "osu" or self.noteChart.type == "quaver" or self.noteChart.type == "ksm"  then
		self:unloadBMS()
	elseif self.noteChart.type == "o2jam" then
		self:unloadOJM()
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

NoteChartResourceLoader.unloadOJM = function(self)
	JamLoader:unload(self.path:match("(.+)n/%d$") .. "m", function() end)
end

return NoteChartResourceLoader
