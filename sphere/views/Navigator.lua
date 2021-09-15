
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")

local Navigator = Class:new()

Navigator.construct = function(self)
	self.observable = Observable:new()
	self.subscreens = {}
end

Navigator.load = function(self)
	self.observable:add(self.view.controller)
	self:setHidden(nil, true, true)
end

Navigator.unload = function(self)
	self.observable:remove(self.view.controller)
end

Navigator.update = function(self) end

Navigator.send = function(self, event)
	return self.observable:send(event)
end

Navigator.receive = function(self, event) end

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
	if n ~= 1 then
		local last = subscreens[n]
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
	local sequenceView = self.sequenceView
	for _, config in ipairs(self.viewConfig) do
		if not other and config.subscreen == subscreen or other and config.subscreen ~= subscreen then
			local state = sequenceView:getState(config)
			state.hidden = value
		end
	end
end

return Navigator
