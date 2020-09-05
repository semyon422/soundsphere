local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local NoteChartMenuList	= require("sphere.ui.NoteChartMenu.NoteChartMenuList")

local NoteChartMenu = {}

NoteChartMenu.hidden = true
NoteChartMenu.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")

NoteChartMenu.init = function(self)
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
	
	NoteChartMenuList.menu = self
	NoteChartMenuList:init()
end

NoteChartMenu.hide = function(self)
	self.hidden = true
end

NoteChartMenu.update = function(self)
	NoteChartMenuList:update()
end

NoteChartMenu.draw = function(self)
	if not self.hidden then
		self.background:draw()
		NoteChartMenuList:draw()
	end
end

NoteChartMenu.reload = function(self)
	self.background:reload()
	NoteChartMenuList:load()
end

NoteChartMenu.receive = function(self, event)
	if self.hidden then
		return
	end
	if event.name == "resize" then
		self:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		self:hide()
	end
	
	NoteChartMenuList:receive(event)
end

NoteChartMenu.show = function(self)
	self.hidden = false
	self:reload()
end

NoteChartMenu:init()

return NoteChartMenu
