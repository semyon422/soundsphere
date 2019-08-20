local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Observable		= require("aqua.util.Observable")
local CustomList		= require("sphere.ui.CustomList")

local CategoriesList = CustomList:new()

CategoriesList.x = 0
CategoriesList.y = 0
CategoriesList.w = 0.4
CategoriesList.h = 1

CategoriesList.sender = "CategoriesList"
CategoriesList.needFocusToInteract = false

CategoriesList.buttonCount = 17
CategoriesList.middleOffset = 9
CategoriesList.startOffset = 9
CategoriesList.endOffset = 9

CategoriesList.textAlign = {x = "right", y = "center"}
CategoriesList.limit = CategoriesList.w

CategoriesList.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "h")
end

CategoriesList.load = function(self)
	self:addItems()
	self:reload()
end

CategoriesList.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		if key == "f5" then
		end
	end
	
	return CustomList.receive(self, event)
end

CategoriesList.addItems = function(self)
	local items = {}
	
	items[#items + 1] = {
		name = "general",
		category = "general",
	}
	items[#items + 1] = {
		name = "graphics",
		category = "graphics"
	}
	items[#items + 1] = {
		name = "sound",
		category = "sound"
	}
	items[#items + 1] = {
		name = "input",
		category = "input"
	}
	
	return self:setItems(items)
end

return CategoriesList
