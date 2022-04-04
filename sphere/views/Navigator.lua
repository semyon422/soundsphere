
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local Queue = require("aqua.util.Queue")

local Navigator = Class:new()

Navigator.construct = function(self)
	self.observable = Observable:new()
	self.queue = Queue:new()
	self.subscreens = {}
end

Navigator.load = function(self)
	self.observable:add(self.view.controller)
	self.viewIterator = self.sequenceView:newViewIterator()
	self:setHidden(nil, true, true)
end

Navigator.unload = function(self)
	self.observable:remove(self.view.controller)
end

Navigator.update = function(self)
	for event in self.queue do
		self.observable:send(event)
	end
end

Navigator.send = function(self, event)
	return self.queue:add(event)
end

Navigator.receive = function(self, event) end

Navigator.call = function(self, method, value)
	if self[method] then
		self[method](self, value)
	end
end

Navigator.changeScreen = function(self, screenName)
	self:send({
		name = "changeScreen",
		screenName = screenName
	})
end

Navigator.resetSubscreens = function(self)
	self.subscreens = {}
	self:setHidden(nil, true, true)
end

Navigator.setSubscreen = function(self, subscreen)
	self:resetSubscreens()
	self:addSubscreen(subscreen)
end

Navigator.removeLessSubscreens = function(self, ...)
	local subscreens = self.subscreens
	local t = {...}

	local maxIndex = 0
	local maxSubscreen
	for _, subscreen in ipairs(t) do
		local index = subscreens[subscreen]
		if index and index > maxIndex then
			maxIndex = index
			maxSubscreen = subscreen
		end
	end
	for _, subscreen in ipairs(t) do
		if subscreen ~= maxSubscreen then
			self:removeSubscreen(subscreen)
		end
	end
end

Navigator.getSubscreen = function(self, subscreen)
	return self.subscreens[subscreen]
end

Navigator.addSubscreen = function(self, subscreen)
	local subscreens = self.subscreens
	if subscreens[subscreen] then
		return
	end
	table.insert(subscreens, subscreen)
	subscreens[subscreen] = #subscreens
	self:setHidden(subscreen, false)
end

Navigator.removeSubscreen = function(self, subscreen)
	local subscreens = self.subscreens
	if not subscreens[subscreen] then
		return
	end
	local i = subscreens[subscreen]
	local n = #subscreens
	subscreens[subscreen] = nil
	subscreens[i] = nil
	local last = subscreens[n]
	if last then
		subscreens[i] = last
		subscreens[last] = i
		subscreens[n] = nil
	end
	self:setHidden(subscreen, true)
end

Navigator.switchSubscreen = function(self, subscreen)
	local subscreens = self.subscreens
	if subscreens[subscreen] then
		return self:removeSubscreen(subscreen)
	end
	self:addSubscreen(subscreen)
end

Navigator.setHidden = function(self, subscreen, value, other)
	for view in self.viewIterator do
		local config = view.config
		local state = view.state
		if not other and config.subscreen == subscreen or other and config.subscreen ~= subscreen then
			state.hidden = value
		end
	end
end

return Navigator
