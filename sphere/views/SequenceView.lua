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

SequenceView.getViewIterator = function(self)
	local configs = self.config
	local index = 1

	return function()
		for i = index, #configs do
			local config = configs[i]
			local view = self:getView(config.class)
			if view then
				view.config = config
				view.state = self.states[config]
				index = i + 1
				return view
			end
		end
	end
end

SequenceView.load = function(self)
	for view in self:getViewIterator() do
		view:load()
	end
end

SequenceView.unload = function(self)
	for view in self:getViewIterator() do
		view:unload()
	end
end

SequenceView.receive = function(self, event)
	for view in self:getViewIterator() do
		view:receive(event)
	end
end

SequenceView.update = function(self, dt)
	for view in self:getViewIterator() do
		view:update(dt)
	end
end

SequenceView.draw = function(self)
	for view in self:getViewIterator() do
		view:draw()
	end
end

return SequenceView
