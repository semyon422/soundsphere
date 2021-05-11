local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local AvailableModifierListItemView = require(viewspackage .. "ModifierView.AvailableModifierListItemView")

local AvailableModifierListView = ListView:new()

AvailableModifierListView.construct = function(self)
	ListView.construct(self)
	self.itemView = AvailableModifierListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

AvailableModifierListView.reloadItems = function(self)
	self.state.items = self.modifierModel.modifiers
end

AvailableModifierListView.getItemIndex = function(self)
	return self.modifierModel.availableModifierItemIndex
end

AvailableModifierListView.scrollUp = function(self)
	self.navigator:scrollAvailableModifier("up")
end

AvailableModifierListView.scrollDown = function(self)
	self.navigator:scrollAvailableModifier("down")
end

AvailableModifierListView.receiveItems = function(self, event)
	local state = self.state
	local config = self.config

	local deltaItemIndex = state.selectedItem - state.selectedVisualItem
	for i = 0 - math.floor(deltaItemIndex), config.rows - math.floor(deltaItemIndex) do
		local itemIndex = i + state.selectedItem - math.ceil(config.rows / 2)
		local visualIndex = i + deltaItemIndex
		local item = state.items[itemIndex]
		if item then
			local itemView = self:getItemView(item)
			itemView.visualIndex = visualIndex
			itemView.itemIndex = itemIndex
			itemView.item = item
			itemView.listView = self
			itemView.prevItem = state.items[itemIndex - 1]
			itemView.nextItem = state.items[itemIndex + 1]
			itemView:receive(event)
		end
	end
end

AvailableModifierListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

AvailableModifierListView.wheelmoved = function(self, event)
	local config = self.config
	local cs = self.cs

	local mx, my = love.mouse.getPosition()
	local x = cs:X(config.x / config.screen.h, true)
	local y = cs:Y(config.y / config.screen.h, true)
	local w = cs:X(config.w / config.screen.h)
	local h = cs:Y(config.h / config.screen.h)

	if mx >= x and mx < x + w and my >= y and my < y + h then
		local wy = event.args[2]
		if wy == 1 then
			self:scrollUp()
		elseif wy == -1 then
			self:scrollDown()
		end
		return
	end
end

return AvailableModifierListView
