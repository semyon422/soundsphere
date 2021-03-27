local Class = require("aqua.util.Class")

local SequenceView = Class:new()

SequenceView.construct = function(self)
    self.views = {}
    self.config = {}
end

SequenceView.setSequenceConfig = function(self, config)
    self.config = config
end

SequenceView.setView = function(self, viewClass, view)
    self.views[viewClass] = view
end

SequenceView.getView = function(self, viewClass)
    return self.views[viewClass]
end

SequenceView.draw = function(self)
    for _, config in ipairs(self.config) do
        local view = self:getView(config.class)
        if view then
            view.config = config
            view:draw()
        end
    end
end

return SequenceView
