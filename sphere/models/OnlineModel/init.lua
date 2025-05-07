local class = require("class")
local WebApi = require("sphere.models.OnlineModel.WebApi")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")

---@class sphere.OnlineModel
---@operator call: sphere.OnlineModel
local OnlineModel = class()

---@param configModel sphere.ConfigModel
---@param sea_client sphere.SeaClient
function OnlineModel:new(configModel, sea_client)
	self.configModel = configModel
	self.webApi = WebApi()
	self.authManager = AuthManager(sea_client)
end

function OnlineModel:load()
	local webApi = self.webApi
	local authManager = self.authManager

	local configs = self.configModel.configs
	webApi.token = configs.online.token
	webApi.host = configs.urls.host
	webApi:load()

	authManager.config = configs.online
end

return OnlineModel
