local Class = require("aqua.util.Class")

local NoteSkin = Class:new()

NoteSkin.construct = function(self) end
NoteSkin.load = function(self) end
NoteSkin.check = function(self, note) end
NoteSkin.get = function(self, noteView, part, name, timeState) end
NoteSkin.where = function(self, note, time) end

return NoteSkin
