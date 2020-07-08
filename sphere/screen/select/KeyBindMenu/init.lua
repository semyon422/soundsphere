local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local InputManager		= require("sphere.screen.gameplay.InputManager")
local KeyBindList		= require("sphere.screen.select.KeyBindMenu.KeyBindList")
local BackgroundManager	= require("sphere.ui.BackgroundManager")
local NoteChartList  	= require("sphere.screen.select.NoteChartList")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")

local KeyBindMenu = {}

KeyBindMenu.hidden = true
KeyBindMenu.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")

KeyBindMenu.init = function(self)
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
	InputManager:write()
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
	InputManager:read()

	self.noteChart = self.SelectScreen:getNoteChart()

	ModifierManager.noteChart = self.noteChart
	ModifierManager:apply("NoteChartModifier")

	self:reload()
end

KeyBindMenu:init()

return KeyBindMenu
