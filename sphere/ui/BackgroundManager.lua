local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local image				= require("aqua.image")
local ImageBackground	= require("sphere.ui.ImageBackground")
local tween				= require("tween")
local ThreadPool		= require("aqua.thread.ThreadPool")

local BackgroundManager = {}

BackgroundManager.color = {0, 0, 0}

BackgroundManager.init = function(self)
	self.state = 0
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	self.backgrounds = {}
	ThreadPool.observable:add(self)
end

BackgroundManager.loadDrawableBackground = function(self, path)
	local info = love.filesystem.getInfo(path)
	if not info or info.type == "directory" then
		return
	end
	if path ~= self.currentPath then
		self.currentPath = path
		if path:find("%.ojn$") then
			return self:loadOJNBackground(path)
		elseif path:find("%.mid$") then
			return self:loadImageBackground("resources/midi/background.jpg")
		else
			return self:loadImageBackground(path)
		end
	end
end

BackgroundManager.loadImageBackground = function(self, path)
	return image.load(path, function(imageData)
		if imageData then
			return self:setBackground(
				ImageBackground:new({
					image = love.graphics.newImage(imageData),
					cs = self.cs,
					color = {255, 255, 255, 0},
					globalColor = self.color,
					path = path
				})
			)
		end
	end)
end

BackgroundManager.loadOJNBackground = function(self, path)
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

BackgroundManager.setColor = function(self, color)
	love.timer.step()
	self.colorTween = tween.new(0.5, self.color, color, "inOutQuad")
end

BackgroundManager.setBackground = function(self, background)
	local layer = math.min(#self.backgrounds + 1, 3)
	self.backgrounds[layer] = background
	background:load()
end

BackgroundManager.update = function(self, dt)
	if self.colorTween then self.colorTween:update(dt) end
	
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:update()
	end
	
	if #self.backgrounds > 1 then
		local background = self.backgrounds[2]
		if background.visible == -1 then
			background:fadeIn()
		end
		if background.visible == 1 then
			self.backgrounds[1]:unload()
			table.remove(self.backgrounds, 1)
		end
	elseif #self.backgrounds == 1 then
		local background = self.backgrounds[1]
		if background.visible == -1 then
			background:fadeIn()
		end
	end
end

BackgroundManager.draw = function(self)
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:draw()
	end
end

BackgroundManager.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	end
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:receive(event)
	end
	if event.name == "OJNBackground" then
		return self:setBackground(
			ImageBackground:new({
				image = love.graphics.newImage(event.imageData),
				cs = self.cs,
				color = {255, 255, 255, 0},
				globalColor = self.color,
				path = event.path
			})
		)
	end
end

BackgroundManager.reload = function(self, event)
	for i = 1, #self.backgrounds do
		self.backgrounds[i]:reload()
	end
end

BackgroundManager:init()

return BackgroundManager
