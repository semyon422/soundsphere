local just = require("just")
local tween = require("tween")
local Class = require("Class")
local transform = require("gfx_util").transform

local ListView = Class:new()

ListView.targetItemIndex = 1
ListView.itemIndex = 1
ListView.visualItemIndex = 1

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
		local itemIndex = assert(self:getItemIndex())
		self.itemIndex = itemIndex
		self.visualItemIndex = itemIndex
	end

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)
	just.clip(love.graphics.rectangle, "fill", 0, 0, self.w, self.h)

	local h = self.h / self.rows
	local visualItemIndex = self.visualItemIndex

	local deltaItemIndex = math.floor(visualItemIndex) - visualItemIndex
	love.graphics.translate(0, deltaItemIndex * h)

	local delta = just.wheel_over(self, just.is_over(self.w, self.h))
	if delta then
		self:scroll(-delta)
	end

	for i = math.floor(visualItemIndex), self.rows + math.ceil(visualItemIndex) - 1 do
		local _i = i - math.floor(self.rows / 2)
		if self.items[_i] then
			just.push()
			self:drawItem(_i, self.w, h)
			just.pop()
		end
		just.emptyline(h)
	end

	just.clip()
end

return ListView
