local class = require("class")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")

---@class sphere.OnlineModel
---@operator call: sphere.OnlineModel
local OnlineModel = class()

---@param configModel sphere.ConfigModel
---@param sea_client sphere.SeaClient
function OnlineModel:new(configModel, sea_client)
	self.configModel = configModel
	self.sea_client = sea_client
	self.authManager = AuthManager(sea_client, configModel)
end

function OnlineModel:getUser()
	return self.configModel.configs.online.user
end

return OnlineModel
