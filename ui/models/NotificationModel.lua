local class = require("class")

---@class sphere.NotificationModel
---@operator call: sphere.NotificationModel
local NotificationModel = class()

function NotificationModel:new()
	self.message = ""
	self.time = 0
	self.delay = 1
end

---@param message string
function NotificationModel:notify(message)
	self.message = message
	self.time = love.timer.getTime()
end

function NotificationModel:update()
	if love.timer.getTime() > self.time + self.delay then
		self.message = ""
	end
end

return NotificationModel
