local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local SettingsListItemSwitchView = require(viewspackage .. "settings.SettingsListItemSwitchView")
local SettingsListItemSliderView = require(viewspackage .. "settings.SettingsListItemSliderView")
local SettingsListItemInputView = require(viewspackage .. "settings.SettingsListItemInputView")
local Slider = require(viewspackage .. "Slider")
local Switch = require(viewspackage .. "Switch")

local SettingsListView = ListView:new()

SettingsListView.init = function(self)
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = -16 / 9 / 3 / 4
	self.y = 0
	self.w = 16 / 9 / 3
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1
	self.activeItem = self.selectedItem

	self:reloadItems()

	self.slider = Slider:new()
	self.switch = Switch:new()

	self:on("update", function()
		self.selectedItem = self.navigator.settingsList.selected
		self:reloadItems()
	end)
	self:on("select", function()
        if not self.navigator:checkNode("inputHandler") then
	    	self.navigator:setNode("settingsList")
        end
	end)
	self:on("draw", self.drawFrame)
	self:on("wheelmoved", self.receive)
	self:on("mousepressed", self.receive)
	self:on("mousereleased", self.receive)
	self:on("mousemoved", self.receive)
	self:on("keypressed", self.receive)

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

	ListView.init(self)
end

SettingsListView.createListItemViews = function(self)
	local switchView = SettingsListItemSwitchView:new()
	switchView.listView = self
	switchView:init()
	self.listItemSwitchView = switchView

	local sliderView = SettingsListItemSliderView:new()
	sliderView.listView = self
	sliderView:init()
	self.listItemSliderView = sliderView

	local inputView = SettingsListItemInputView:new()
	inputView.listView = self
	inputView:init()
	self.listItemInputView = inputView
end

SettingsListView.getListItemView = function(self, settingConfig)
	if settingConfig.type == "slider" or settingConfig.type == "listSwitcher" then
		return self.listItemSliderView
	elseif settingConfig.type == "checkbox" then
		return self.listItemSwitchView
	elseif settingConfig.type == "keybind" then
		return self.listItemInputView
	end
end

SettingsListView.reloadItems = function(self)
	self.items = self.config_settings_model[self.navigator.categoriesList.selected].items
    self.categoryName = self.config_settings_model[self.navigator.categoriesList.selected].name
end

SettingsListView.drawFrame = function(self)
	if self.navigator:checkNode("settingsList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return SettingsListView
