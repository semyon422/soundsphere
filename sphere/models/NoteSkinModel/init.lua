local Class = require("aqua.util.Class")
local NoteSkinManager = require("sphere.models.NoteSkinModel.NoteSkinManager")
local NoteSkinLoader = require("sphere.models.NoteSkinModel.NoteSkinLoader")

local NoteSkinModel = Class:new()

NoteSkinModel.load = function(self)
    NoteSkinManager:load()
end

NoteSkinModel.getMetaDataList = function(self, noteChart)
    return NoteSkinManager:getMetaDataList(noteChart.inputMode)
end

NoteSkinModel.setDefaultNoteSkin = function(self, inputMode, metaData)
    return NoteSkinManager:setDefaultNoteSkin(inputMode, metaData)
end

NoteSkinModel.getNoteSkinMetaData = function(self, noteChart)
    return NoteSkinManager:getMetaData(noteChart.inputMode)
end

NoteSkinModel.getNoteSkin = function(self, noteSkinMetaData)
    return NoteSkinLoader:load(noteSkinMetaData)
end

return NoteSkinModel
