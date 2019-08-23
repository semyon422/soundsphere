local aquafonts		= require("aqua.assets.fonts")
local TextFrame		= require("aqua.graphics.TextFrame")
local map			= require("aqua.math").map
local spherefonts	= require("sphere.assets.fonts")
local Config		= require("sphere.config.Config")
local Checkbox		= require("sphere.ui.Checkbox")
local CustomList	= require("sphere.ui.CustomList")
local Slider		= require("sphere.ui.Slider")

local SettingsListButton = CustomList.Button:new()

SettingsListButton.nameTextAlign = {x = "left", y = "center"}
SettingsListButton.valueTextAlign = {x = "left", y = "center"}

SettingsListButton.columnX = {0, 0.4, 0.6}
SettingsListButton.columnWidth = {0.4, 0.2, 0.4}

SettingsListButton.sliderRectangleColor = {63, 63, 63, 255}
SettingsListButton.sliderCircleColor = {255, 255, 255, 255}
SettingsListButton.sliderCircleLineColor = {255, 255, 255, 255}

SettingsListButton.construct = function(self)
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	
	self.nameTextFrame = TextFrame:new()
	self.valueTextFrame = TextFrame:new()
	
	if self.item.type == "slider" then
		self.slider = Slider:new()
		self.slider.item = self.item
		self.slider.observable:add(self)
	elseif self.item.type == "checkbox" then
		self.checkbox = Checkbox:new()
		self.checkbox.item = self.item
		self.checkbox.observable:add(self)
	end
	
	CustomList.Button.construct(self)
end

SettingsListButton.reload = function(self)
	if self.item.type == "slider" then
		local slider = self.slider
		
		slider.x = self.x + self.w * self.columnX[3]
		slider.y = self.y
		slider.w = self.w * self.columnWidth[3]
		slider.h = self.h
		slider.barHeight = self.h / 2
		slider.rectangleColor = self.sliderRectangleColor
		slider.circleColor = self.sliderCircleColor
		slider.cs = self.cs
		slider.value = Config:get(self.item.configKey)
		
		slider:reload()
	elseif self.item.type == "checkbox" then
		local checkbox = self.checkbox
		
		checkbox.x = self.x + self.w * self.columnX[3]
		checkbox.y = self.y
		checkbox.w = self.w * self.columnWidth[3]
		checkbox.h = self.h
		checkbox.cs = self.cs
		checkbox.value = Config:get(self.item.configKey)
		
		checkbox:reload()
	end
	
	local textFrame = self.nameTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[1]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[1]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[1]
	textFrame.align = self.nameTextAlign
	textFrame.text = self.item.name
	textFrame.font = self.font
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
	
	local textFrame = self.valueTextFrame
	
	textFrame.x = self.x + self.w * self.columnX[2]
	textFrame.y = self.y
	textFrame.w = self.w * self.columnWidth[2]
	textFrame.h = self.h
	textFrame.limit = self.w * self.columnWidth[2]
	textFrame.align = self.valueTextAlign
	textFrame.text = self:getDisplayValue()
	textFrame.font = self.font
	textFrame.color = self.textColor
	textFrame.cs = self.cs
	
	textFrame:reload()
end

SettingsListButton.receive = function(self, event)
	if event.name == "pressed" then
		return
	elseif event.name == "released" then
		return
	elseif event.name == "valueChanged" then
		self:updateValue(event.value)
	end
	
	if self.item.type == "slider" then
		self.slider:receive(event)
	elseif self.item.type == "checkbox" then
		self.checkbox:receive(event)
	end
	
	CustomList.Button.receive(self, event)
end

SettingsListButton.draw = function(self)
	self.nameTextFrame:draw()
	self.valueTextFrame:draw()
	
	if self.item.type == "slider" then
		self.slider:draw()
	elseif self.item.type == "checkbox" then
		self.checkbox:draw()
	end
end

SettingsListButton.getValue = function(self)
	if self.item.type == "slider" then
		return self.slider.value
	elseif self.item.type == "checkbox" then
		return self.checkbox.value
	end
end

SettingsListButton.getDisplayValue = function(self)
	if self.item.type == "slider" then
		return self.item.format:format(map(self:getValue(), self.item.minValue, self.item.maxValue, self.item.minDisplayValue, self.item.maxDisplayValue))
	elseif self.item.type == "checkbox" then
		return self:getValue(value) == self.item.minValue and self.item.minDisplayValue or self.item.maxDisplayValue
	end
end

SettingsListButton.updateValue = function(self, value)
	Config:set(self.item.configKey, value)
	self.valueTextFrame.text = self:getDisplayValue(value)
	self.valueTextFrame:reload()
end

return SettingsListButton
