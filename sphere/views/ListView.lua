local just = require("just")
local tween = require("tween")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local ListItemView = require("sphere.views.ListItemView")

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
	self.selectedItem = itemIndex
	self.selectedVisualItem = itemIndex
end

ListView.reloadItems = function(self)
	self.stateCounter = 1
	self.items = {}
end

ListView.receive = function(self, event) end
ListView.scrollUp = function(self) end
ListView.scrollDown = function(self) end

ListView.update = function(self, dt)
	local itemIndex = assert(self:getItemIndex())
	if self.selectedItem ~= itemIndex then
		self.scrollTween = tween.new(
			0.1,
			self,
			{selectedVisualItem = itemIndex},
			"linear"
		)
		self.selectedItem = itemIndex
	end
	if self.selectedVisualItem == self.selectedItem then
		self.scrollTween = nil
	end
	if self.scrollTween then
		self.scrollTween:update(math.min(dt, 1 / 60))
	end
end

ListView.getItemIndex = function(self)
	return 1
end

ListView.getItemView = function(self, item)
	return self.itemView
end

ListView.drawStencil = function(self)
	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.rectangle(
		"fill",
		self.x,
		self.y,
		self.w,
		self.h
	)
end

ListView.draw = function(self)
	local stateCounter = self.stateCounter
	self:reloadItems()
	if stateCounter ~= self.stateCounter then
		self:forceScroll()
	end

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= mx and mx <= self.w and 0 <= my and my <= self.h

	local delta = just.wheel_over(self, over)
	if delta == 1 then
		self:scrollUp()
	elseif delta == -1 then
		self:scrollDown()
	end

	love.graphics.stencil(
		self.stencilfunction,
		"replace",
		1,
		false
	)
	love.graphics.setStencilTest("greater", 0)

	local deltaItemIndex = self.selectedItem - self.selectedVisualItem
	for i = 0 - math.floor(deltaItemIndex), self.rows - math.floor(deltaItemIndex) do
		local itemIndex = i + self.selectedItem - math.ceil(self.rows / 2)
		local visualIndex = i + deltaItemIndex
		local item = self.items[itemIndex]
		if item then
			local itemView = self:getItemView(item)
			itemView.visualIndex = visualIndex
			itemView.itemIndex = itemIndex
			itemView.item = item
			itemView.listView = self
			itemView.prevItem = self.items[itemIndex - 1]
			itemView.nextItem = self.items[itemIndex + 1]

			local x, y, w, h = self:getItemPosition(itemIndex)
			local tf = transform(self.transform):translate(self.x + x, self.y + y)
			love.graphics.replaceTransform(tf)
			self:drawItem(itemIndex, w, h)
		end
	end

	love.graphics.setStencilTest()
end

ListView.drawItem = function(self, itemIndex, w, h)
	local item = self.items[itemIndex]
	local itemView = self:getItemView(item)
	itemView:draw(w, h)
end

ListView.getItemPosition = function(self, itemIndex)
	local visualIndex = math.ceil(self.rows / 2) + itemIndex - self.selectedVisualItem
	local h = self.h / self.rows

	return 0, (visualIndex - 1) * h, self.w, h
end

ListView.getItemElementPosition = function(self, el)
	return el.x, el.y, el.w, el.h
end

return ListView
