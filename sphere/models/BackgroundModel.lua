local Class = require("aqua.util.Class")
local ThreadPool	= require("aqua.thread.ThreadPool")
local aquaimage			= require("aqua.image")
local newPixel = require("aqua.graphics.newPixel")
local tween				= require("tween")

local BackgroundModel = Class:new()

BackgroundModel.construct = function(self)
	self.currentPath = ""
	self.alpha = 0
	self.loadable = 0
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
	if self.loadTween then
		self.loadTween:update(dt)
	end

	if self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		self.noteChartDataEntryId = self.config.noteChartDataEntryId
		local backgroundPath = self:getBackgroundPath()
		if backgroundPath and self.backgroundPath ~= backgroundPath then
			self.backgroundPath = backgroundPath
			self.loadable = 0
			self.loadTween = tween.new(0.1, self, {loadable = 1}, "inOutQuad")
		end
	end

	if self.loadable == 1 then
		self:loadBackground(self.backgroundPath)
		self.loadable = 0
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
	local noteChartSetEntry = selectModel.noteChartSetItem.noteChartSetEntry
	local noteChartDataEntry = selectModel.noteChartItem.noteChartDataEntry

	if not noteChartSetEntry or not noteChartDataEntry then
		return
	end

	local directoryPath = noteChartSetEntry.path
	local stagePath = noteChartDataEntry.stagePath

	if stagePath and stagePath ~= "" then
		return directoryPath .. "/" .. stagePath
	end

	return directoryPath
end

BackgroundModel.reloadBackground = function(self)
	self:loadBackground(self.backgroundPath)
end

BackgroundModel.loadBackground = function(self, path)
	local info = love.filesystem.getInfo(path)
	if not info or info.type == "directory" then
		self:setBackground(self.emptyImage)
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
	aquaimage.load(path, function(imageData)
		if imageData then
			local image = love.graphics.newImage(imageData)
			self:setBackground(image)
		end
	end)
end

BackgroundModel.loadOJN = function(self, path)
	return ThreadPool:execute({
		f = function(path)
			require("love.filesystem")
			require("love.image")

			local OJN = require("o2jam.OJN")

			local file = love.filesystem.newFile(path)
			file:open("r")
			local content = file:read()
			file:close()

			local ojn = OJN:new(content)
			if ojn.cover == "" then
				return
			end

			local fileData = love.filesystem.newFileData(ojn.cover, "cover")
			return love.image.newImageData(fileData)
		end,
		params = {path},
		result = function(imageData)
			if not imageData then
				return self:setBackground(self.emptyImage)
			end
			local image = love.graphics.newImage(imageData)
			self:setBackground(image)
		end
	})
end

return BackgroundModel
