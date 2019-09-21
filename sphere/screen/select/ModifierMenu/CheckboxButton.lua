local aquafonts		= require("aqua.assets.fonts")
local TextFrame		= require("aqua.graphics.TextFrame")
local map			= require("aqua.math").map
local spherefonts	= require("sphere.assets.fonts")
local Checkbox		= require("sphere.ui.Checkbox")
local CustomList	= require("sphere.ui.CustomList")

local CheckboxButton = CustomList.Button:new()

CheckboxButton.nameTextAlign = {x = "left", y = "center"}

CheckboxButton.columnX = {0, 0.9}
CheckboxButton.columnWidth = {0.9, 0.1}

CheckboxButton.construct = function(self)
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
	
	self.nameTextFrame = TextFrame:new()
	
	self.checkbox = Checkbox:new()
	self.checkbox.item = self.item
	self.checkbox.observable:add(self)
	
	CustomList.Button.construct(self)
end

CheckboxButton.reload = function(self)
	local checkbox = self.checkbox
	
	checkbox.x = self.x + self.w * self.columnX[2]
	checkbox.y = self.y
	checkbox.w = self.w * self.columnWidth[2]
	checkbox.h = self.h
	checkbox.cs = self.cs
	checkbox.value = checkbox.value or self.item.minValue
	
	checkbox:reload()
	
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
end

CheckboxButton.receive = function(self, event)
	if event.name == "valueChanged" then
		self:updateValue(event.value)
	end
	
	self.checkbox:receive(event)
	
	CustomList.Button.receive(self, event)
end

CheckboxButton.draw = function(self)
	self.nameTextFrame:draw()
	self.checkbox:draw()
end

CheckboxButton.updateValue = function(self, value) end

return CheckboxButton
