local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local ThreadPool	= require("aqua.thread.ThreadPool")
local image			= require("aqua.image")

local BackgroundModel = Class:new()

BackgroundModel.construct = function(self)
	self.observable = Observable:new()
	self.currentPath = ""

	self.emptyImageData = love.image.newImageData(1, 1)
	self.emptyImage = love.graphics.newImage(self.emptyImageData)
	self.image = self.emptyImage
end

BackgroundModel.load = function(self)
	ThreadPool.observable:add(self)

	self.config = self.configModel:getConfig("select")
	self.noteChartDataEntryId = 0
	self.backgroundPath = ""
end

BackgroundModel.unload = function(self)
	ThreadPool.observable:remove(self)
end

BackgroundModel.update = function(self)
	if self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		self.noteChartDataEntryId = self.config.noteChartDataEntryId
		local backgroundPath = self:getBackgroundPath()
		if self.backgroundPath ~= backgroundPath then
			self.backgroundPath = backgroundPath
			self:loadBackground(backgroundPath)
		end
	end
end

BackgroundModel.getImage = function(self)
	return self.image
end

BackgroundModel.getBackgroundPath = function(self)
	local config = self.config

	local noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(config.noteChartSetEntryId)
	local noteChartDataEntry = self.cacheModel.cacheManager:getNoteChartDataEntryById(config.noteChartDataEntryId)

	local directoryPath = noteChartSetEntry.path
	local stagePath = noteChartDataEntry.stagePath

	if stagePath and stagePath ~= "" then
		return directoryPath .. "/" .. stagePath
	end

	return directoryPath
end

BackgroundModel.loadBackground = function(self, path)
	local info = love.filesystem.getInfo(path)
	if not info or info.type == "directory" then
		self.image = self.emptyImage
		self.currentPath = path
		return
	end
	if path ~= self.currentPath then
		self.currentPath = path
		if path:find("%.ojn$") then
			self:loadOJN(path)
		elseif path:find("%.mid$") then
			self:loadImage("resources/midi/background.jpg")
		else
			self:loadImage(path)
		end
	end
end

BackgroundModel.loadImage = function(self, path)
	image.load(path, function(imageData)
		if imageData then
			self.image = love.graphics.newImage(imageData)
		end
	end)
end

BackgroundModel.loadOJN = function(self, path)
	return ThreadPool:execute(
		[[
			require("love.filesystem")
			require("love.image")

			local OJN = require("o2jam.OJN")

			local path = ...
			local file = love.filesystem.newFile(path)
			file:open("r")
			local content = file:read()
			file:close()

			local ojn = OJN:new(content)
			if ojn.cover == "" then
				return
			end

			local fileData = love.filesystem.newFileData(ojn.cover, "cover")
			local imageData = love.image.newImageData(fileData)

			thread:push({
				name = "OJNBackground",
				imageData = imageData,
				path = path
			})
		]],
		{path}
	)
end

BackgroundModel.receive = function(self, event)
	if event.name == "OJNBackground" then
		self.image = love.graphics.newImage(event.imageData)
	end
end

return BackgroundModel
