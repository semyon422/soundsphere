local class = require("class")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")

---@class sphere.OnlineModel
---@operator call: sphere.OnlineModel
local OnlineModel = class()

---@param configModel sphere.ConfigModel
---@param sea_client sphere.SeaClient
function OnlineModel:new(configModel, sea_client)
	self.configModel = configModel
	self.authManager = AuthManager(sea_client, configModel)
end

return OnlineModel
