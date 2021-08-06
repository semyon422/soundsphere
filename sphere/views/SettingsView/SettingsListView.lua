local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local SettingsListItemSwitchView = require(viewspackage .. "SettingsView.SettingsListItemSwitchView")
local SettingsListItemSliderView = require(viewspackage .. "SettingsView.SettingsListItemSliderView")
local SettingsListItemStepperView = require(viewspackage .. "SettingsView.SettingsListItemStepperView")
local SettingsListItemInputView = require(viewspackage .. "SettingsView.SettingsListItemInputView")
local Slider = require(viewspackage .. "Slider")
local Switch = require(viewspackage .. "Switch")
local Stepper = require(viewspackage .. "Stepper")
local transform = require("aqua.graphics.transform")

local SettingsListView = ListView:new()

SettingsListView.construct = function(self)
	ListView.construct(self)

	self.itemSwitchView = SettingsListItemSwitchView:new()
	self.itemSliderView = SettingsListItemSliderView:new()
	self.itemStepperView = SettingsListItemStepperView:new()
	self.itemInputView = SettingsListItemInputView:new()
	self.itemSwitchView.listView = self
	self.itemSliderView.listView = self
	self.itemStepperView.listView = self
	self.itemInputView.listView = self

	self.slider = Slider:new()
	self.switch = Switch:new()
	self.stepper = Stepper:new()
end

SettingsListView.load = function(self)
	ListView.load(self)
	self.state.activeItem = self.state.selectedItem
end

SettingsListView.getItemView = function(self, settingConfig)
	if settingConfig.type == "slider" or settingConfig.type == "listSwitcher" then
		return self.itemSliderView
	elseif settingConfig.type == "switch" then
		return self.itemSwitchView
	elseif settingConfig.type == "binding" then
		return self.itemInputView
	elseif settingConfig.type == "stepper" then
		return self.itemStepperView
	end
end

SettingsListView.reloadItems = function(self)
	self.state.items = self.settingsModel.sections[self.navigator.sectionItemIndex]
    self.state.sectionName = self.settingsModel.sections[self.navigator.sectionItemIndex][1].section
end

SettingsListView.getItemIndex = function(self)
	return self.navigator.settingItemIndex
end

SettingsListView.scrollUp = function(self)
	self.navigator:scrollSettings("up")
end

SettingsListView.scrollDown = function(self)
	self.navigator:scrollSettings("down")
end

SettingsListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

SettingsListView.wheelmoved = function(self, event)
	local config = self.config

	local tf = transform(config.transform)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())
	local sx = config.x + config.scroll.x
	local sy = config.y + config.scroll.y
	local sw = config.scroll.w
	local sh = config.scroll.h

	if mx >= sx and mx < sx + sw and my >= sy and my < sy + sh then
		local wy = event.args[2]
		if wy == 1 then
			self:scrollUp()
		elseif wy == -1 then
			self:scrollDown()
		end
		return
	end

	local x = config.x
	local y = config.y
	local w = config.w
	local h = config.h

	if mx >= x and mx < x + w and my >= y and my < y + h then
		self:receiveItems(event)
	end
end

return SettingsListView
