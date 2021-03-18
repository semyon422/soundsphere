local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local CategoriesListItemView = require(viewspackage .. "SettingsView.CategoriesListItemView")

local CategoriesListView = ListView:new()

CategoriesListView.init = function(self)
	self.ListItemView = CategoriesListItemView
	self.view = self.view
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = -16 / 9 / 3 + 16 / 9 / 3 / 4
	self.y = 0
	self.w = 16 / 9 / 3 / 2
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.categoriesList.selected
	end)
	self:on("select", function()
        if not self.navigator:checkNode("inputHandler") then
		    self.navigator:setNode("categoriesList")
        end
	end)
	self:on("draw", self.drawFrame)
	self:on("wheelmoved", function(self, event)
		local mx, my = love.mouse.getPosition()
		local cs = self.cs
		local x = cs:X(self.x, true)
		local w = cs:X(self.w)
		if mx >= x and mx < x + w then
			local wy = event.args[2]
			if wy == 1 then
				self.navigator:call("up")
			elseif wy == -1 then
				self.navigator:call("down")
			end
		end
	end)
	self:on("mousepressed", self.receive)

	ListView.init(self)
end

CategoriesListView.reloadItems = function(self)
	self.items = self.config_settings_model
end

CategoriesListView.drawFrame = function(self)
	if self.navigator:checkNode("categoriesList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return CategoriesListView
