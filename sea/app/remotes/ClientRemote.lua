local class = require("class")
local OnlineClientRemote = require("sphere.online.remotes.OnlineClientRemote")

---@class sea.ClientRemote: sea.IClientRemote
---@operator call: sea.ClientRemote
local ClientRemote = class()

---@param client sphere.OnlineClient
---@param cacheModel sphere.CacheModel
function ClientRemote:new(client, cacheModel)
	self.client = OnlineClientRemote(client)
	self.compute_data_provider = cacheModel.computeDataProvider
end

---@param ... any
function ClientRemote:print(...)
	print(...)
end

return ClientRemote
