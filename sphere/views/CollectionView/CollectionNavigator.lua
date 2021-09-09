local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local CollectionNavigator = Navigator:new({construct = false})

CollectionNavigator.construct = function(self)
	Navigator.construct(self)
	self.collectionItemIndex = 1
end

CollectionNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if scancode == "up" then self:scrollCollection("up")
	elseif scancode == "down" then self:scrollCollection("down")
	elseif scancode == "return" then self:setCollection()
	elseif scancode == "escape" then self:changeScreen("Select")
	end
end

CollectionNavigator.scrollCollection = function(self, direction)
	direction = direction == "up" and -1 or 1
	local collections = self.collectionModel.items
	if not collections[self.collectionItemIndex + direction] then
		return
	end
	self.collectionItemIndex = self.collectionItemIndex + direction
end

CollectionNavigator.setCollection = function(self, itemIndex)
	local collections = self.collectionModel.items
	self:send({
		name = "setCollection",
		collection = collections[itemIndex or self.collectionItemIndex]
	})
	self:changeScreen("Select")
end

CollectionNavigator.updateCache = function(self)
	local collections = self.collectionModel.items
	self:send({
		name = "updateCache",
		collection = collections[self.collectionItemIndex],
		force = love.keyboard.isDown("lshift")
	})
end

return CollectionNavigator
