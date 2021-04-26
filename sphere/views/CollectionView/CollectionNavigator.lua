local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local CollectionNavigator = Navigator:new()

CollectionNavigator.construct = function(self)
	Navigator.construct(self)

	local collectionList = Node:new()
	self.collectionList = collectionList
	collectionList.selected = 1
end

CollectionNavigator.scrollCollection = function(self, direction, destination)
	local collectionList = self.collectionList

	local collections = self.view.collectionModel.items

	direction = direction or destination - collectionList.selected
	if not collections[collectionList.selected + direction] then
		return
	end

	collectionList.selected = collectionList.selected + direction
end

CollectionNavigator.load = function(self)
    Navigator.load(self)

	local collectionList = self.collectionList

	self.node = collectionList
	collectionList:on("up", function()
		self:scrollCollection(-1)
	end)
	collectionList:on("down", function()
		self:scrollCollection(1)
	end)
	collectionList:on("return", function(_, itemIndex)
        local collections = self.view.collectionModel.items
        self:send({
            name = "setCollection",
            collection = collections[itemIndex or collectionList.selected]
        })
		self:send({
			name = "goSelectScreen"
		})
    end)
	collectionList:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)
end

CollectionNavigator.receive = function(self, event)
	if event.name == "keypressed" then
		self:call(event.args[1])
	end
end

return CollectionNavigator
