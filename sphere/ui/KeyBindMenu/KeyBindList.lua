local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local CustomList		= require("sphere.ui.CustomList")
local KeyBindListButton	= require("sphere.ui.KeyBindMenu.KeyBindListButton")

local KeyBindList = CustomList:new()

KeyBindList.x = 0
KeyBindList.y = 0
KeyBindList.w = 1
KeyBindList.h = 1

KeyBindList.sender = "KeyBindList"
KeyBindList.needFocusToInteract = false

KeyBindList.buttonCount = 17
KeyBindList.middleOffset = 9
KeyBindList.startOffset = 9
KeyBindList.endOffset = 9

KeyBindList.textAlign = {x = "left", y = "center"}
KeyBindList.limit = KeyBindList.w

KeyBindList.Button = KeyBindListButton

KeyBindList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 0.5, 0, "h")
end

KeyBindList.load = function(self)
	self:addItems()
	self:reload()
end

KeyBindList.getSelectedInputMode = function(self)
	local noteChart = self.menu.noteChart

	if not noteChart then
		return ""
	end

	return noteChart.inputMode:getString()
end

KeyBindList.addItems = function(self)
	local noteChart = self.menu.noteChart

	if not noteChart then
		return
	end

	local items = {}

	for inputCount, inputType in self:getSelectedInputMode():gmatch("([0-9]+)([a-z]+)") do
		for i = 1, inputCount do
			items[#items + 1] = {
				name = inputType .. i,
				type = "keybind",
				virtualKey = inputType .. i
			}
		end
	end

	return self:setItems(items)
end

return KeyBindList
