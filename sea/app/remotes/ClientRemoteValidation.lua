local class = require("class")
local OnlineClientRemoteValidation = require("sphere.online.remotes.OnlineClientRemoteValidation")
local ComputeDataProviderRemoteValidation = require("sea.compute.remotes.ComputeDataProviderRemoteValidation")

---@class sea.ClientRemoteValidation: sea.ClientRemote
---@operator call: sea.ClientRemoteValidation
local ClientRemoteValidation = class()

---@param remote sea.ClientRemote
function ClientRemoteValidation:new(remote)
	self.remote = remote
	self.client = OnlineClientRemoteValidation(remote.client)
	self.compute_data_provider = ComputeDataProviderRemoteValidation(remote.compute_data_provider)
end

---@param ... any
function ClientRemoteValidation:print(...)
	return self.remote:print(...)
end

---@return number
function ClientRemoteValidation:getRandomNumber()
	local res = self.remote:getRandomNumber()
	assert(type(res) == "number")
	return res
end

return ClientRemoteValidation
