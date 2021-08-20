local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local ResultNavigator = Navigator:new()

ResultNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if scancode == "escape" then
		self:changeScreen("Select")
	end
end

ResultNavigator.scrollScore = function(self, direction)
	self:send({
		name = "scrollScore",
		direction = direction == "down" and 1 or -1
	})
end

return ResultNavigator
