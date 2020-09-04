local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local ThemeList			= require("sphere.ui.ThemeMenu.ThemeList")
local Observable		= require("aqua.util.Observable")

local ThemeMenu = {}

ThemeMenu.hidden = true
ThemeMenu.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")

ThemeMenu.init = function(self)
	self.observable = Observable:new()
	self.background = Rectangle:new({
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		color = {0, 0, 0, 191},
		cs = self.csall,
		mode = "fill"
	})
	self.background:reload()

	ThemeList.menu = self
	ThemeList:init()
end

ThemeMenu.hide = function(self)
	self.hidden = true
end

ThemeMenu.update = function(self)
	ThemeList:update()
end

ThemeMenu.draw = function(self)
	if not self.hidden then
		self.background:draw()
		ThemeList:draw()
	end
end

ThemeMenu.reload = function(self)
	self.background:reload()
	ThemeList:load()
end

ThemeMenu.receive = function(self, event)
	if self.hidden then
		return
	end
	if event.name == "resize" then
		self:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		self:hide()
	end

	ThemeList:receive(event)
end

ThemeMenu.show = function(self)
	self.hidden = false

	self:reload()
end

ThemeMenu:init()

return ThemeMenu
