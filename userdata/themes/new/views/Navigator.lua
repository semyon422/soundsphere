
local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local Observable = require("aqua.util.Observable")

local Navigator = Class:new()

Navigator.construct = function(self)
	self.observable = Observable:new()
end

Navigator.load = function(self)
	self.observable:add(self.view.controller)
end

Navigator.unload = function(self)
	self.observable:remove(self.view.controller)
end

Navigator.update = function(self)
end

Navigator.setNode = function(self, nodeName)
	self.node = assert(self[nodeName])
end

Navigator.checkNode = function(self, nodeName)
	return self.node == self[nodeName]
end

Navigator.call = function(self, ...)
	self.node:call(...)
end

Navigator.send = function(self, event)
	return self.observable:send(event)
end

Navigator.receive = function(self, event)
end

return Navigator
