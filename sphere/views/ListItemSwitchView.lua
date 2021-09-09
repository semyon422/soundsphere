local viewspackage = (...):match("^(.-%.views%.)")

local ListItemView = require(viewspackage .. "ListItemView")
local ListItemSliderView = require(viewspackage .. "ListItemSliderView")
local SwitchView = require(viewspackage .. "SwitchView")
local transform = require("aqua.graphics.transform")

local ListItemSwitchView = ListItemView:new({construct = false})

ListItemSwitchView.construct = function(self)
	ListItemView.construct(self)
	self.switchView = SwitchView:new()
end

ListItemSwitchView.getName = function(self) end
ListItemSwitchView.getValue = function(self) end
ListItemSwitchView.setValue = function(self, delta) end

ListItemSwitchView.draw = function(self)
	ListItemView.draw(self)

	local config = self.listView.config
	self:drawValue(config.name, self:getName())

	local switchView = self.switchView
	switchView:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.switch))
	switchView:setValue(self:getValue())
	switchView:draw()
end

ListItemSwitchView.receive = function(self, event)
	ListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name ~= "mousepressed" then
		return
	end

	local listView = self.listView

	local config = listView.config
	local switch = listView.switch
	switch:setTransform(transform(config.transform):clone():translate(config.x, config.y))
	switch:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.switch))
	switch:setValue(self:getValue())
	switch:receive(event)

	if switch.valueUpdated then
		self:setValue(switch.value)
		switch.valueUpdated = false
	end
end

ListItemSwitchView.increaseValue = function(self, delta)
	if delta == 1 then
		self:setValue(true)
	elseif delta == -1 then
		self:setValue(false)
	end
end

ListItemSwitchView.wheelmoved = ListItemSliderView.wheelmoved

return ListItemSwitchView
