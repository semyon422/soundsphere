local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local ErrorNavigator = Navigator:new({construct = false})

ErrorNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if scancode == "escape" then self:changeScreen("Select")
	end
end

return ErrorNavigator
