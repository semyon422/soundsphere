local Class = require("aqua.util.Class")
local NotificationLine = require("sphere.ui.NotificationLine")

local NotificationView = Class:new()

NotificationView.construct = function(self)
    self.notificationLine = NotificationLine:new()
end

NotificationView.load = function(self)
    self.notificationLine:load()
end

NotificationView.unload = function(self)
end

NotificationView.receive = function(self, event)
    self.notificationLine:receive(event)
end

NotificationView.update = function(self, dt)
    self.notificationLine:update(dt)
end

NotificationView.draw = function(self)
    self.notificationLine:draw()
end

return NotificationView
