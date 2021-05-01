local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local SelectNavigator = Navigator:new()

SelectNavigator.construct = function(self)
	Navigator.construct(self)

	self.node = Node:new()
end

SelectNavigator.update = function(self) end

SelectNavigator.load = function(self)
	Navigator.load(self)

	local node = self.node

	node:on("f5", function()
		local cacheUpdater = self.view.cacheModel.cacheUpdater
		if cacheUpdater.state == 0 or cacheUpdater.state == 3 then
			self:send({
				name = "startCacheUpdate"
			})
		else
			self:send({
				name = "stopCacheUpdate"
			})
		end
	end)

	node:on("up", function()
		self:send({
			name = "scrollNoteChartSet",
			direction = -1
		})
	end)
	node:on("down", function()
		self:send({
			name = "scrollNoteChartSet",
			direction = 1
		})
	end)
	node:on("right", function()
		self:send({
			name = "scrollNoteChart",
			direction = 1
		})
	end)
	node:on("left", function()
		self:send({
			name = "scrollNoteChart",
			direction = -1
		})
	end)
	node:on("return", function()
		self:send({
			action = "playNoteChart"
		})
	end)
end

SelectNavigator.receive = function(self, event)
	if event.name == "keypressed" then
		self:call(event.args[1])
	end
end

return SelectNavigator
