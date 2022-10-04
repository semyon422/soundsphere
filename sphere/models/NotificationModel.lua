local Class = require("Class")

local NotificationModel = Class:new()

NotificationModel.construct = function(self)
	self.message = ""
	self.time = 0
	self.delay = 1
end

NotificationModel.notify = function(self, message)
	self.message = message
	self.time = love.timer.getTime()
end

NotificationModel.update = function(self)
	if love.timer.getTime() > self.time + self.delay then
		self.message = ""
	end
end

return NotificationModel
