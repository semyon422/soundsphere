local image			= require("aqua.image")
local sound			= require("aqua.sound")
local Group			= require("aqua.util.Group")
local Observable	= require("aqua.util.Observable")
local video			= require("aqua.video")
local JamLoader		= require("sphere.database.JamLoader")
local FileManager	= require("sphere.filesystem.FileManager")

local NoteChartResourceLoader = {}

NoteChartResourceLoader.resourceNames = {}
NoteChartResourceLoader.hitSoundsPath = "userdata/hitsounds"
NoteChartResourceLoader.sample_gain = 0

NoteChartResourceLoader.init = function(self)
	self.observable = Observable:new()
	self.localAliases = {}
	self.globalAliases = {}
	JamLoader:init()
end

NoteChartResourceLoader.getNoteChartType = function(self, noteChart)
	if noteChart.type == "bms" or noteChart.type == "osu" or noteChart.type == "quaver" or noteChart.type == "ksm" then
		return "bms"
	elseif noteChart.type == "o2jam" then
		return "o2jam"
	elseif noteChart.type == "midi" then
		return "midi"
	end
end

NoteChartResourceLoader.load = function(self, path, noteChart, callback)
	local directoryPath = path:match("^(.+)/")
	local noteChartType = self:getNoteChartType(noteChart)

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
	local path = self.path:match("(.+)n$") .. "m"
	JamLoader:load(path, function(samples)
		for name in pairs(samples) do
			self.localAliases[name] = path .. "/" .. name
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
						if soundFilePath:find(self.directoryPath, 1, true) then
							self.localAliases[name] = soundFilePath
						else
							self.globalAliases[name] = soundFilePath
						end
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
						if imageFilePath:find(self.directoryPath, 1, true) then
							self.localAliases[name] = imageFilePath
						else
							self.globalAliases[name] = imageFilePath
						end
					end
					break
				elseif videoFilePath then
					if not self.videoGroup.objects[videoFilePath] then
						self.videoGroup:add(videoFilePath)
						self.resourceCount = self.resourceCount + 1
						if videoFilePath:find(self.directoryPath, 1, true) then
							self.localAliases[name] = videoFilePath
						else
							self.globalAliases[name] = videoFilePath
						end
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
			resourceLoadedCallback()
		end
	end)
end

NoteChartResourceLoader.unloadAll = function(self)
	self:unload()
	self.localAliases = {}
	self.globalAliases = {}
end

NoteChartResourceLoader.unload = function(self)
	if self.noteChart.type == "bms" or self.noteChart.type == "osu" or self.noteChart.type == "quaver" or self.noteChart.type == "ksm" or self.noteChart.type == "midi" then
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
	JamLoader:unload(self.path:match("(.+)n$") .. "m", function() end)
end

NoteChartResourceLoader:init()

return NoteChartResourceLoader
