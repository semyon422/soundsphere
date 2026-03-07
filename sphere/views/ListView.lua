local just = require("just")
local flux = require("flux")
local class = require("class")

---@class sphere.ListView
---@operator call: sphere.ListView
local ListView = class()

ListView.targetItemIndex = 1
ListView.itemIndex = 1
ListView.visualItemIndex = 1

function ListView:reloadItems()
	self.stateCounter = 1
	self.items = {}
end

---@param i number
---@return any
function ListView:get(i)
	local items = self.items
	if not items then return nil end
	if items.get then
		return items:get(i)
	end
	return items[i]
end

---@return number
function ListView:getItemCount()
	local items = self.items
	if type(items) == "table" then
		if items.count and type(items.count) == "function" then
			return items:count()
		end
		if items.itemsCount then
			return items.itemsCount
		end
		return #items
	end
	if items.count and type(items.count) == "function" then
		return items:count()
	end
	return items.itemsCount or 0
end

---@param delta number
function ListView:scroll(delta)
	self.targetItemIndex = math.min(math.max(self.targetItemIndex + delta, 1), self:getItemCount())
end

---@return number
function ListView:getItemIndex()
	return self.targetItemIndex
end

---@param w number
---@param h number
function ListView:draw(w, h)
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

	local count = self:getItemCount()
	for i = math.floor(visualItemIndex), self.rows + math.ceil(visualItemIndex) - 1 do
		local _i = i - math.floor(self.rows / 2)
		if _i >= 1 and _i <= count then
			if self:get(_i) then
				just.push()
				self:drawItem(_i, w, _h)
				just.pop()
			end
		end
		just.emptyline(_h)
	end

	just.clip()
end

return ListView
