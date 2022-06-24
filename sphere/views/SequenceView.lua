local Class = require("aqua.util.Class")

local SequenceView = Class:new()

local function getViews(views, out)
	out = out or {}
	for _, view in ipairs(views) do
		if #view == 0 then
			table.insert(out, view)
		else
			getViews(view, out)
		end
	end
	return out
end

SequenceView.construct = function(self)
	self.views = {}
	self.abortIterating = false
end

SequenceView.setSequenceConfig = function(self, config)
	self.views = getViews(config)
	for _, view in ipairs(self.views) do
		view.sequenceView = self
		view.game = self.game
		view.navigator = self.navigator
	end
end

SequenceView.load = function(self)
	self.abortIterating = true
	for _, view in ipairs(self.views) do
		if view.load then view:load() end
	end
end

SequenceView.unload = function(self)
	self.abortIterating = true
	for _, view in ipairs(self.views) do
		if view.unload then view:unload() end
	end
end

SequenceView.receive = function(self, event)
	if self.iterating then
		return
	end
	self.iterating = true
	for _, view in ipairs(self.views) do
		if view.receive and not view.hidden then view:receive(event) end
		if self.abortIterating then break end
	end
	self.abortIterating = false
	self.iterating = false
end

SequenceView.update = function(self, dt)
	if self.iterating then
		return
	end
	self.iterating = true
	for _, view in ipairs(self.views) do
		if view.update and not view.hidden then view:update(dt) end
		if self.abortIterating then break end
	end
	self.abortIterating = false
	self.iterating = false
end

SequenceView.draw = function(self)
	if self.iterating then
		return
	end
	self.iterating = true
	for _, view in ipairs(self.views) do
		if view.beforeDraw and not view.hidden then view:beforeDraw() end
		if view.draw and not view.hidden then view:draw() end
		if self.abortIterating then break end
	end
	self.abortIterating = false
	self.iterating = false
end

return SequenceView
