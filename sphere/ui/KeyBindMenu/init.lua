local Observable		= require("aqua.util.Observable")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local KeyBindList		= require("sphere.ui.KeyBindMenu.KeyBindList")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local KeyBindMenu = {}

KeyBindMenu.hidden = true
KeyBindMenu.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")

KeyBindMenu.init = function(self)
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

	KeyBindList.menu = self
	KeyBindList:init()
	KeyBindList.observable:add(self)

	BackgroundManager:setColor({63, 63, 63})
end

KeyBindMenu.hide = function(self)
	self.hidden = true
end

KeyBindMenu.update = function(self)
	KeyBindList:update()
end

KeyBindMenu.draw = function(self)
	if not self.hidden then
		self.background:draw()
		KeyBindList:draw()
	end
end

KeyBindMenu.reload = function(self)
	self.background:reload()
	KeyBindList:load()
end

KeyBindMenu.receive = function(self, event)
	if self.hidden then
		return
	end
	if event.name == "resize" then
		self:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		self:hide()
	end

	if event.name == "resize" then
		KeyBindList:reload()
		return
	end

	KeyBindList:receive(event)
end

KeyBindMenu.show = function(self)
	self.hidden = false

	self.observable:send({
		name = "loadModifiedNoteChart"
	})

	self.noteChart = self.noteChartModel.noteChart

	self:reload()
end

KeyBindMenu:init()

return KeyBindMenu
