local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local ModifierListItemSwitchView = require(viewspackage .. "ModifierView.ModifierListItemSwitchView")
local ModifierListItemSliderView = require(viewspackage .. "ModifierView.ModifierListItemSliderView")
local ModifierListItemStepperView = require(viewspackage .. "ModifierView.ModifierListItemStepperView")
local Slider = require(viewspackage .. "Slider")
local Switch = require(viewspackage .. "Switch")
local Stepper = require(viewspackage .. "Stepper")

local ModifierListView = ListView:new()

ModifierListView.construct = function(self)
	ListView.construct(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")

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
	self.state.items = self.configModifier
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

ModifierListView.receiveItems = function(self, event)
	local state = self.state
	local config = self.config

	local deltaItemIndex = state.selectedItem - state.selectedVisualItem
	for i = 0 - math.floor(deltaItemIndex), config.rows - math.floor(deltaItemIndex) do
		local itemIndex = i + state.selectedItem - math.ceil(config.rows / 2)
		local visualIndex = i + deltaItemIndex
		local item = state.items[itemIndex]
		if item then
			local itemView = self:getItemView(item)
			itemView.visualIndex = visualIndex
			itemView.itemIndex = itemIndex
			itemView.item = item
			itemView.listView = self
			itemView.prevItem = state.items[itemIndex - 1]
			itemView.nextItem = state.items[itemIndex + 1]
			itemView:receive(event)
		end
	end
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
	local cs = self.cs

	local mx, my = love.mouse.getPosition()
	local sx = cs:X((config.x + config.scroll.x) / config.screen.h, true)
	local sy = cs:Y((config.y + config.scroll.y) / config.screen.h, true)
	local sw = cs:X(config.scroll.w / config.screen.h)
	local sh = cs:Y(config.scroll.h / config.screen.h)

	if mx >= sx and mx < sx + sw and my >= sy and my < sy + sh then
		local wy = event.args[2]
		if wy == 1 then
			self:scrollUp()
		elseif wy == -1 then
			self:scrollDown()
		end
		return
	end

	local x = cs:X(config.x / config.screen.h, true)
	local y = cs:Y(config.y / config.screen.h, true)
	local w = cs:X(config.w / config.screen.h)
	local h = cs:Y(config.h / config.screen.h)

	if mx >= x and mx < x + w and my >= y and my < y + h then
		self:receiveItems(event)
	end
end

return ModifierListView
