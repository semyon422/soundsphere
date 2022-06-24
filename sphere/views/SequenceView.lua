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

SequenceView.setSequenceConfig = function(self, config)
	self.views = getViews(config)
	for _, view in ipairs(self.views) do
		view.sequenceView = self
		view.game = self.game
		view.navigator = self.navigator
	end
end

SequenceView.load = function(self)
	if self.iterating then
		self.abortIterating = true
	end
	for _, view in ipairs(self.views) do
		if view.load then view:load() end
	end
end

SequenceView.unload = function(self)
	if self.iterating then
		self.abortIterating = true
	end
	for _, view in ipairs(self.views) do
		if view.unload then view:unload() end
	end
end

SequenceView.callMethod = function(self, method, ...)
	if self.iterating then
		return
	end
	self.iterating = true
	for _, view in ipairs(self.views) do
		if not view.hidden and view[method] then
			view[method](view, ...)
		end
		if self.abortIterating then break end
	end
	self.abortIterating = false
	self.iterating = false
end

SequenceView.receive = function(self, event)
	self:callMethod("receive", event)
end

SequenceView.update = function(self, dt)
	self:callMethod("update", dt)
end

SequenceView.draw = function(self)
	self:callMethod("beforeDraw")
	self:callMethod("draw")
end

return SequenceView
