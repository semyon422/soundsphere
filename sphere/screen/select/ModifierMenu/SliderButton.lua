local aquafonts		= require("aqua.assets.fonts")
local TextFrame		= require("aqua.graphics.TextFrame")
local map			= require("aqua.math").map
local spherefonts	= require("sphere.assets.fonts")
local CrossButton	= require("sphere.ui.CrossButton")
local CustomList	= require("sphere.ui.CustomList")
local Slider		= require("sphere.ui.Slider")

local SliderButton = CustomList.Button:new()

SliderButton.nameTextAlign = {x = "left", y = "center"}
SliderButton.valueTextAlign = {x = "left", y = "center"}

SliderButton.columnX = {0, 4/11, 6/11, 10/11}
SliderButton.columnWidth = {4/11, 2/11, 4/11, 1/11}

SliderButton.sliderRectangleColor = {63, 63, 63, 255}
SliderButton.sliderCircleColor = {255, 255, 255, 255}
SliderButton.sliderCircleLineColor = {255, 255, 255, 255}

SliderButton.construct = function(self)
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
	
	self.nameTextFrame = TextFrame:new()
	self.valueTextFrame = TextFrame:new()
	
	self.slider = Slider:new()
	self.slider.item = self.item
	self.slider.observable:add(self)
	
	self.crossButton = CrossButton:new()
	self.crossButton.item = self.item
	self.crossButton.observable:add(self)
	
	CustomList.Button.construct(self)
end

SliderButton.reload = function(self)
	local slider = self.slider
	
	slider.x = self.x + self.w * self.columnX[3]
	slider.y = self.y
	slider.w = self.w * self.columnWidth[3]
	slider.h = self.h
	slider.barHeight = self.h / 2
	slider.rectangleColor = self.sliderRectangleColor
	slider.circleColor = self.sliderCircleColor
	slider.cs = self.cs
	slider.value = slider.value or self.item.minValue
	
	slider.step = self.item.step
	slider.minValue = self.item.minValue
	slider.maxValue = self.item.maxValue
	
	slider:reload()
	
	local crossButton = self.crossButton
	
	crossButton.x = self.x + self.w * self.columnX[4]
	crossButton.y = self.y
	crossButton.w = self.w * self.columnWidth[4]
	crossButton.h = self.h
	crossButton.cs = self.cs
	
	crossButton:reload()
	
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

SliderButton.receive = function(self, event)
	if event.name == "pressed" then
		return
	elseif event.name == "released" then
		return
	elseif event.name == "valueChanged" then
		self:updateValue(event.value)
	elseif event.name == "ButtonPressed" and event.sender == "CrossButton" then
		self:removeModifier()
	end
	
	self.crossButton:receive(event)
	self.slider:receive(event)
	
	CustomList.Button.receive(self, event)
end

SliderButton.draw = function(self)
	self.nameTextFrame:draw()
	self.valueTextFrame:draw()
	self.crossButton:draw()
	self.slider:draw()
end

SliderButton.getValue = function(self)
	return self.slider.value
end

SliderButton.getDisplayValue = function(self)
	return self.item.format:format(map(self:getValue(), self.item.minValue, self.item.maxValue, self.item.minDisplayValue, self.item.maxDisplayValue))
end

SliderButton.updateValue = function(self, value)
	self.valueTextFrame.text = self:getDisplayValue()
	self.valueTextFrame:reload()
end

SliderButton.removeModifier = function(self) end

return SliderButton
