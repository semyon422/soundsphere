local Class = require("aqua.util.Class")

local Background = Class:new()

Background.visible = -1

Background.load = function(self) end
Background.unload = function(self) end
Background.update = function(self) end
Background.draw = function(self) end
Background.fadeIn = function(self) end
Background.fadeOut = function(self) end

return Background
