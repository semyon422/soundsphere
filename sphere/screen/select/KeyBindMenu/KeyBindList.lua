local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Observable		= require("aqua.util.Observable")
local CustomList		= require("sphere.ui.CustomList")
local KeyBindListButton	= require("sphere.screen.select.KeyBindMenu.KeyBindListButton")
local NoteChartList  	= require("sphere.screen.select.NoteChartList")

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

KeyBindList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f5" then
		end
	end
	
	return CustomList.receive(self, event)
end

KeyBindList.getSelectedInputMode = function(self)
	return NoteChartList.items[NoteChartList.focusedItemIndex].cacheData.inputMode
end

KeyBindList.addItems = function(self)
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
