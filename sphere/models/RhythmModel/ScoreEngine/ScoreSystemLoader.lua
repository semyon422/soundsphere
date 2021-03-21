local Class = require("aqua.util.Class")
local ScoreSystem	= require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local ScoreSystemLoader = Class:new()

ScoreSystemLoader.loadScoreSystem = function(self)
    return ScoreSystem:new()
end

return ScoreSystemLoader
