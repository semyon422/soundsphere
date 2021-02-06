local Class			= require("aqua.util.Class")
local icons			= require("sphere.assets.icons")

local SwitchView = Class:new()

SwitchView.construct = function(self)
	self.checkboxOffImage = love.graphics.newImage(icons.ic_check_box_outline_blank_white_24dp)
	self.checkboxOnImage = love.graphics.newImage(icons.ic_check_box_white_24dp)
end

SwitchView.x = 0
SwitchView.y = 0
SwitchView.w = 0
SwitchView.h = 0
SwitchView.value = 0

SwitchView.setPosition = function(self, x, y, w, h)
	self.x, self.y, self.w, self.h = x, y, w, h
end

SwitchView.setValue = function(self, value)
	self.value = value
end

SwitchView.draw = function(self)
	local x, y, w, h = self.x, self.y, self.w, self.h

	local drawable = self.checkboxOnImage
	if self.value == 0 then
		drawable = self.checkboxOffImage
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(
		drawable,
		x + w - h / 2,
		y + h / 2,
		0,
		h / drawable:getWidth() * 0.5,
		h / drawable:getHeight() * 0.5,
		drawable:getWidth() / 2,
		drawable:getHeight() / 2
	)
end

return SwitchView
