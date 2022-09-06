local just = require("just")
local tween = require("tween")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local ListView = Class:new()

ListView.targetItemIndex = 1
ListView.itemIndex = 1
ListView.visualItemIndex = 1

ListView.forceScroll = function(self)
	local itemIndex = assert(self:getItemIndex())
	self.itemIndex = itemIndex
	self.visualItemIndex = itemIndex
end

ListView.reloadItems = function(self)
	self.stateCounter = 1
	self.items = {}
end

ListView.scroll = function(self, delta)
	self.targetItemIndex = math.min(math.max(self.targetItemIndex + delta, 1), #self.items)
end

ListView.getItemIndex = function(self)
	return self.targetItemIndex
end

ListView.draw = function(self)
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
		self.scrollTween:update(math.min(love.timer.getDelta(), 1 / 60))
	end

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
		local item = self.items[itemIndex]
		if item then
			local visualIndex = math.ceil(self.rows / 2) + itemIndex - self.visualItemIndex
			local h = self.h / self.rows

			local tf = transform(self.transform):translate(self.x, self.y + (visualIndex - 1) * h)
			love.graphics.replaceTransform(tf)
			self:drawItem(itemIndex, self.w, h)
		end
	end

	just.clip()
end

return ListView
