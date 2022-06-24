local transform = require("aqua.graphics.transform")
local ListView = require("sphere.views.ListView")
local ModifierListItemSwitchView = require("sphere.views.ModifierView.ModifierListItemSwitchView")
local ModifierListItemSliderView = require("sphere.views.ModifierView.ModifierListItemSliderView")
local ModifierListItemStepperView = require("sphere.views.ModifierView.ModifierListItemStepperView")
local Slider = require("sphere.views.Slider")
local Switch = require("sphere.views.Switch")
local Stepper = require("sphere.views.Stepper")

local ModifierListView = ListView:new({construct = false})

ModifierListView.construct = function(self)
	ListView.construct(self)

	self.itemSwitchView = ModifierListItemSwitchView:new()
	self.itemSliderView = ModifierListItemSliderView:new()
	self.itemStepperView = ModifierListItemStepperView:new()
	self.itemSwitchView.listView = self
	self.itemSliderView.listView = self
	self.itemStepperView.listView = self

	self.sliderObject = Slider:new()
	self.switchObject = Switch:new()
	self.stepperObject = Stepper:new()
end

ModifierListView.load = function(self)
	ListView.load(self)
	self.activeItem = self.selectedItem
end

ModifierListView.getItemView = function(self, modifierConfig)
	local modifier = self.game.modifierModel:getModifier(modifierConfig)
	if modifier.interfaceType == "toggle" then
		return self.itemSwitchView
	elseif modifier.interfaceType == "slider" then
		return self.itemSliderView
	elseif modifier.interfaceType == "stepper" then
		return self.itemStepperView
	end
end

ModifierListView.reloadItems = function(self)
	self.items = self.game.modifierModel.config
end

ModifierListView.getItemIndex = function(self)
	return self.game.modifierModel.modifierItemIndex
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
	local tf = transform(self.transform)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	local sx = self.x + self.scroll.x
	local sy = self.y + self.scroll.y
	local sw = self.scroll.w
	local sh = self.scroll.h

	if mx >= sx and mx < sx + sw and my >= sy and my < sy + sh then
		local wy = event[2]
		if wy == 1 then
			self:scrollUp()
		elseif wy == -1 then
			self:scrollDown()
		end
		return
	end

	local x = self.x
	local y = self.y
	local w = self.w
	local h = self.h

	if mx >= x and mx < x + w and my >= y and my < y + h then
		self:receiveItems(event)
	end
end

return ModifierListView
