local class = require("class")

---@class sea.ClientRemote: sea.IClientRemote
---@operator call: sea.ClientRemote
local ClientRemote = class()

---@param cacheModel sphere.CacheModel
function ClientRemote:new(cacheModel)
	self.compute_data_provider = cacheModel.computeDataProvider
end

return ClientRemote
