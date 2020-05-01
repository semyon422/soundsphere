local aquafonts			= require("aqua.assets.fonts")
local TextFrame			= require("aqua.graphics.TextFrame")
local map				= require("aqua.math").map
local spherefonts		= require("sphere.assets.fonts")
local CrossButton		= require("sphere.ui.CrossButton")
local CustomList		= require("sphere.ui.CustomList")
local Slider			= require("sphere.ui.Slider")

local SliderButton = CustomList.Button:new()

SliderButton.nameTextAlign = {x = "left", y = "center"}
SliderButton.valueTextAlign = {x = "left", y = "center"}

SliderButton.columnX = {0, 0.45, 0.6, 0.9}
SliderButton.columnWidth = {0.45, 0.15, 0.3, 0.1}

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
	local modifier = self.item.modifier

	local slider = self.slider
	
	slider.x = self.x + self.w * self.columnX[3]
	slider.y = self.y
	slider.w = self.w * self.columnWidth[3]
	slider.h = self.h
	slider.barHeight = self.h / 2
	slider.rectangleColor = self.sliderRectangleColor
	slider.circleColor = self.sliderCircleColor
	slider.cs = self.cs
	slider.value = modifier[modifier.variableName]
	
	slider.step = modifier.variableRange[2]
	slider.minValue = modifier.variableRange[1]
	slider.maxValue = modifier.variableRange[3]
	
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
		-- ModifierDisplay:updateText()
		return
	elseif event.name == "released" then
		-- ModifierDisplay:updateText()
		return
	elseif event.name == "valueChanged" then
		-- ModifierDisplay:updateText()
		self:updateValue(event.value)
	elseif event.name == "ButtonPressed" and event.sender == "CrossButton" then
		-- ModifierDisplay:updateText()
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
	local displayRange = self.item.modifier.variableDisplayRange or self.item.modifier.variableRange
	local format = self.item.modifier.variableFormat or "%s"
	return format:format(map(self:getValue(), self.item.modifier.variableRange[1], self.item.modifier.variableRange[3], displayRange[1], displayRange[3]))
end

SliderButton.updateValue = function(self, value)
	self.valueTextFrame.text = self:getDisplayValue()
	self.valueTextFrame:reload()
end

SliderButton.removeModifier = function(self) end

return SliderButton
