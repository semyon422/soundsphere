local viewspackage = (...):match("^(.-%.views%.)")

local ModifierListItemView = require(viewspackage .. "ModifierView.ModifierListItemView")
local SwitchView = require(viewspackage .. "SwitchView")

local ModifierListItemSwitchView = ModifierListItemView:new()

ModifierListItemSwitchView.construct = function(self)
	self.switchView = SwitchView:new()
end

ModifierListItemSwitchView.draw = function(self)
	local modifierConfig = self.item

	ModifierListItemView.draw(self)

	local config = self.listView.config
	local switchView = self.switchView
	switchView:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.switch))
	switchView:setValue(modifierConfig.value)
	switchView:draw()
end

ModifierListItemSwitchView.receive = function(self, event)
	ModifierListItemView.receive(self, event)

	if event.name ~= "mousepressed" then
		return
	end

	local listView = self.listView

	local config = listView.config
	local switch = listView.switch
	local modifierConfig = self.item
	switch:setPosition(self.listView:getItemElementPosition(self.itemIndex, config.slider))
	switch:setValue(modifierConfig.value)
	switch:receive(event)

	if switch.valueUpdated then
		if switch.value == 0 then
			self.listView.navigator:increaseModifierValue(self.itemIndex, -1)
		else
			self.listView.navigator:increaseModifierValue(self.itemIndex, 1)
		end
		switch.valueUpdated = false
	end
end

return ModifierListItemSwitchView
