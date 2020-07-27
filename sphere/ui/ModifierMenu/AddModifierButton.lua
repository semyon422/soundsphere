local aquafonts		= require("aqua.assets.fonts")
local TextFrame		= require("aqua.graphics.TextFrame")
local map			= require("aqua.math").map
local spherefonts	= require("sphere.assets.fonts")
local PlusButton	= require("sphere.ui.PlusButton")
local CustomList	= require("sphere.ui.CustomList")

local AddModifierButton = CustomList.Button:new()

AddModifierButton.nameTextAlign = {x = "left", y = "center"}

AddModifierButton.columnX = {0, 0.9}
AddModifierButton.columnWidth = {0.9, 0.1}

AddModifierButton.construct = function(self)
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
	
	self.nameTextFrame = TextFrame:new()
	
	self.plusButton = PlusButton:new()
	self.plusButton.item = self.item
	self.plusButton.observable:add(self)
	
	CustomList.Button.construct(self)
end

AddModifierButton.reload = function(self)
	local plusButton = self.plusButton
	
	plusButton.x = self.x + self.w * self.columnX[2]
	plusButton.y = self.y
	plusButton.w = self.w * self.columnWidth[2]
	plusButton.h = self.h
	plusButton.cs = self.cs
	
	plusButton:reload()
	
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

AddModifierButton.receive = function(self, event)
	if event.name == "ButtonPressed" and event.sender == "PlusButton" then
		self:add()
	end
	
	self.plusButton:receive(event)
	
	CustomList.Button.receive(self, event)
end

AddModifierButton.draw = function(self)
	self.nameTextFrame:draw()
	self.plusButton:draw()
end

AddModifierButton.add = function(self) end

return AddModifierButton
