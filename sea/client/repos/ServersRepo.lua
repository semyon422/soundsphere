local class = require("class")

---@class sea.ServersRepo
---@operator call: sea.ServersRepo
local ServersRepo = class()

---@param models rdb.Models
function ServersRepo:new(models)
	self.models = models
end

---@return sea.ServerInfo[]
function ServersRepo:getServerInfos()
	return self.models.server_infos:select()
end

--------------------------------------------------------------------------------

---@return sea.AuthState[]
function ServersRepo:getAuthStates()
	return self.models.auth_states:select()
end

return ServersRepo
