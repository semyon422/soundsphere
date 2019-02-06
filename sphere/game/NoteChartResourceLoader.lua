local Group = require("aqua.util.Group")
local Observable = require("aqua.util.Observable")
local sound = require("aqua.sound")
local FileManager = require("sphere.filesystem.FileManager")
local JamLoader = require("sphere.game.JamLoader")

local NoteChartResourceLoader = {}
NoteChartResourceLoader.observable = Observable:new()

NoteChartResourceLoader.resourceNames = {}
NoteChartResourceLoader.aliases = {}

NoteChartResourceLoader.load = function(self, path, noteChart, callback)
	local directoryPath = path:match("^(.+)/")
	if self.directoryPath and self.directoryPath ~= directoryPath then
		self:unload()
	end
	self.directoryPath = directoryPath
	self.path = path
	self.noteChart = noteChart
	self.callback = callback
	
	if self.noteChart.type == "bms" or self.noteChart.type == "osu" then
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
	FileManager:addPath(self.directoryPath)
	
	self.resourceCount = 0
	self.resourceCountLoaded = 0
	self.soundGroup = Group:new()
	for resourceType, resourceName in self.noteChart:getResourceIterator() do
		if resourceType == "sound" then
			local soundFilePath = FileManager:findFile(resourceName, "audio")
			if soundFilePath then
				self.soundGroup:add(soundFilePath)
				self.resourceCount = self.resourceCount + 1
				self.aliases[resourceName] = soundFilePath
			end
		end
	end
	
	local directoryPath = self.directoryPath
	return self.soundGroup:call(function(soundFilePath)
		if self.directoryPath == directoryPath then
			return sound.load(soundFilePath, function()
				self.resourceCountLoaded = self.resourceCountLoaded + 1
				if self.resourceCountLoaded == self.resourceCount then
					self.callback()
				end
				
				return self.observable:send({
					name = "notify",
					text = self.resourceCountLoaded .. "/" .. self.resourceCount
				})
			end)
		end
	end)
end

NoteChartResourceLoader.unload = function(self)
	if self.noteChart.type == "bms" or self.noteChart.type == "osu" then
		self:unloadBMS()
	elseif self.noteChart.type == "o2jam" then
		self:unloadOJM()
	end
end

NoteChartResourceLoader.unloadBMS = function(self)
	FileManager:removePath(self.directoryPath)
	
	return self.soundGroup:call(function(soundFilePath)
		return sound.unload(soundFilePath, function() end)
	end)
end

NoteChartResourceLoader.unloadOJM = function(self)
	JamLoader:unload(self.path:match("(.+)n/%d$") .. "m", function() end)
end

return NoteChartResourceLoader
