local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local ImageFrame		= require("aqua.graphics.ImageFrame")
local ImageButton		= require("aqua.ui.ImageButton")
local Theme				= require("aqua.ui.Theme")
local icons				= require("sphere.assets.icons")
local ScreenManager		= require("sphere.screen.ScreenManager")

local Header = {}

Header.topHeight = 56/1080
Header.bottomHeight = 134/1080

Header.init = function(self)
	self.csall = CoordinateManager:getCS(0, 0, 0, 0, "all")
	self.csmin = CoordinateManager:getCS(0.5, 1, 0.5, 1, "min")
	self.cshl = CoordinateManager:getCS(0, 0, 0, 0, "h")
	
	self.settingsImage = love.graphics.newImage(icons.ic_settings_white_48dp)
	
	self.topButton = Theme.Button:new({
		x = 0,
		y = 0,
		w = 1,
		h = self.topHeight,
		cs = self.csall,
		mode = "fill",
		backgroundColor = {0, 0, 0, 127}
	})
	
	self.bottomButton = Theme.Button:new({
		x = 0,
		y = self.topHeight,
		w = 1,
		h = self.bottomHeight,
		cs = self.csall,
		mode = "fill",
		backgroundColor = {0, 0, 0, 191}
	})
	
	self.settingsDrawable = ImageFrame:new({
		image = self.settingsImage,
		cs = self.cshl,
		x = 0,
		y = 0,
		h = self.topHeight,
		w = self.topHeight * 1.5,
		scale = 0.66,
		locate = "in",
		align = {
			x = "center",
			y = "center"
		}
	})
	
	self.settingsButton = ImageButton:new({
		drawable = self.settingsDrawable,
		interact = function()
			return ScreenManager:set(require("sphere.screen.settings.SettingsScreen"))
		end
	})
end

Header.reload = function(self)
	self.topButton:reload()
	self.bottomButton:reload()
	self.settingsDrawable:reload()
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
