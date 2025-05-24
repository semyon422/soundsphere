local IEmailSender = require("sea.access.IEmailSender")

---@class sea.FakeEmailSender: sea.IEmailSender
---@operator call: sea.FakeEmailSender
local FakeEmailSender = IEmailSender + {}

function FakeEmailSender:new()
	---@type string[]
	self.emails = {}
end

---@param email string
---@param text string
function FakeEmailSender:send(email, text)
	table.insert(self.emails, ("%s: %s"):format(email, text))
end

return FakeEmailSender
