local class = require("class")

---@class sea.ClientRemote: sea.IClientRemote
---@operator call: sea.ClientRemote
local ClientRemote = class()

---@param game sphere.GameplayController
function ClientRemote:new(game)
	self.compute_data_provider = game.cacheModel.computeDataProvider
end

return ClientRemote
