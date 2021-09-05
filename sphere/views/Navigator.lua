
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")

local Navigator = Class:new()

Navigator.construct = function(self)
	self.observable = Observable:new()
	self.debugHidden = true
end

Navigator.load = function(self)
	self.observable:add(self.view.controller)
end

Navigator.unload = function(self)
	self.observable:remove(self.view.controller)
end

Navigator.update = function(self) end

Navigator.send = function(self, event)
	return self.observable:send(event)
end

Navigator.receive = function(self, event) end

Navigator.changeScreen = function(self, screenName)
	self:send({
		name = "changeScreen",
		screenName = screenName
	})
end

Navigator.showDebug = function(self)
	self.debugHidden = not self.debugHidden
	for _, config in ipairs(self.viewConfig) do
		if config.debug then
			config.hidden = self.debugHidden
		end
	end
end

return Navigator
