local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local ErrorNavigator = Navigator:new({construct = false})

ErrorNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event[2]
	if scancode == "escape" then self:changeScreen("Select")
	elseif scancode == "f1" then self:switchSubscreen("debug")
	end
end

return ErrorNavigator
