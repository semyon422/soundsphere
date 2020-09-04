local aquafonts			= require("aqua.assets.fonts")
local aquamath			= require("aqua.math")
local TextFrame			= require("aqua.graphics.TextFrame")
local map				= require("aqua.math").map
local spherefonts		= require("sphere.assets.fonts")
local CrossButton		= require("sphere.ui.CrossButton")
local CustomList		= require("sphere.ui.CustomList")

local TextButton = CustomList.Button:new()

TextButton.columnX = {0, 0.9}
TextButton.columnWidth = {0.9, 0.1}

TextButton.nameTextAlign = {x = "left", y = "center"}

TextButton.construct = function(self)
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)

	self.nameTextFrame = TextFrame:new()

	self.crossButton = CrossButton:new()
	self.crossButton.item = self.item
	self.crossButton.observable:add(self)

	CustomList.Button.construct(self)
end

TextButton.reload = function(self)
	local crossButton = self.crossButton

	crossButton.x = self.x + self.w * self.columnX[2]
	crossButton.y = self.y
	crossButton.w = self.w * self.columnWidth[2]
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
end

TextButton.receive = function(self, event)
	if event.name == "ButtonPressed" and event.sender == "CrossButton" then
		self:removeModifier()
	end

	self.crossButton:receive(event)

	CustomList.Button.receive(self, event)
end

TextButton.draw = function(self)
	self.nameTextFrame:draw()
	self.crossButton:draw()
end

TextButton.removeModifier = function(self) end

return TextButton
