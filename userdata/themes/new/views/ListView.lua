
local Node = require("aqua.util.Node")

local ListView = Node:new()

ListView.init = function(self)
	local ListItemView = self.ListItemView or dofile(self.__path .. "/views/ListItemView.lua")
	for i = 1, self.itemCount do
		local item = ListItemView:new()
		item.__path = self.__path
		item.listView = self
		item.index = i
		self:node(item)
	end

	local cs = self.cs
	self:on("mousemoved", function(self, event)
		local x = cs:X(self.x, true)
		local y = cs:Y(self.y, true)
		local w = cs:X(self.w)
		local h = cs:Y(self.h)
		if event.args[1] >= x and event.args[1] < x + w and event.args[2] >= y and event.args[2] < y + h then
			self:call("select")
		end
	end)
end

return ListView
