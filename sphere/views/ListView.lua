local just = require("just")
local flux = require("flux")
local Class = require("Class")

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

ListView.draw = function(self, w, h)
	local itemIndex = assert(self:getItemIndex())
	if self.itemIndex ~= itemIndex then
		if self.tween then
			self.tween:stop()
		end
		self.tween = flux.to(self, 0.1, {visualItemIndex = itemIndex}):ease("linear")
		self.itemIndex = itemIndex
	end

	local stateCounter = self.stateCounter
	self:reloadItems()
	if stateCounter ~= self.stateCounter then
		local itemIndex = assert(self:getItemIndex())
		self.itemIndex = itemIndex
		self.visualItemIndex = itemIndex
	end

	love.graphics.setColor(1, 1, 1, 1)
	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h)

	local _h = h / self.rows
	local visualItemIndex = self.visualItemIndex

	local deltaItemIndex = math.floor(visualItemIndex) - visualItemIndex
	love.graphics.translate(0, deltaItemIndex * _h)

	local delta = just.wheel_over(self, just.is_over(w, h))
	if delta then
		self:scroll(-delta)
	end

	for i = math.floor(visualItemIndex), self.rows + math.ceil(visualItemIndex) - 1 do
		local _i = i - math.floor(self.rows / 2)
		if self.items[_i] then
			just.push()
			self:drawItem(_i, w, _h)
			just.pop()
		end
		just.emptyline(_h)
	end

	just.clip()
end

return ListView
