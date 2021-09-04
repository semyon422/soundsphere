local viewspackage = (...):match("^(.-%.views%.)")

local tween = require("tween")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local ListItemView = require(viewspackage .. "ListItemView")

local ListView = Class:new()

ListView.construct = function(self)
	self.itemView = ListItemView:new()
	self.itemView.listView = self
	self.stencilfunction = function()
		self:drawStencil()
	end
end

ListView.load = function(self)
	self:reloadItems()
	self:forceScroll()
end

ListView.forceScroll = function(self)
	local itemIndex = assert(self:getItemIndex())
	self.state.selectedItem = itemIndex
	self.state.selectedVisualItem = itemIndex
	self.state.numberItems = #self.state.items
end

ListView.reloadItems = function(self)
	self.state.items = {}
end

ListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
end

ListView.wheelmoved = function(self, event)
	local config = self.config

	local tf = transform(config.transform)
	local mx, my = tf:inverseTransformPoint(love.mouse.getPosition())

	local x = config.x
	local y = config.y
	local w = config.w
	local h = config.h
	if mx >= x and mx < x + w and my >= y and my < y + h then
		local wy = event.args[2]
		if wy == 1 then
			self:scrollUp()
		elseif wy == -1 then
			self:scrollDown()
		end
	end
end

ListView.receiveItems = function(self, event)
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

ListView.scrollUp = function(self) end

ListView.scrollDown = function(self) end

ListView.update = function(self, dt)
	local itemIndex = assert(self:getItemIndex())
	if self.state.selectedItem ~= itemIndex then
		self.state.scrollTween = tween.new(
			0.1,
			self.state,
			{selectedVisualItem = itemIndex},
			"linear"
		)
		self.state.selectedItem = itemIndex
	end
	if self.state.selectedVisualItem == self.state.selectedItem then
		self.state.scrollTween = nil
	end
	if self.state.scrollTween then
		self.state.scrollTween:update(math.min(dt, 1 / 60))
	end

	local items = self.state.items
	local numberItems = self.state.numberItems
	self:reloadItems()
	if items ~= self.state.items or numberItems ~= #items then
		self:forceScroll()
	end
end

ListView.getItemIndex = function(self)
	return 1
end

ListView.getItemView = function(self, item)
	return self.itemView
end

ListView.drawStencil = function(self)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.rectangle(
		"fill",
		config.x,
		config.y,
		config.w,
		config.h
	)
end

ListView.draw = function(self)
	love.graphics.stencil(
		self.stencilfunction,
		"replace",
		1,
		false
	)
	love.graphics.setStencilTest("greater", 0)

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
			itemView:draw()
		end
	end

	love.graphics.setStencilTest()
end

ListView.getItemPosition = function(self, itemIndex)
	local config = self.config

	local visualIndex = math.ceil(config.rows / 2) + itemIndex - self.state.selectedVisualItem
	local h = config.h / config.rows

	return 0, (visualIndex - 1) * h, config.w, h
end

ListView.getItemElementPosition = function(self, itemIndex, el)
	local config = self.config
	local state = self.state
	local visualIndex = math.ceil(config.rows / 2) + itemIndex - state.selectedVisualItem
	local h = config.h / config.rows

	return el.x, (visualIndex - 1) * h + el.y, el.w, el.h
end

return ListView
