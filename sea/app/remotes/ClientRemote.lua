local class = require("class")
local SubmissionClientRemote = require("sea.chart.remotes.SubmissionClientRemote")

---@class sea.ClientRemote: sea.IClientRemote
---@operator call: sea.ClientRemote
local ClientRemote = class()

function ClientRemote:new()
	self.submission = SubmissionClientRemote()
end

return ClientRemote
