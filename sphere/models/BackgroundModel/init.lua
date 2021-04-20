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
end

BackgroundModel.unload = function(self)
	ThreadPool.observable:remove(self)
end

BackgroundModel.getImage = function(self)
	return self.image
end

BackgroundModel.loadBackground = function(self, path)
	local info = love.filesystem.getInfo(path)
	if not info or info.type == "directory" then
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
