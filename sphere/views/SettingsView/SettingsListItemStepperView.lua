local viewspackage = (...):match("^(.-%.views%.)")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local SettingsListItemView = require(viewspackage .. "SettingsView.SettingsListItemView")
local StepperView = require(viewspackage .. "StepperView")

local SettingsListItemStepperView = SettingsListItemView:new()

SettingsListItemStepperView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

	self.stepperView = StepperView:new()
end

SettingsListItemStepperView.draw = function(self)
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

	local value = listView.view.settingsModel:getValue(settingConfig)

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
		settingConfig.displayValues[value],
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

	local stepperView = self.stepperView
	stepperView:setPosition(x + w / 2, y, w / 2, h)
	stepperView:setValue(value)
	stepperView:setCount(#settingConfig.values)
	stepperView:draw()
end

SettingsListItemStepperView.receive = function(self, event)
	SettingsListItemView.receive(self, event)

	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end

	if event.name ~= "mousepressed" then
		return
	end

	local listView = self.listView

	local x, y, w, h = self:getPosition()

	local settingConfig = self.item
	local value = listView.view.settingsModel:getValue(settingConfig)

	local stepper = listView.stepper
	stepper:setPosition(x + w / 2, y, w / 2, h)
	stepper:setValue(value)
	stepper:setCount(#settingConfig.values)
	stepper:receive(event)

	if stepper.valueUpdated then
		if stepper.value < value then
			self.listView.navigator:call("left", self.itemIndex)
		elseif stepper.value > value then
			self.listView.navigator:call("right", self.itemIndex)
		end
		stepper.valueUpdated = false
	end
end

SettingsListItemStepperView.wheelmoved = function(self, event)
	local x, y, w, h = self:getPosition()
	local mx, my = love.mouse.getPosition()

	if not (mx >= x and mx <= x + w and my >= y and my <= y + h) then
		return
	end

	if mx >= x + w * 0.5 and mx <= x + w then
		local wy = event.args[2]
		if wy == 1 then
			self.listView.navigator:call("right", self.itemIndex)
		elseif wy == -1 then
			self.listView.navigator:call("left", self.itemIndex)
		end
	end
end

return SettingsListItemStepperView
