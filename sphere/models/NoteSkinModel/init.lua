local Class = require("aqua.util.Class")
local NoteSkinManager = require("sphere.models.NoteSkinModel.NoteSkinManager")
local NoteSkinLoader = require("sphere.models.NoteSkinModel.NoteSkinLoader")

local NoteSkinModel = Class:new()

NoteSkinModel.load = function(self)
    NoteSkinManager:load()
end

NoteSkinModel.getNoteSkin = function(self, noteChart)
    return NoteSkinLoader:load(NoteSkinManager:getMetaData(noteChart.inputMode))
end

return NoteSkinModel
