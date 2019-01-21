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
	self.path = path
	local directoryPath = path:match("^(.+)/")
	
	if self.directoryPath and self.directoryPath ~= directoryPath then
		self:unload()
		self.directoryPath = directoryPath
	end
	
	FileManager:addPath(directoryPath)
	
	self.resourceCount = 0
	self.resourceCountLoaded = 0
	self.soundGroup = Group:new()
	for resourceType, resourceName in noteChart:getResourceIterator() do
		if resourceType == "sound" then
			self:loadSound(resourceName)
		elseif resourceType == "ojm" then
			self.o2jam = true
			self:loadOJM(callback)
		end
	end
	
	return self.soundGroup:call(function(soundFilePath)
		return sound.load(soundFilePath, function()
			self.resourceCountLoaded = self.resourceCountLoaded + 1
			if self.resourceCountLoaded == self.resourceCount then
				callback()
			end
			
			return self.observable:send({
				name = "notify",
				text = self.resourceCountLoaded .. "/" .. self.resourceCount
			})
		end)
	end)
end

NoteChartResourceLoader.unload = function(self)
	FileManager:removePath(self.directoryPath)
	
	if self.o2jam then
		JamLoader:unload(self.path:match("(.+)n/%d$") .. "m", function() end)
		self.o2jam = false
	end
	
	return self.soundGroup:call(function(soundFilePath)
		return sound.unload(soundFilePath, function() end)
	end)
end

NoteChartResourceLoader.loadSound = function(self, resourceName)
	local soundFilePath = FileManager:findFile(resourceName, "audio")
	if soundFilePath then
		self.soundGroup:add(soundFilePath)
		self.resourceCount = self.resourceCount + 1
		self.aliases[resourceName] = soundFilePath
	end
end

NoteChartResourceLoader.loadOJM = function(self, callback)
	local path = self.path:match("(.+)n/%d$") .. "m"
	JamLoader:load(path, function(samples)
		for name in pairs(samples) do
			self.aliases[name] = path .. "/" .. name
		end
		callback()
	end)
end

return NoteChartResourceLoader
