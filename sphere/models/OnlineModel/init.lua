local class = require("class")
local WebApi = require("sphere.models.OnlineModel.WebApi")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")
local OnlineScoreManager = require("sphere.models.OnlineModel.OnlineScoreManager")
local OnlineNotechartManager = require("sphere.models.OnlineModel.OnlineNotechartManager")

---@class sphere.OnlineModel
---@operator call: sphere.OnlineModel
local OnlineModel = class()

---@param configModel sphere.ConfigModel
function OnlineModel:new(configModel)
	self.configModel = configModel
	self.webApi = WebApi()
	self.authManager = AuthManager(self.webApi)
	self.onlineScoreManager = OnlineScoreManager(self.webApi)
	self.onlineNotechartManager = OnlineNotechartManager(self.webApi)
end

function OnlineModel:load()
	local webApi = self.webApi
	local onlineNotechartManager = self.onlineNotechartManager
	local authManager = self.authManager

	local configs = self.configModel.configs
	webApi.token = configs.online.token
	webApi.host = configs.urls.host
	webApi:load()

	authManager.config = configs.online
	onlineNotechartManager.urls = configs.urls
end

return OnlineModel
