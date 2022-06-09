local Class = require("aqua.util.Class")

local SequenceView = Class:new()

local function getConfigs(configs)
	for _, config in ipairs(configs) do
		if #config == 0 then
			coroutine.yield(config)
		else
			getConfigs(config)
		end
	end
end

local noViews = function() end

SequenceView.construct = function(self)
	self.views = {}
	self.sequenceConfig = {}
	self.states = {}

	self.viewIterator = self:newViewIterator(true)
	self.loadViewIterator = self:newViewIterator(false)

	self.abortViewIterator = false
end

SequenceView.setSequenceConfig = function(self, config)
	self.sequenceConfig = config
	self:createStates(config)
end

SequenceView.createStates = function(self, config)
	local states = self.states
	for _, subConfig in ipairs(config) do
		if #subConfig == 0 then
			states[subConfig] = {}
		else
			self:createStates(subConfig)
		end
	end
end

SequenceView.clone = function(self)
	local sequenceView = SequenceView:new()
	for viewClass, view in pairs(self.views) do
		sequenceView:setView(viewClass, view)
	end
	return sequenceView
end

SequenceView.setView = function(self, viewClass, view)
	self.views[viewClass] = view
end

SequenceView.getView = function(self, config)
	local state = self.states[config]
	local view = self.views[config.class]
	if not view and self.sequenceView then
		view = self.sequenceView.views[config.class]
	end
	if view and state then
		view.config = config
		view.state = state
		view.sequenceView = self
		return view
	end
end

SequenceView.getState = function(self, config)
	return self.states[config]
end

SequenceView.newViewIterator = function(self, skipHidden, stop)
	local co = coroutine.create(function()
		while true do
			getConfigs(self.sequenceConfig)
			coroutine.yield()
		end
	end)

	return function()
		while true do
			local _, config = coroutine.resume(co)
			if not config then
				if stop then stop() end
				return
			end
			local view = self:getView(config)
			if view and (not skipHidden or not view.state.hidden) then
				return view
			end
		end
	end
end

SequenceView.load = function(self)
	for view in self.loadViewIterator do
		if view.load then view:load() end
	end
end

SequenceView.unload = function(self)
	for view in self.loadViewIterator do
		if view.unload then view:unload() end
	end
end

SequenceView.receive = function(self, event)
	if self.iterating then
		return
	end
	self.iterating = true
	for view in self.viewIterator do
		if view.receive then view:receive(event) end
		if self.abortViewIterator then break end
	end
	self.abortViewIterator = false
	self.iterating = false
end

SequenceView.update = function(self, dt)
	if self.iterating then
		return
	end
	self.iterating = true
	for view in self.viewIterator do
		if view.update then view:update(dt) end
		if self.abortViewIterator then break end
	end
	self.abortViewIterator = false
	self.iterating = false
end

SequenceView.draw = function(self)
	if self.iterating then
		return
	end
	self.iterating = true
	for view in self.viewIterator do
		if view.config.beforeDraw then view.config.beforeDraw(view) end
		if view.draw then view:draw() end
		if self.abortViewIterator then break end
	end
	self.abortViewIterator = false
	self.iterating = false
end

return SequenceView
