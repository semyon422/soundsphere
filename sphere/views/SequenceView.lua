local class = require("class")

local SequenceView = class()

local function getViews(views, out)
	out = out or {}
	for _, view in ipairs(views) do
		if #view == 0 or type(view[1]) ~= "table" then
			table.insert(out, view)
		else
			getViews(view, out)
		end
	end
	return out
end

function SequenceView:setSequenceConfig(config)
	self.views = getViews(config)
	self.viewById = {}
	for _, view in ipairs(self.views) do
		view.sequenceView = self
		view.game = self.game
		view.screenView = self.screenView
		if view.id then
			self.viewById[view.id] = view
		end
	end
end

function SequenceView:load()
	if self.iterating then
		self.abortIterating = true
	end
	for _, view in ipairs(self.views) do
		if view.load then view:load() end
	end
end

function SequenceView:unload()
	if self.iterating then
		self.abortIterating = true
	end
	for _, view in ipairs(self.views) do
		if view.unload then view:unload() end
	end
end

function SequenceView:callMethod(method, ...)
	if self.iterating then
		return
	end
	self.iterating = true
	local subscreen = self.subscreen
	for _, view in ipairs(self.views) do
		if view[method] and not view.hidden and (not view.subscreen or subscreen == view.subscreen) then
			view[method](view, ...)
		end
		if self.abortIterating then break end
	end
	self.abortIterating = false
	self.iterating = false
end

function SequenceView:receive(event)
	self:callMethod("receive", event)
end

function SequenceView:update(dt)
	self:callMethod("update", dt)
end

function SequenceView:draw()
	self:callMethod("draw")
end

return SequenceView
