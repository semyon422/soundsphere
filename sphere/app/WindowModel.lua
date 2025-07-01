local class = require("class")
local Cursor = require("sphere.app.Cursor")
local loop = require("loop")
local brand = require("brand")

---@class sphere.WindowModel
---@operator call: sphere.WindowModel
local WindowModel = class()

function WindowModel:new()
	self.cursor = Cursor()
end

WindowModel.baseVsync = 1

---@param mode table
---@return number
---@return number
local function getDimensions(mode)
	local flags = mode.flags
	if flags.fullscreen then
		return love.window.getDesktopDimensions()
	else
		return mode.window.width, mode.window.height
	end
end

---@param graphics table
function WindowModel:load(graphics)
	self.graphics = graphics
	self.mode = self.graphics.mode
	local mode = self.mode
	local flags = mode.flags

	local width, height = getDimensions(mode)
	if not love.window.isOpen() then
		love.window.setMode(width, height, mode.flags)
	end

	self:setIcon()
	love.window.setTitle(brand.name)

	self.fullscreen = flags.fullscreen
	self.fullscreentype = flags.fullscreentype
	self.vsync = flags.vsync
	self.cursor_name = self.graphics.cursor

	self.cursor:createCursors()
	self.cursor:setCursor(self.cursor_name)
end

function WindowModel:update()
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
	if self.cursor_name ~= graphics.cursor then
		self.cursor_name = graphics.cursor
		self.cursor:setCursor(self.cursor_name)
	end

	loop.fpslimit = graphics.fps
	loop.unlimited_fps = graphics.unlimited_fps
	loop.asynckey = graphics.asynckey
	loop.dwmflush = graphics.dwmflush
end

---@param event table
function WindowModel:receive(event)
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
	end
end

---@param fullscreen boolean
---@param fullscreentype string
function WindowModel:setFullscreen(fullscreen, fullscreentype)
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

local icon_path = "resources/logo.png"
function WindowModel:setIcon()
	local info = love.filesystem.getInfo(icon_path)
	if info then
		local imageData = love.image.newImageData(icon_path)
		love.window.setIcon(imageData)
	end
end

---@param enabled boolean
function WindowModel:setVsyncOnSelect(enabled)
	local graphics = self.graphics
	if not graphics.vsyncOnSelect then
		return
	end
	local flags = graphics.mode.flags
	if not enabled then
		self.baseVsync = flags.vsync ~= 0 and flags.vsync or 1
		flags.vsync = 0
	elseif flags.vsync == 0 then
		flags.vsync = self.baseVsync
	end
end

return WindowModel
