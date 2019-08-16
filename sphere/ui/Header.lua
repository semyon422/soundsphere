local Theme = require("aqua.ui.Theme")
local ImageButton = require("aqua.ui.ImageButton")
local ImageFrame = require("aqua.graphics.ImageFrame")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local OverlayMenu = require("sphere.ui.OverlayMenu")
local icons = require("sphere.assets.icons")

local Header = {}

Header.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")
Header.csmin = CoordinateManager:getCS(0.5, 1, 0.5, 1, "min")
Header.cshl = CoordinateManager:getCS(0, 0, 0, 0, "h")

Header.settingsImage = love.graphics.newImage(icons.ic_settings_white_48dp)
Header.topHeight = 56/1080
Header.bottomHeight = 134/1080

Header.load = function(self)
	self.topButton = Theme.Button:new({
		x = 0,
		y = 0,
		w = 1,
		h = self.topHeight,
		cs = self.csall,
		mode = "fill",
		backgroundColor = {0, 0, 0, 127}
	})
	self.topButton:reload()
	
	self.bottomButton = Theme.Button:new({
		x = 0,
		y = self.topHeight,
		w = 1,
		h = self.bottomHeight,
		cs = self.csall,
		mode = "fill",
		backgroundColor = {0, 0, 0, 191}
	})
	self.bottomButton:reload()
	
	self.settingsDrawable = ImageFrame:new({
		image = self.settingsImage,
		cs = self.cshl,
		x = 0,
		y = 0,
		h = self.topHeight,
		w = self.topHeight,
		scale = 0.66,
		locate = "in",
		align = {
			x = "center",
			y = "center"
		}
	})
	self.settingsDrawable:reload()
	
	self.settingsButton = ImageButton:new({
		drawable = self.settingsDrawable,
		interact = function()
			OverlayMenu:show()
			OverlayMenu:setTitle("Settings")
			OverlayMenu:setItems({
				{
					name = "exit game",
					onClick = function()
						love.event.quit()
					end
				},
			})
		end
	})
	self.settingsButton:reload()
end

Header.draw = function(self)
	self.topButton:draw()
	self.bottomButton:draw()
	self.settingsButton:draw()
end

Header.receive = function(self, event)
	self.topButton:receive(event)
	self.bottomButton:receive(event)
	self.settingsButton:receive(event)
end

return Header
