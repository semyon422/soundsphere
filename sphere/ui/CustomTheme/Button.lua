local CS = require("aqua.graphics.CS")
local aquaButton = require("aqua.ui.Button")
local Class = require("aqua.util.Class")
local aquafonts = require("aqua.assets.fonts")
local spherefonts = require("sphere.assets.fonts")
local Observable = require("aqua.util.Observable")

local Button = Class:new()

Button.construct = function(self, objectData)
	self.observable = Observable:new()
	self.cs = CS:new(objectData.cs)
	self.cs:reload()
	self.button = aquaButton:new(objectData)
	self.button.cs = self.cs
	self.button.font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	self.button:reload()
end

Button.load = function(self)
	self.container:add(self.button)
end

Button.unload = function(self)
	self.container:remove(self.button)
end

Button.update = function(self) end

Button.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
	end
	self.button:receive(event)
end

return Button
