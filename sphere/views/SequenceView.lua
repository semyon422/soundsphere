local Class = require("aqua.util.Class")

local SequenceView = Class:new()

SequenceView.construct = function(self)
	self.views = {}
	self.config = {}
	self.states = {}
end

SequenceView.setSequenceConfig = function(self, config)
	self.config = config
	local states = self.states
	for _, subConfig in ipairs(config) do
		states[subConfig] = {}
	end
end

SequenceView.setView = function(self, viewClass, view)
	self.views[viewClass] = view
end

SequenceView.getView = function(self, viewClass)
	return self.views[viewClass]
end

SequenceView.getState = function(self, config)
	return self.states[config]
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
				view.state = self:getState(config)
				view.sequenceView = self
				index = i + 1
				return view
			end
		end
	end
end

SequenceView.load = function(self)
	for view in self:getViewIterator() do
		if view.load then view:load() end
	end
end

SequenceView.unload = function(self)
	for view in self:getViewIterator() do
		if view.unload then view:unload() end
	end
end

SequenceView.receive = function(self, event)
	for view in self:getViewIterator() do
		if view.receive then view:receive(event) end
	end
end

SequenceView.update = function(self, dt)
	for view in self:getViewIterator() do
		if view.update then view:update(dt) end
	end
end

SequenceView.draw = function(self)
	for view in self:getViewIterator() do
		if view.draw then view:draw() end
	end
end

return SequenceView