local viewspackage = (...):match("^(.-%.views%.)")

local transform = require("aqua.graphics.transform")
local ListView = require(viewspackage .. "ListView")
local ModifierListItemSwitchView = require(viewspackage .. "ModifierView.ModifierListItemSwitchView")
local ModifierListItemSliderView = require(viewspackage .. "ModifierView.ModifierListItemSliderView")
local ModifierListItemStepperView = require(viewspackage .. "ModifierView.ModifierListItemStepperView")
local Slider = require(viewspackage .. "Slider")
local Switch = require(viewspackage .. "Switch")
local Stepper = require(viewspackage .. "Stepper")

local ModifierListView = ListView:new({construct = false})

ModifierListView.construct = function(self)
	ListView.construct(self)

	self.itemSwitchView = ModifierListItemSwitchView:new()
	self.itemSliderView = ModifierListItemSliderView:new()
	self.itemStepperView = ModifierListItemStepperView:new()
	self.itemSwitchView.listView = self
	self.itemSliderView.listView = self
	self.itemStepperView.listView = self

	self.slider = Slider:new()
	self.switch = Switch:new()
	self.stepper = Stepper:new()
end

ModifierListView.load = function(self)
	ListView.load(self)
	self.state.activeItem = self.state.selectedItem
end

ModifierListView.getItemView = function(self, modifierConfig)
	local modifier = self.modifierModel:getModifier(modifierConfig)
	if modifier.interfaceType == "toggle" then
		return self.itemSwitchView
	elseif modifier.interfaceType == "slider" then
		return self.itemSliderView
	elseif modifier.interfaceType == "stepper" then
		return self.itemStepperView
	end
end

ModifierListView.reloadItems = function(self)
	self.state.items = self.modifierModel.config
end

ModifierListView.getItemIndex = function(self)
	return self.modifierModel.modifierItemIndex
end

ModifierListView.scrollUp = function(self)
	self.navigator:scrollModifier("up")
end

ModifierListView.scrollDown = function(self)
	self.navigator:scrollModifier("down")
end

ModifierListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

ModifierListView.wheelmoved = function(self, event)
	local config = self.config

	local tf = transform(config.transform)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())
	tf:release()

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

return ModifierListView
