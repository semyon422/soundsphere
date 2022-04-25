local Class = require("aqua.util.Class")
local aquathread = require("aqua.thread")
local newPixel = require("aqua.graphics.newPixel")
local tween				= require("tween")
local aquatimer				= require("aqua.timer")

local BackgroundModel = Class:new()

BackgroundModel.construct = function(self)
	self.currentPath = ""
	self.alpha = 0
end

BackgroundModel.load = function(self)
	self.config = self.configModel.configs.select
	self.noteChartDataEntryId = 0
	self.backgroundPath = ""

	self.emptyImage = newPixel(0.25, 0.25, 0.25, 1)
	self.images = {
		self.emptyImage
	}
end

BackgroundModel.update = function(self, dt)
	if self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		local backgroundPath = self:getBackgroundPath()
		if backgroundPath then
			self.noteChartDataEntryId = self.config.noteChartDataEntryId
		end
		if backgroundPath and self.backgroundPath ~= backgroundPath then
			self.backgroundPath = backgroundPath
			aquatimer.debounce(self, "loadDebounce", 0.1, self.loadBackground, self)
		end
	end

	if self.alphaTween then
		self.alphaTween:update(dt)
	end

	if #self.images > 1 then
		if self.alpha == 1 then
			table.remove(self.images, 1)
			self.alpha = 0
			self.alphaTween = nil
		elseif self.alpha == 0 then
			self.alphaTween = tween.new(0.25, self, {alpha = 1}, "inOutQuad")
		end
	end
end

BackgroundModel.setBackground = function(self, image)
	local layer = math.min(#self.images + 1, 3)
	self.images[layer] = image
	if layer == 2 then
		self.alpha = 0
	end
end

BackgroundModel.getBackgroundPath = function(self)
	local selectModel = self.selectModel

	local noteChartItem = selectModel.noteChartItem
	if not noteChartItem or not noteChartItem.path or not noteChartItem.stagePath then
		return
	end

	if noteChartItem.path:find("%.ojn$") then
		return noteChartItem.path
	end

	local directoryPath = noteChartItem.path:match("^(.+)/(.-)$") or ""
	local stagePath = noteChartItem.stagePath

	if stagePath and stagePath ~= "" then
		return directoryPath .. "/" .. stagePath
	end

	return directoryPath
end

BackgroundModel.loadBackground = function(self)
	local path = self.backgroundPath
	local info = love.filesystem.getInfo(path)
	if not info or info.type == "directory" then
		self:setBackground(self.emptyImage)
		self.currentPath = path
		return
	end
	if path ~= self.currentPath then
		self.currentPath = path
		if path:find("%.ojn$") then
			self:loadImage(path, "ojn")
		elseif path:find("%.mid$") then
			self:loadImage("resources/midi/background.jpg")
		else
			self:loadImage(path)
		end
	end
end

local loadImage = aquathread.async(function(path)
	require("love.filesystem")
	require("love.image")

	local info = love.filesystem.getInfo(path)
	if not info then
		return
	end

	local status, imageData = pcall(love.image.newImageData, path)
	if status then
		return imageData
	end
end)

local loadOJN = aquathread.async(function(path)
	require("love.filesystem")
	require("love.image")
	local OJN = require("o2jam.OJN")

	local content = love.filesystem.read(path)
	if not content then
		return
	end

	local ojn = OJN:new(content)
	if ojn.cover == "" then
		return
	end

	local fileData = love.filesystem.newFileData(ojn.cover, "cover")
	return love.image.newImageData(fileData)
end)

BackgroundModel.loadImage = aquathread.coro(function(self, path, type)
	local imageData
	if type == "ojn" then
		imageData = loadOJN(path)
	else
		imageData = loadImage(path)
	end
	if not imageData then
		return self:setBackground(self.emptyImage)
	end
	local image = love.graphics.newImage(imageData)
	self:setBackground(image)
end)

return BackgroundModel
