local Class = require("aqua.util.Class")
local aquathread = require("aqua.thread")
local newPixel = require("aqua.graphics.newPixel")
local tween				= require("tween")
local aquatimer				= require("aqua.timer")

local BackgroundModel = Class:new()

BackgroundModel.alpha = 0

BackgroundModel.load = function(self)
	self.config = self.configModel.configs.select
	self.noteChartDataEntryId = 0
	self.path = ""

	self.emptyImage = newPixel(0.25, 0.25, 0.25, 1)
	self.images = {self.emptyImage}
end

BackgroundModel.update = function(self, dt)
	local noteChartItem = self.selectModel.noteChartItem
	if noteChartItem and self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		self.noteChartDataEntryId = self.config.noteChartDataEntryId
		local path = noteChartItem:getBackgroundPath()
		if self.path ~= path then
			self.path = path
			self:loadBackgroundDebounce()
		end
	elseif not noteChartItem and self.images[1] ~= self.emptyImage then
		self.images = {self.emptyImage}
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

BackgroundModel.loadBackgroundDebounce = function(self, path)
	self.path = path or self.path
	aquatimer.debounce(self, "loadDebounce", 0.1, self.loadBackground, self)
end

BackgroundModel.loadBackground = function(self)
	local path = self.path
	if not path then
		return self:setBackground(self.emptyImage)
	end

	if not path:find("^http") then
		local info = love.filesystem.getInfo(path)
		if not info or info.type == "directory" then
			self:setBackground(self.emptyImage)
			return
		end
	end

	local image
	if path:find("%.ojn$") then
		image = self:loadImage(path, "ojn")
	elseif path:find("^http") then
		image = self:loadImage(path, "http")
	elseif path:find("%.mid$") then
		image = self:loadImage("resources/midi/background.jpg")
	else
		image = self:loadImage(path)
	end

	if path ~= self.path then
		return self:loadBackground()
	end

	if image then
		return self:setBackground(image)
	end

	self:setBackground(self.emptyImage)
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
	local status, imageData = pcall(love.image.newImageData, fileData)
	if status then
		return imageData
	end
end)

local loadHttp = aquathread.async(function(url)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end

	require("love.filesystem")
	require("love.image")
	local fileData = love.filesystem.newFileData(response.body, "cover")
	local status, imageData = pcall(love.image.newImageData, fileData)
	if status then
		return imageData
	end
end)

BackgroundModel.loadImage = function(self, path, type)
	local imageData
	if type == "ojn" then
		imageData = loadOJN(path)
	elseif type == "http" then
		imageData = loadHttp(path)
	else
		imageData = loadImage(path)
	end
	if not imageData then
		return
	end
	return love.graphics.newImage(imageData)
end

return BackgroundModel
