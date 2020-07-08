local Observable = require("aqua.util.Observable")

local NotificationModel = {}

NotificationModel.init = function(self)
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

NotificationModel:init()

return NotificationModel
