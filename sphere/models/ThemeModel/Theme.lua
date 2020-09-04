local Class = require("aqua.util.Class")
local ViewFactory = require("sphere.views.ViewFactory")

local Theme = Class:new()

Theme.construct = function(self)
	self.viewFactory = ViewFactory:new()
end

Theme.load = function(self)
    local init = dofile(self.path .. "/init.lua")
    init(self)
end

Theme.newView = function(self, name)
	return self.viewFactory:newView(name)
end

return Theme
