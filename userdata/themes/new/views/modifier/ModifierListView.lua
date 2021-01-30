local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local ModifierListItemView = require(viewspackage .. "modifier.ModifierListItemView")
local ModifierListItemSwitchView = require(viewspackage .. "modifier.ModifierListItemSwitchView")
local ModifierListItemSliderView = require(viewspackage .. "modifier.ModifierListItemSliderView")

local ModifierListView = ListView:new()

ModifierListView.init = function(self)
	self.ListItemView = ModifierListItemView
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = 0
	self.y = 0
	self.w = 16 / 9 / 3
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.modifierList.selected
		self:reloadItems()
	end)
	self:on("select", function()
		self.navigator:setNode("modifierList")
		self.view.selectedNode = self
	end)
	self:on("draw", self.drawFrame)

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
