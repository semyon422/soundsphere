
local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local SettingsListItemView = require(viewspackage .. "SettingsView.SettingsListItemView")
local SwitchView = require(viewspackage .. "SwitchView")

local SettingsListItemInputView = SettingsListItemView:new()

SettingsListItemInputView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

	self.switchView = SwitchView:new()
end

SettingsListItemInputView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.index + listView.selectedItem - math.ceil(listView.itemCount / 2)
	local item = self.item

	local cs = listView.cs

	local x, y, w, h = self:getPosition()

	local settingConfig = item
	-- local modifier = listView.view.modifierModel:getSettings(modifierConfig)
	-- local realValue = modifier:getRealValue(modifierConfig)

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
	love.graphics.printf(
		listView.view.settingsModel:getValue(settingConfig),
		x + w / 2,
		y,
		w / 2 / cs.one * 1080,
		"center",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(0 / cs.one),
		-cs:Y(18 / cs.one)
	)
end

SettingsListItemInputView.receive = function(self, event)
	SettingsListItemView.receive(self, event)

	local listView = self.listView

	local navigator = self.listView.navigator
	if
		not navigator:checkNode("inputHandler") and
		event.name == "keypressed" and event.args[1] == "return"
	then
		navigator.inputHandler.settingConfig = nil
		navigator:setNode("inputHandler")
		return
	end

	if event.name ~= "mousepressed" then
		return
	end

	local x, y, w, h = self:getPosition()

	local mx, my = love.mouse.getPosition()

	if event.name == "mousepressed" and (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		listView.activeItem = self.itemIndex
		local button = event.args[3]
		if button == 1 then
			navigator.inputHandler.settingConfig = self.item
			self.listView.navigator:setNode("inputHandler")
		end
	end
end

return SettingsListItemInputView
