local Class	= require("Class")
local cursor = require("sphere.cursor")

local WindowManager = Class:new()

local function getDimensions(mode)
	local flags = mode.flags
	if flags.fullscreen then
		return love.window.getDesktopDimensions()
	else
		return mode.window.width, mode.window.height
	end
end

WindowManager.load = function(self)
	self.graphics = self.game.configModel.configs.settings.graphics
	self.mode = self.graphics.mode
	local mode = self.mode
	local flags = mode.flags

	local width, height = getDimensions(mode)
	if not love.window.isOpen() then
		love.window.setMode(width, height, mode.flags)
	end

	self:setIcon()
	love.window.setTitle("soundsphere")

	self.fullscreen = flags.fullscreen
	self.fullscreentype = flags.fullscreentype
	self.vsync = flags.vsync
	self.cursor = self.graphics.cursor

	self:setCursor()
end

WindowManager.update = function(self)
	local flags = self.mode.flags
	local graphics = self.graphics
	if self.vsync ~= flags.vsync then
		self.vsync = flags.vsync
		love.window.setVSync(self.vsync)
	end
	if self.fullscreen ~= flags.fullscreen or (self.fullscreen and self.fullscreentype ~= flags.fullscreentype) then
		self.fullscreen = flags.fullscreen
		self.fullscreentype = flags.fullscreentype
		self:setFullscreen(self.fullscreen, self.fullscreentype)
	end
	if self.cursor ~= graphics.cursor then
		self.cursor = graphics.cursor
		self:setCursor()
	end
end

WindowManager.receive = function(self, event)
	if event.name == "keypressed" and event[1] == "f10" then
		local mode = self.mode
		local flags = mode.flags
		local width, height = getDimensions(mode)
		love.window.updateMode(width, height, flags)
	elseif event.name == "keypressed" and event[1] == "f11" then
		local mode = self.mode
		self.fullscreen = not self.fullscreen
		mode.flags.fullscreen = self.fullscreen
		self:setFullscreen(self.fullscreen, mode.flags.fullscreentype)
	elseif event.name == "mousemoved" then
		self:setCursor()
	end
end

WindowManager.setCursor = function(self)
	if self.cursor == "circle" then
		cursor:setCircleCursor()
	elseif self.cursor == "arrow" then
		cursor:setArrowCursor()
	elseif self.cursor == "system" then
		cursor:setSystemCursor()
	end
end

WindowManager.setFullscreen = function(self, fullscreen, fullscreentype)
	local mode = self.mode
	local width, height
	if self.fullscreen then
		width, height = love.window.getDesktopDimensions()
	else
		width, height = mode.window.width, mode.window.height
	end
	love.window.updateMode(width, height, {
		fullscreen = fullscreen,
		fullscreentype = fullscreentype
	})
end

local icon_path = "resources/icon.png"
WindowManager.setIcon = function(self)
	local info = love.filesystem.getInfo(icon_path)
	if info then
		local imageData = love.image.newImageData(icon_path)
		love.window.setIcon(imageData)
	end
end

return WindowManager
