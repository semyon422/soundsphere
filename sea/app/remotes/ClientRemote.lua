local class = require("class")
local SubmissionClientRemote = require("sea.chart.remotes.SubmissionClientRemote")

---@class sea.ClientRemote: sea.IClientRemote
---@operator call: sea.ClientRemote
local ClientRemote = class()

---@param game sphere.GameplayController
function ClientRemote:new(game)
	self.submission = SubmissionClientRemote(game.cacheModel)
end

return ClientRemote
