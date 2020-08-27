local Class = require("aqua.util.Class")

local ConfigController = Class:new()

ConfigController.receive = function(self, event)
    if event.name ~= "ConfigModel.setValue" then
        return
    end

    self.configModel:set(event.key, event.value)
end

return ConfigController
