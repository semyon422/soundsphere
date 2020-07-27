local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Rectangle			= require("aqua.graphics.Rectangle")
local NoteSkinList		= require("sphere.ui.NoteSkinMenu.NoteSkinList")

local NoteSkinMenu = {}

local NoteSkinMenu = {}

NoteSkinMenu.hidden = true
NoteSkinMenu.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")

NoteSkinMenu.init = function(self)
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

	NoteSkinList.menu = self
	NoteSkinList:init()
end

NoteSkinMenu.hide = function(self)
	self.hidden = true
end

NoteSkinMenu.update = function(self)
	NoteSkinList:update()
end

NoteSkinMenu.draw = function(self)
	if not self.hidden then
		self.background:draw()
		NoteSkinList:draw()
	end
end

NoteSkinMenu.reload = function(self)
	self.background:reload()
	NoteSkinList:load()
end

NoteSkinMenu.receive = function(self, event)
	if self.hidden then
		return
	end
	if event.name == "resize" then
		self:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		self:hide()
	end

	NoteSkinList:receive(event)
end

NoteSkinMenu.show = function(self)
	self.hidden = false

	self.noteChart = self.noteChartModel:getNoteChart()

	self.modifierModel.noteChart = self.noteChart
	self.modifierModel:apply("NoteChartModifier")

	self:reload()
end

NoteSkinMenu:init()

return NoteSkinMenu
