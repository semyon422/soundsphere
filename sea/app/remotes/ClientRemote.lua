local class = require("class")
local OnlineClientRemote = require("sphere.online.remotes.OnlineClientRemote")
local MultiplayerClientRemote = require("sea.multi.remotes.MultiplayerClientRemote")

---@class sea.ClientRemote: sea.IClientRemoteContext
---@field multiplayer sea.MultiplayerClientRemote
---@operator call: sea.ClientRemote
local ClientRemote = class()

---@param client sphere.OnlineClient
---@param library rizu.library.Library
---@param multipalyer_client sea.MultiplayerClient
function ClientRemote:new(client, library, multipalyer_client)
	self.client = OnlineClientRemote(client)
	self.multiplayer = MultiplayerClientRemote(multipalyer_client)
	self.compute_data_provider = library.computeDataProvider
end

---@param ... any
function ClientRemote:print(...)
	print(...)
end

---@return number
function ClientRemote:getRandomNumber()
	return math.random()
end

return ClientRemote
