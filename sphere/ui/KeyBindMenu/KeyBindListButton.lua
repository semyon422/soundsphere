local aquafonts			= require("aqua.assets.fonts")
local TextFrame			= require("aqua.graphics.TextFrame")
local map				= require("aqua.math").map
local spherefonts		= require("sphere.assets.fonts")
-- local InputManager		= require("sphere.screen.gameplay.InputManager")
local NoteChartList  	= require("sphere.ui.NoteChartList")
local KeybindEditButton	= require("sphere.screen.settings.KeybindEditButton")
local Checkbox			= require("sphere.ui.Checkbox")
local CustomList		= require("sphere.ui.CustomList")
local Slider			= require("sphere.ui.Slider")

local KeyBindListButton = CustomList.Button:new()

KeyBindListButton.nameTextAlign = {x = "left", y = "center"}
KeyBindListButton.valueTextAlign = {x = "right", y = "center"}

KeyBindListButton.columnX = {0, 0.5, 0.75}
KeyBindListButton.columnWidth = {0.5, 0.25, 0.25}

KeyBindListButton.construct = function(self)
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	
	self.nameTextFrame = TextFrame:new()
	self.valueTextFrame = TextFrame:new()
	
	self.keybindEditButton = KeybindEditButton:new()
	self.keybindEditButton.item = self.item
	self.keybindEditButton.observable:add(self)
	
	CustomList.Button.construct(self)
end

KeyBindListButton.reload = function(self)
	local keybindEditButton = self.keybindEditButton
	
	keybindEditButton.x = self.x + self.w * self.columnX[3]
	keybindEditButton.y = self.y
	keybindEditButton.w = self.w * self.columnWidth[3]
	keybindEditButton.h = self.h
	keybindEditButton.cs = self.cs
	-- keybindEditButton.value = InputManager:getKey(self:getSelectedInputMode(), self.item.virtualKey)
	
	keybindEditButton:reload()
	
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

KeyBindListButton.receive = function(self, event)
	if event.name == "pressed" then
		return
	elseif event.name == "released" then
		return
	elseif event.name == "valueChanged" then
		self:updateValue(event.value, event.type)
	end
	
	self.keybindEditButton:receive(event)
	
	CustomList.Button.receive(self, event)
end

KeyBindListButton.draw = function(self)
	self.nameTextFrame:draw()
	self.valueTextFrame:draw()
	
	self.keybindEditButton:draw()
end

KeyBindListButton.getValue = function(self)
	return self.keybindEditButton.value
end

KeyBindListButton.getDisplayValue = function(self)
	return self:getValue()
end

KeyBindListButton.getSelectedInputMode = function(self)
	return self.list:getSelectedInputMode()
end

KeyBindListButton.updateValue = function(self, value, type)
	-- InputManager:setKey(self:getSelectedInputMode(), self.item.virtualKey, value, type)
	self.valueTextFrame.text = self:getDisplayValue(value)
	self.valueTextFrame:reload()
end

return KeyBindListButton
