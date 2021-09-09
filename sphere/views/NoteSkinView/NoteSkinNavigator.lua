local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local NoteSkinNavigator = Navigator:new({construct = false})

NoteSkinNavigator.construct = function(self)
	Navigator.construct(self)
	self.noteSkinItemIndex = 1
end

NoteSkinNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if scancode == "up" then self:scrollNoteSkin("up")
	elseif scancode == "down" then self:scrollNoteSkin("down")
	elseif scancode == "return" then self:setNoteSkin()
	elseif scancode == "escape" then self:changeScreen("Select")
	end
end

NoteSkinNavigator.scrollNoteSkin = function(self, direction)
	direction = direction == "up" and -1 or 1
	local noteChart = self.noteChartModel.noteChart
	local noteSkins = self.noteSkinModel:getNoteSkins(noteChart.inputMode)
	if not noteSkins[self.noteSkinItemIndex + direction] then
		return
	end
	self.noteSkinItemIndex = self.noteSkinItemIndex + direction
end

NoteSkinNavigator.setNoteSkin = function(self, itemIndex)
	local noteChart = self.noteChartModel.noteChart
	local noteSkins = self.noteSkinModel:getNoteSkins(noteChart.inputMode)
	self:send({
		name = "setNoteSkin",
		noteSkin = noteSkins[itemIndex or self.noteSkinItemIndex]
	})
	self:changeScreen("Select")
end

return NoteSkinNavigator
