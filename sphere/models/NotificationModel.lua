local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")

local NotificationModel = Class:new()

NotificationModel.construct = function(self)
    self.observable = Observable:new()
    self.messages = {}
end

NotificationModel.notify = function(self, message)
    local messages = self.messages
    messages[#messages + 1] = message
    self.observable:send({
        name = "Notification",
        message = message
    })
end

return NotificationModel
