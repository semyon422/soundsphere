local Class = require("aqua.util.Class")

local SequenceView = Class:new()

SequenceView.construct = function(self)
	self.views = {}
	self.config = {}
	self.states = {}
end

SequenceView.setSequenceConfig = function(self, config)
	self.config = config
	self:initStates()
end

SequenceView.initStates = function(self)
	local states = self.states
	for _, config in ipairs(self.config) do
		states[config] = {}
	end
end

SequenceView.setView = function(self, viewClass, view)
	self.views[viewClass] = view
end

SequenceView.getView = function(self, viewClass)
	return self.views[viewClass]
end

SequenceView.load = function(self)
	for _, config in ipairs(self.config) do
		local view = self:getView(config.class)
		if view then
			view.config = config
			view.state = self.states[config]
			view:load()
		end
	end
end

SequenceView.draw = function(self)
	for _, config in ipairs(self.config) do
		local view = self:getView(config.class)
		if view then
			view.config = config
			view.state = self.states[config]
			view:draw()
		end
	end
end

return SequenceView
