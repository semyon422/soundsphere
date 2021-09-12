local Class = require("aqua.util.Class")

local Screen = Class:new()

Screen.load = function(self) end
Screen.unload = function(self) end
Screen.update = function(self) end
Screen.draw = function(self) end
Screen.receive = function(self) end

return Screen
