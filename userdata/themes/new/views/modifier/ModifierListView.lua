local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local ModifierListItemSwitchView = require(viewspackage .. "modifier.ModifierListItemSwitchView")
local ModifierListItemSliderView = require(viewspackage .. "modifier.ModifierListItemSliderView")
local Slider = require(viewspackage .. "Slider")
local Switch = require(viewspackage .. "Switch")

local ModifierListView = ListView:new()

ModifierListView.init = function(self)
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = -16 / 9 / 3 / 4
	self.y = 0
	self.w = 16 / 9 / 3
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1

	self:reloadItems()

	self.slider = Slider:new()
	self.switch = Switch:new()

	self:on("update", function()
		self.selectedItem = self.navigator.modifierList.selected
		self:reloadItems()
	end)
	self:on("select", function()
		self.navigator:setNode("modifierList")
		self.view.selectedNode = self
	end)
	self:on("draw", self.drawFrame)
	self:on("wheelmoved", self.receive)
	self:on("mousepressed", self.receive)
	self:on("mousereleased", self.receive)
	self:on("mousemoved", self.receive)

	self:on("wheelmoved", function(self, event)
		local mx, my = love.mouse.getPosition()
		local cs = self.cs
		local x = cs:X(self.x, true)
		local w = cs:X(self.w)
		if mx >= x and mx < x + w / 2 then
			local wy = event.args[2]
			if wy == 1 then
				self.navigator:call("up")
			elseif wy == -1 then
				self.navigator:call("down")
			end
		end
	end)
	self:on("mousepressed", function(self, event)
		local mx = event.args[1]
		local my = event.args[2]
		local cs = self.cs
		local x = cs:X(self.x, true)
		local w = cs:X(self.w)
		local button = event.args[3]
		if button == 1 then
			if mx >= x + w then
				self.navigator:call("return")
			end
		elseif button == 2 then
			self.navigator:call("backspace")
		end
	end)

	ListView.init(self)
end

ModifierListView.createListItemViews = function(self)
	local switchView = ModifierListItemSwitchView:new()
	switchView.listView = self
	switchView:init()
	self.listItemSwitchView = switchView

	local sliderView = ModifierListItemSliderView:new()
	sliderView.listView = self
	sliderView:init()
	self.listItemSliderView = sliderView
end

ModifierListView.getListItemView = function(self, modifierConfig)
	local modifier = self.view.modifierModel:getModifier(modifierConfig)
	if modifier.range[1] == 0 and modifier.range[2] == 1 then
		return self.listItemSwitchView
	else
		return self.listItemSliderView
	end
end

ModifierListView.reloadItems = function(self)
	self.items = self.view.configModel:getConfig("modifier")
end

ModifierListView.drawFrame = function(self)
	if self.navigator:checkNode("modifierList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return ModifierListView
