local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Theme				= require("aqua.ui.Theme")
local aquafonts			= require("aqua.assets.fonts")

local Button = Class:new()

local transparent = {0, 0, 0, 0}
local white = {255, 255, 255, 255}
Button.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.layer = self.data.layer
	self.textAlign = self.data.textAlign
	self.text = self.data.text or ""
	self.textColor = self.data.textColor or white
	self.backgroundColor = self.data.backgroundColor or transparent

	if self.data.font then
		self.font = aquafonts.getFont(self.data.font, self.data.fontSize)
	end

	self.interact = function()
		local sequence = self.data.interact
		if not sequence then return end
		for i = 1, #sequence do
			local f = self.gui.functions[sequence[i]]
			if f then f() end
		end
	end

	self.container = self.gui.container

	self:load()
end

Button.load = function(self)
	self.button = Theme.Button:new({
		text = self.text,
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		limit = self.w,
		cs = self.cs,
		layer = self.layer,
		mode = "fill",
		textolor = self.textolor,
		backgroundColor = self.backgroundColor,
		textAlign = self.textAlign,
		font = self.font,
		interact = self.interact
	})
	self.button:reload()

	self.container:add(self.button)
end

Button.receive = function(self, event)
	self.button:receive(event)
end

Button.update = function(self)
	self.button:update()
end

Button.unload = function(self)
	self.container:remove(self.button)
end

Button.reload = function(self)
	self:unload()
	self:load()
end

return Button
