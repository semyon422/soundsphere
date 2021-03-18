local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local ResultNavigator = Navigator:new()

ResultNavigator.construct = function(self)
	Navigator.construct(self)

	local resultNode = Node:new()
	self.resultNode = resultNode
end

ResultNavigator.load = function(self)
	Navigator.load(self)

	local resultNode = self.resultNode

	self.node = resultNode
	resultNode:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)
end

ResultNavigator.receive = function(self, event)
	if event.name == "keypressed" then
		self:call(event.args[1])
		return
	end
end

return ResultNavigator
