local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local CustomList		= require("sphere.ui.CustomList")

local ThemeList = CustomList:new()

ThemeList.x = 0
ThemeList.y = 0
ThemeList.w = 1
ThemeList.h = 1

ThemeList.textAlign = {x = "center", y = "center"}

ThemeList.sender = "ThemeList"
ThemeList.needFocusToInteract = false

ThemeList.buttonCount = 17
ThemeList.middleOffset = 9
ThemeList.startOffset = 9
ThemeList.endOffset = 9

ThemeList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")
end

ThemeList.load = function(self)
	self:addItems()
	self:reload()
end

ThemeList.send = function(self, event)
	if event.action == "buttonInteract" and event.button == 1 then
		local theme = self.items[event.itemIndex].theme
		self.menu.observable:send({
			name = "setTheme",
			theme = theme
		})
		self:addItems()
	end

	CustomList.send(self, event)
end

ThemeList.addItems = function(self)
	local items = {}

	local themeModel = self.menu.themeModel

	local list = themeModel:getThemes()
	local selectedTheme = themeModel:getTheme()

	for _, theme in ipairs(list) do
		local name = theme.name
		if name == selectedTheme.name then
			name = "★ " .. name
		end
		items[#items + 1] = {
			theme = theme,
			name = name
		}
	end

	return self:setItems(items)
end

return ThemeList
