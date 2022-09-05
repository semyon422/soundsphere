local just = require("just")
local tween = require("tween")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local ListItemView = require("sphere.views.ListItemView")

local ListView = Class:new()

ListView.targetItemIndex = 1
ListView.itemIndex = 1
ListView.visualItemIndex = 1

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
	self.itemIndex = itemIndex
	self.visualItemIndex = itemIndex
end

ListView.reloadItems = function(self)
	self.stateCounter = 1
	self.items = {}
end

ListView.receive = function(self, event) end

ListView.scroll = function(self, delta)
	self.targetItemIndex = math.min(math.max(self.targetItemIndex + delta, 1), #self.items)
end

ListView.update = function(self, dt)
	local itemIndex = assert(self:getItemIndex())
	if self.itemIndex ~= itemIndex then
		self.scrollTween = tween.new(
			0.1,
			self,
			{visualItemIndex = itemIndex},
			"linear"
		)
		self.itemIndex = itemIndex
	end
	if self.visualItemIndex == self.itemIndex then
		self.scrollTween = nil
	end
	if self.scrollTween then
		self.scrollTween:update(math.min(dt, 1 / 60))
	end
end

ListView.getItemIndex = function(self)
	return self.targetItemIndex
end

ListView.getItemView = function(self, item)
	return self.itemView
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
	if delta then
		self:scroll(-delta)
	end

	love.graphics.setColor(1, 1, 1, 1)
	just.clip(love.graphics.rectangle, "fill", 0, 0, self.w, self.h)

	local deltaItemIndex = self.itemIndex - self.visualItemIndex
	for i = 0 - math.floor(deltaItemIndex), self.rows - math.floor(deltaItemIndex) do
		local itemIndex = i + self.itemIndex - math.ceil(self.rows / 2)
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

	just.clip()
end

ListView.drawItem = function(self, itemIndex, w, h)
	local item = self.items[itemIndex]
	local itemView = self:getItemView(item)
	itemView:draw(w, h)
end

ListView.getItemPosition = function(self, itemIndex)
	local visualIndex = math.ceil(self.rows / 2) + itemIndex - self.visualItemIndex
	local h = self.h / self.rows

	return 0, (visualIndex - 1) * h, self.w, h
end

ListView.getItemElementPosition = function(self, el)
	return el.x, el.y, el.w, el.h
end

return ListView
