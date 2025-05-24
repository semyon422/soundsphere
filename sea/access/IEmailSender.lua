local class = require("class")

---@class sea.IEmailSender
---@operator call: sea.IEmailSender
local IEmailSender = class()

---@param email string
---@param text string
function IEmailSender:send(email, text) end

return IEmailSender
