local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local SettingsListItemView = require(viewspackage .. "settings.SettingsListItemView")
local SwitchView = require(viewspackage .. "SwitchView")

local SettingsListItemSwitchView = SettingsListItemView:new()

SettingsListItemSwitchView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

	self.switchView = SwitchView:new()
end

SettingsListItemSwitchView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.index + listView.selectedItem - math.ceil(listView.itemCount / 2)
	local item = self.item

	local cs = listView.cs

	local x, y, w, h = self:getPosition()

    local settingConfig = item

	local deltaItemIndex = math.abs(itemIndex - listView.selectedItem)
	if listView.isSelected then
		love.graphics.setColor(1, 1, 1,
			deltaItemIndex == 0 and 1 or 0.66
		)
	else
		love.graphics.setColor(1, 1, 1, 0.33)
	end

	love.graphics.setFont(self.fontName)
	love.graphics.printf(
		settingConfig.name,
		x,
		y,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(0 / cs.one),
		-cs:Y(18 / cs.one)
	)

	local switchView = self.switchView
	switchView:setPosition(x + 3 * w / 4 - h / 2, y, h, h)
	-- switchView:setValue(modifier:getNormalizedValue(modifierConfig))
	switchView:setValue(1)
	switchView:draw()
end

SettingsListItemSwitchView.receive = function(self, event)
	SettingsListItemView.receive(self, event)

	if event.name ~= "mousepressed" then
		return
	end

	local listView = self.listView

	local x, y, w, h = self:getPosition()

	local switch = listView.switch
	-- local modifierConfig = self.item
	-- local modifier = listView.view.modifierModel:getSettings(modifierConfig)
	switch:setPosition(x + 3 * w / 4 - h / 2, y, h, h)
	-- switch:setValue(modifier:getRealValue(modifierConfig))
	switch:setValue(1)
	switch:receive(event)

	if switch.valueUpdated then
		if switch.value == 0 then
			self.listView.navigator:call("left", self.itemIndex)
		else
			self.listView.navigator:call("right", self.itemIndex)
		end
		switch.valueUpdated = false
	end
end

return SettingsListItemSwitchView
